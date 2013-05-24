express = require 'express.io'
http = require 'http'
crypto = require 'crypto'
mysql = require 'mysql'

app = express()
app.http().io();

passport = require 'passport'
FacebookStrategy = require('passport-facebook').Strategy;
LocalStrategy = require('passport-local').Strategy;

# Passport
# var FACEBOOK_APP_ID       = "579460945427195"
# var FACEBOOK_APP_SECRET   = "46acd35a5b81f470c7912533573a34bf";
# var FACEBOOK_CALLBACK_URL = "http://digitalfood.me/auth/facebook/callback";


# for testing
FACEBOOK_APP_ID       = "363076780460904"
FACEBOOK_APP_SECRET   = "0a5daa96bed157945af97a1a0345f579"
FACEBOOK_CALLBACK_URL = "http://byebyeprince.com/auth/facebook/callback"

info  = (msg) -> console.log(msg)
debug = (msg) -> console.log(msg)
warn  = (msg) -> console.log(msg)


conn = mysql.createConnection(
  { host: 'localhost'
  , user: 'admin'
  , database: 'cinemode'
  , password: '123123123'})
conn.connect()

sha256 = (pwd) -> crypto.createHash('sha256').update(pwd).digest('hex')

# user table
createUser = (email,pwd, callback) ->
  q = "insert into users(email, password_hash) values (?,?);"
  conn.query(q, [email, sha256(pwd)], (err,rows,field) ->
    findUserByEmail email, (err,usr,fields) -> call(err,usr,fields))
  
findUser = (id, callback) ->
  q = "select * from users where id = ?;"
  conn.query(q, id, (err,rows,fields) -> callback(err,rows[0],fields) )
  
findUserByEmail = (email, callback) ->
  q = 'select * from users where email = ?;'
  # precondition: email must be unique
  conn.query(q, email, (err,rows,fields) -> callback(err,rows[0],fields) ) 
  
  
# passport initialize
passport.serializeUser( (user,done) -> done(null ,user.id) )

passport.deserializeUser( (id,done) -> 
  findUser id, (err,usr) ->
    if usr == undefined
      throw new Error('unable to deserializeUser')
    else
      done(null, usr)
)
      
passport.use( new FacebookStrategy(
  { clientID: FACEBOOK_APP_ID
  , clientSecret: FACEBOOK_APP_SECRET
  , callbackURL: FACEBOOK_CALLBACK_URL
  }
  ,
  (accessToken, refreshToken, profile, done) ->
    email = profile.username + '@facebook.com'
    findUserByEmail email, (err,user) ->
      if user 
        done(null, user)
      else
        createUser email, (err, usr) -> 
          if err then done(err, false) else done(null, usr)
))

passport.use( new LocalStrategy(
  (email, pwd, done) -> 
    findUserByEmail email, (err, usr) -> 
      done err,  false if err
      done null, false unless usr
      if sha256 pwd == usr.password_hash
        done(null, usr)
      else
        done null, false
))

ensureAuthenticated = (req,res,next) ->
  if req.isAuthenticated()
    next()
  else
    res.redirect('/login')
      
# configure
app.configure( ()->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'blade'
  
  app.use express.compress()
  
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.session({ secret: 'awesome secret'})
  
  app.use passport.initialize()
  app.use passport.session()
  
  app.use express.static(__dirname + '/public')
)

# routing
app.get '/', 
  ensureAuthenticated, 
  (req,res) -> res.redirect('/tv')

app.get '/tablet', 
  ensureAuthenticated, 
  (req,res) -> res.render 'tablet', { user: req.user }
  
app.get '/account',
  ensureAuthenticated,
  (req,res) -> res.render 'account', { user: req.user }
  
app.get  '/login', (req,res) -> res.render 'login', { user: req.user }
app.post '/login', 
  passport.authenticate 'local', { successRedirect: '/'
                                 , failureRedirect: '/login' }
  
app.get  '/signup', (req,res) -> res.render 'signup'
app.post '/signup', (req,res,next) -> 
  email = req.body.email
  pwd   = req.body.password
  pwd_c = req.body.password_confirmation
  
  if pwd != pwd_c
    res.render 'signup', { error: 'password does not match.' }
  else
    findUserByEmail email, (err,usr) ->
      if usr
        res.render 'signup', { error: 'email already exists' }
      else
        createUser email, pwd
        passport.authenticate('loacl', { successRedirect: '/', failureRedirect: '/login'})(req,res)

app.get '/auth/facebook', passport.authenticate('facebook')

app.get '/auth/facebook/callback', 
  passport.authenticate('facebook', { successRedirect: '/'
                                    , failureRedirect: '/login'})
        
app.get '/logout', (req,res) -> 
  req.logout()
  res.redirect('/')
  
# socket.io
app.io.route 'ready', (req) -> info 'new connection'

app.io.route 'test', (req) -> debug 'test received'

app.io.route 'video', {
  play: (req) ->
    info 'play'
    req.io.broadcast 'video:play'
  ,
  pause: (req) ->
    info 'pause'
    req.io.broadcast 'video:pause'
  ,
  time: (req) ->
    info 'time'
    req.io.broadcast 'video:time', req.data.time
}
  
app.io.route 'product', {
  like: (req) ->
    info 'like'
}

app.listen (process.env.PROT || 80)