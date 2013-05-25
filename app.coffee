express   = require 'express.io'
app = express()
app.http().io();

require './modules/misc'
require './modules/conn'
passport = require './modules/passport'

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
app.get   '/'         , (req,res) -> res.redirect('/tv')
app.get   '/tv'       , ensureAuthenticated                 , (req,res) -> res.render 'tv', {user: req.user}
app.get   '/tablet'   , ensureAuthenticated                 , (req,res) -> res.render 'tablet', { user: req.user }
app.get   '/account'  , ensureAuthenticated                 , (req,res) -> res.render 'account', { user: req.user }
app.get   '/login'    , (req,res) -> res.render 'login', { user: req.user }
app.post  '/login'    ,  
  passport.authenticate 'local', 
    { successRedirect: '/'
    , failureRedirect: '/login' }
app.get   '/signup'   , (req,res) -> res.render 'signup'
app.post  '/signup'   , 
  createUser, 
  passport.authenticate 'local', 
    { successRedirect: '/'
    , failureRedirect: '/login'}   

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

#info app.routes
port = process.env.PORT || 80
info "listening on #{port}"
app.listen (port)