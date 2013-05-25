passport          = require 'passport'
FacebookStrategy  = require('passport-facebook').Strategy;
LocalStrategy     = require('passport-local').Strategy;

# Passport
# var FACEBOOK_APP_ID       = "579460945427195"
# var FACEBOOK_APP_SECRET   = "46acd35a5b81f470c7912533573a34bf";
# var FACEBOOK_CALLBACK_URL = "http://digitalfood.me/auth/facebook/callback";

# for testing
FACEBOOK_APP_ID       = "363076780460904"
FACEBOOK_APP_SECRET   = "0a5daa96bed157945af97a1a0345f579"
FACEBOOK_CALLBACK_URL = "http://byebyeprince.com/auth/facebook/callback"

# passport initialize
passport.serializeUser( (user,done) -> done(null ,user.id) )

passport.deserializeUser( (id,done) -> 
  conn.cond1 'users', {id:id}, (err,usr) ->
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
    # well, what should I use? 
    # if others know it they can hack it using local login. 
    # Use a random number?
    # I should use the password_enable field
    pwd   = "null"  
    conn.cond1 'users', {email:email}, (err,user) ->
      return done(null, user) if user
      conn.insert 'users', { email:email, password_hash: sha256(pwd) }, (err) -> 
        return done(err, false) if err
        conn.cond1 'users', { email:email }, (err, usr) ->
          return done(err, false) if err
          done(null, usr)
))

passport.use( new LocalStrategy(
  (email, pwd, done) -> 
    conn.cond1 'users', {email:email}, (err, usr) -> 
      return done err,  false if err
      return done null, false unless usr
      return done null, false if (sha256 pwd) != usr.password_hash
      done(null, usr)
        
))

global.authenticateLocal =  (req,res,next) ->
  console.log 'local authenticating...'
  passport.authenticate 'local', 
    { successRedirect: '/'
    , failureRedirect: '/login' }
  next()

global.ensureAuthenticated = (req,res,next) ->
  if req.isAuthenticated()
    next()
  else
    res.redirect('/login')

global.createUser = (req,res,next) ->
  info req.body 
  email = req.body.email
  pwd   = req.body.password
  pwd_c = req.body.password_confirmation
  
  if pwd != pwd_c
    res.render 'signup', { error: 'password does not match.' }
  else
    conn.cond1 'users', {email:email}, (err,usr) ->
      if usr
        res.render 'signup', { error: 'email already exists' }
      else
        conn.insert 'users', { email:email, password_hash: sha256(pwd) }, (err) ->
          if err
            res.render 'signup', { error: 'cannot create user' }
          else 
            next()  

module.exports = passport