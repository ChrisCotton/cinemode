fs        = require 'fs'
express   = require 'express.io'
app = express()
app.http().io();

global.conf = JSON.parse fs.readFileSync('./config/cinemode.conf')
# info conf


require './modules/misc'
require './modules/conn'
passport = require './modules/passport'

# configure
app.configure( ()->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  
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
app.get   '/tv', 
  ensureAuthenticated, 
  (req,res) -> 
    r = req.user.id.toString()
    req.session.room = req.user.id
    req.session.save()
    res.render 'tv', {user: req.user}
app.get   '/tablet', 
  ensureAuthenticated , 
  (req,res) ->  
    res.render 'tablet', 
      { user: req.user
      , products: [ { img:"/shoes.jpg", name:"Shoes", price:15 , start: 0 }
                  , { img:"/tshirt.jpg", name:"Shirt", price:10, start: 5 }
                  , { img:"/jeans.jpg", name:"Jeans", price:30, start: 10}
                  , { img:"/shoes2.jpg", name:"Shoes", price:15, start: 15 }
                  , { img:"/tshirt2.jpg", name:"Shirt", price:10, start: 20 }
                  , { img:"/jeans2.jpg", name:"Jeans", price:30, start: 25 }
                  ] 
      }
app.get   '/account'  , ensureAuthenticated                 , (req,res) -> res.render 'account', { user: req.user }
app.get   '/password' , ensureAuthenticated                 , (req,res) -> res.render 'password', { user: req.user }
app.post  '/password' , ensureAuthenticated                 , changePassword
app.get   '/login'    , (req,res) -> res.render 'login', { user: req.user }
app.post  '/login'    ,  
  passport.authenticate 'local', 
    { successRedirect: '/'
    , failureRedirect: '/login' }
    
app.get   '/signup'   , (req,res) -> res.render 'signup'
app.post  '/signup'   , 
  createUser, 
  passport.authenticate 'local', 
    { successRedirect: '/'        # some problem, do not auto redirect to /tv
    , failureRedirect: '/login'}    

app.get '/auth/facebook', passport.authenticate('facebook')

app.get '/auth/facebook/callback', 
  passport.authenticate('facebook', { successRedirect: '/'
                                    , failureRedirect: '/login'})
        
app.get '/logout', (req,res) -> 
  req.logout()
  res.redirect('/')
  
global.like = 0
  
# socket.io
app.io.route 'ready', (req) -> 
  info 'new connection'

app.io.route 'room', {
  ask: (req) ->
    info 'room ask'
    req.io.join req.session.room
    req.io.emit 'room:reply', req.session.room
  } 

app.io.route 'test', (req) -> debug "test received #{req.data}"

app.io.route 'video', {
  # command ( order )
  play: (req) ->
    info 'play'
    req.io.room(req.session.room).broadcast 'video:play'
  ,
  pause: (req) ->
    info 'pause'
    req.io.room(req.session.room).broadcast 'video:pause'
  ,
  next: (req) ->
    info 'next'
    req.io.room(req.session.room).broadcast 'video:next'
  ,
  prev: (req) ->
    info 'prev'
    req.io.room(req.session.room).broadcast 'video:prev'
  ,
  volume: (req) ->
    info "volume: #{req.data}"
    req.io.room(req.session.room).broadcast 'video:volume', req.data
  ,
  current_time: (req) ->
    info "set current time #{req.data}"
    req.io.room(req.session.room).broadcast 'video:current_time', req.data
  ,
  # info ( free to listen )
  time: (req) ->
    req.io.room(req.session.room).broadcast 'video:time', req.data
  ,
  ended: (req) ->
    info 'ended'
    req.io.room(req.session.room).broadcast 'video:ended' 
  ,
  volume_change: (req) ->
    info "volume change: #{req.data}"
    req.io.room(req.session.room).broadcast 'video:volume_change', req.data
  ,
  duration_change: (req) ->
    info "duration_change: #{req.data}"
    req.io.room(req.session.room).broadcast 'video:duration_change', req.data
  ,
  loaded_metadata: (req) ->
    info "loaded_metadata"
    req.io.room(req.session.room).broadcast 'video:loaded_metadata'
  ,
  # query ( ask and reply pair )
  volume_ask: (req) ->
    info "volume ask"
    req.io.room(req.session.room).broadcast 'video:volume_ask'
  ,
  volume_reply: (req) ->
    info "volume reply #{req.data}"
    req.io.room(req.session.room).broadcast 'video:volume_reply', req.data
  ,
  current_time_ask: (req) ->
    info 'current_time_ask'
    req.io.room(req.session.room).broadcast 'video:current_time_ask'
  ,
  current_time_reply: (req) ->
    info "current_time_reply #{req.data}"
    req.io.room(req.session.room).broadcast 'video:current_time_reply', req.data
  ,
  duration_ask: (req) ->
    info 'duration ask'
    req.io.room(req.session.room).broadcast 'video:duration_ask'
  ,
  duration_reply: (req) ->
    info "duration_reply #{req.data}"
    req.io.room(req.session.room).broadcast 'video:duration_reply', req.data
    
  ,
  like: (req) ->
    info 'like'
    global.like += 1;
    req.io.room(req.session.room).broadcast 'video:like', global.like
}
  


#info app.routes
port = process.env.PORT || 80
info "listening on #{port}"
app.listen (port)