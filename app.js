var express   = require('express.io');
var http      = require('http');

var app     = express()
app.http().io();

var passport          = require('passport')
  , FacebookStrategy  = require('passport-facebook').Strategy;

// Passport
// var FACEBOOK_APP_ID       = "579460945427195"
// var FACEBOOK_APP_SECRET   = "46acd35a5b81f470c7912533573a34bf";
// var FACEBOOK_CALLBACK_URL = "http://digitalfood.me/auth/facebook/callback";

// for testing
var FACEBOOK_APP_ID       = "363076780460904"
var FACEBOOK_APP_SECRET   = "0a5daa96bed157945af97a1a0345f579";
var FACEBOOK_CALLBACK_URL = "http://byebyeprince.com/auth/facebook/callback";

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
    callbackURL: FACEBOOK_CALLBACK_URL
  },
  function(accessToken, refreshToken, profile, done) {
    process.nextTick(function () {
      // return facebook profile
      return done(null, profile);
    });
  }
));


app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'blade');
  
  app.use(express.compress()); // gzip
  
  app.use(express.cookieParser());
  app.use(express.session({ secret: 'you dont know this' }));
  app.use(passport.initialize());
  app.use(passport.session());
  
  app.use(express.static(__dirname + '/public') );
});

// routing
app.get('/', 
  ensureAuthenticated, 
  function(req, res){
    res.redirect('/tv');
  });

app.get('/tv', 
  ensureAuthenticated,
  function(req, res){
    res.render('tv', { user: req.user });
  });

app.get('/tablet', 
  ensureAuthenticated,
  function(req, res){
    res.render('tablet', { user: req.user });
  });

app.get('/account', 
  ensureAuthenticated, 
  function(req, res){
    res.render('account', { user: req.user });
  });

app.get('/login', 
  function(req, res){
    res.render('login', { user: req.user });
  });


app.get('/auth/facebook',
  passport.authenticate('facebook'),
  function(req, res){} // this function will not be called.
);

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
app.io.route('ready', function(req) {
  console.log('new connection');
});

app.io.route('test', function(req){
  console.log('test received');
});

app.io.route('play', function(req){
  console.log('play');
  req.io.broadcast('play', {});
});

app.io.route('pause', function(req){
  console.log('pause');
  req.io.broadcast('pause', {});
});

app.io.route('next', function(req){
  console.log('next');
  req.io.broadcast('next', {});
});

app.io.route('prev', function(req){
  console.log('prev');
  req.io.broadcast('prev', {});
});


app.io.route('volume', function(req){
  console.log('volume: ' + req.data);
  req.io.broadcast('volume', req.data);
});

app.io.route('video_time', function(req){
  req.io.broadcast('video_time', req.data);
});


global.like = 0;
app.io.route('like', function(req){
  console.log('like');
  global.like += 1;
  app.io.broadcast('like', global.like);
});

// start server
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