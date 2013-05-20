var express   = require('express');
var http      = require('http');
var url       = require('url');
var fs        = require('fs');

var passport          = require('passport')
  , FacebookStrategy  = require('passport-facebook').Strategy
  , LocalStrategy     = require('passport-local').Strategy;

var app     = express()
  , server  = http.createServer(app)
  , io      = require('socket.io').listen(server);

// Passport
var FACEBOOK_APP_ID = "579460945427195"
var FACEBOOK_APP_SECRET = "46acd35a5b81f470c7912533573a34bf";

// serial the whole profile
passport.serializeUser(function(user, done) {
  done(null, user);
});

passport.deserializeUser(function(obj, done) {
  done(null, obj);
});

passport.use(new FacebookStrategy({
    clientID: FACEBOOK_APP_ID,
    clientSecret: FACEBOOK_APP_SECRET,
    callbackURL: "http://digitalfood.me/auth/facebook/callback"
  },
  function(accessToken, refreshToken, profile, done) {
    // asynchronous verification, for effect...
    process.nextTick(function () {
      
      // To keep the example simple, the user's Facebook profile is returned to
      // represent the logged-in user.  In a typical application, you would want
      // to associate the Facebook account with a user record in your database,
      // and return that user instead.
      return done(null, profile);
    });
  }
));


app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'blade');
  
  app.use(express.compress()); // gzip
  //app.use(express.logger());
  app.use(express.cookieParser());
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.session({ secret: 'keyboard cat' }));
  // Initialize Passport!  Also use passport.session() middleware, to support
  // persistent login sessions (recommended).
  app.use(passport.initialize());
  app.use(passport.session());
  app.use(express.static(__dirname + '/public') );
});

/*
app.get('/', function(req,res){
  res.sendfile(__dirname + '/tv.html');
});

app.get('/tablet.html', function(req,res){
  res.sendfile(__dirname + '/tablet.html');
});


app.get('/login', function(req,res){
  res.sendfile(__dirname + '/login.html');
});

*/


app.get('/', function(req, res){
  res.render('index', { user: req.user });
});

app.get('/account', ensureAuthenticated, function(req, res){
  res.render('account', { user: req.user });
});

app.get('/login', function(req, res){
  res.render('login', { user: req.user });
});

app.get('/tv', function(req, res){
  res.render('tv', { user: req.user });
});

app.get('/tablet', function(req, res){
  res.render('tablet', { user: req.user });
});

// GET /auth/facebook
//   Use passport.authenticate() as route middleware to authenticate the
//   request.  The first step in Facebook authentication will involve
//   redirecting the user to facebook.com.  After authorization, Facebook will
//   redirect the user back to this application at /auth/facebook/callback
app.get('/auth/facebook',
  passport.authenticate('facebook'),
  function(req, res){
    // The request will be redirected to Facebook for authentication, so this
    // function will not be called.
  });

// GET /auth/facebook/callback
//   Use passport.authenticate() as route middleware to authenticate the
//   request.  If authentication fails, the user will be redirected back to the
//   login page.  Otherwise, the primary route function function will be called,
//   which, in this example, will redirect the user to the home page.
app.get('/auth/facebook/callback', 
  passport.authenticate('facebook', { failureRedirect: '/login' }),
  function(req, res) {
    res.redirect('/');
  });

app.get('/logout', function(req, res){
  req.logout();
  res.redirect('/');
});



// socket.io
io.sockets.on('connection', function (socket) {
  console.log('connection');

  socket.on('play', function(s){
    console.log('play');
    socket.broadcast.emit('play', function(){} );
  });

  socket.on('pause', function(s){
    console.log('pause');
    socket.broadcast.emit('pause', function(){} );
  });

  socket.on('stop', function(s){
    console.log('stop', function(){} );
  });

  socket.on('disconnect', function () {
    io.sockets.emit('user disconnected');
  });
});



console.log(app.routes);
app.listen(process.env.PORT || 80);


// Simple route middleware to ensure user is authenticated.
//   Use this route middleware on any resource that needs to be protected.  If
//   the request is authenticated (typically via a persistent login session),
//   the request will proceed.  Otherwise, the user will be redirected to the
//   login page.
function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  res.redirect('/login')
}