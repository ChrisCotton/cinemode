var express   = require('express.io');
var http      = require('http');
var crypto    = require('crypto');
var mysql     = require('mysql');

var app     = express()
app.http().io();

var passport          = require('passport')
  , FacebookStrategy  = require('passport-facebook').Strategy
  , LocalStrategy     = require('passport-local').Strategy;

// Passport
// var FACEBOOK_APP_ID       = "579460945427195"
// var FACEBOOK_APP_SECRET   = "46acd35a5b81f470c7912533573a34bf";
// var FACEBOOK_CALLBACK_URL = "http://digitalfood.me/auth/facebook/callback";


// for testing
var FACEBOOK_APP_ID       = "363076780460904"
var FACEBOOK_APP_SECRET   = "0a5daa96bed157945af97a1a0345f579";
var FACEBOOK_CALLBACK_URL = "http://byebyeprince.com/auth/facebook/callback";

function put(message){
  console.log(message);
}

//  var redis = require("redis"),
//      client = redis.createClient();

// client.on("error", function (err) {
//   put("Error " + err);
// });

// client.set("string key", "string val", redis.print);
// client.hset("hash key", "hashtest 1", "some value", redis.print);
// client.hset(["hash key", "hashtest 2", "some other value"], redis.print);
// client.hkeys("hash key", function (err, replies) {
//   put(replies.length + " replies:");
//   replies.forEach(function (reply, i) {
//       put("    " + i + ": " + reply);
//   });
//   client.quit();
// });




var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'admin',
  database : 'cinemode',
  password : '123123123',
});
connection.connect();
process.on('exit', function(){
  connection.end();
  console.log('end mysql coonnection');
});

function createUser(email, password, callback){
  var sha256 = crypto.createHash('sha256').update(password).digest("hex");
  var value = '("' + email + '", "' + sha256 + '")';
  var query = 'insert into users(email, password_hash) values ' + value + ';'
  // put(query);
  connection.query(query, callback);
}

function findUser(id, callback){
  query = "select * from users where id = " + id + ";"
  connection.query(query, callback);
}

function findUserByEmail(email, callback){
  query = 'select * from users where email = "' + email + '";';
  connection.query(query, callback);
}


// createUser('test1@example.com', "123123");
// createUser('test2@example.com', "123123");
// createUser('test3@example.com', "abcabc", function(err, rows, fields){
//   if(err) throw err;
//   put("fields: " + fields);
//   put("result: " + rows);
// });

// connection.query('select * from users;', function(err, rows, fields) {
//   if (err) throw err;
//   put('Query result: ', rows);
// });

// connection.end();

// serial the whole profile
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  findUser(id, function(err,rows,fields){
    if( rows[0] == undefined ) throw new Error('unable to deserializeUser');
    else done(err, rows[0]);
  });
});

passport.use(new FacebookStrategy({
    clientID: FACEBOOK_APP_ID,
    clientSecret: FACEBOOK_APP_SECRET,
    callbackURL: FACEBOOK_CALLBACK_URL
  },
  function(accessToken, refreshToken, profile, done) {
    put("FacebookStrategy");
    var email =  profile.username + "@facebook.com"; 
    put("   email: " + email);

    findUserByEmail( email , function(err, rows, fields){
      if( rows.length === 0 ){
        createUser( email, crypto.randomByte(256) );
        findUserByEmail( email, function(err, rows, fields){
          done(err, rows[0]);
        });
      } else {
        done(err, rows[0] ); 
      } 
    });
  }
));

passport.use(new LocalStrategy(
  function(email, pwd, done) {
    put("LocalStrategy:");
    put("   email: " + email);
    put("   pwd: " + pwd );
    
    findUserByEmail(email, function(err, rows, fields){
      put("   rows.length: " + rows.length);
      if( err ){ return done(err, false); }
      if( rows.length == 0 ){ return done(err, false) }
      put("   rows[0]: " + rows[0]);
      var user = rows[0];
      var hash = crypto.createHash('sha256').update(pwd).digest("hex");
      put("   isHashEq: " + (user.password_hash == hash) );
      if( user.password_hash !== hash  ){ return done(null, false); }
      put("   !!PASS!!");
      return done(null, user);
    });
  }));


app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'blade');
  
  app.use(express.compress()); // gzip
  
  app.use(express.cookieParser()); 
  app.use(express.bodyParser());    // parse body for form 
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

app.post('/login',
  passport.authenticate('local', { successRedirect: '/',
                                   failureRedirect: '/login' }),
  function(req,res){}
  );


app.get('/signup',
  function(req, res){
    res.render('signup', {});
  });

app.post('/signup',
  function(req, res, next){
    // put(req.body);
    var email = req.body.email;
    var pwd = req.body.password;
    
    if(pwd != req.body.password_confirmation){
      res.render('signup', {error: 'password does not match.'});
    } else {
      findUserByEmail(req.body.email, function(err,rows,fields){
        if(rows.length == 0){
          // no exixting user
          createUser(email, pwd);
          next();
        } else {
          res.render('signup', { error: 'email already exists.'}) 
        }
      });
    }
  },
  passport.authenticate('local', { successRedirect: '/',
                                   failureRedirect: '/login' })
  );

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
  put('new connection');
});

app.io.route('test', function(req){
  put('test received');
});

app.io.route('play', function(req){
  put('play');
  app.io.broadcast('play', {});
});

app.io.route('pause', function(req){
  put('pause');
  app.io.broadcast('pause', {});
});

app.io.route('video_time', function(req){
  app.io.broadcast('video_time', req.data.at);
});


global.like = 0;
app.io.route('like', function(req){
  put('like');
  global.like += 1;
  app.io.broadcast('like', global.like);
});

// start server
//put(app.routes);
app.listen(process.env.PORT || 80);


// Simple route middleware to ensure user is authenticated.
//   Use this route middleware on any resource that needs to be protected.  If
//   the request is authenticated (typically via a persistent login session),
//   the request will proceed.  Otherwise, the user will be redirected to the
//   login page.
function ensureAuthenticated(req, res, next) {
  put( "isAuthenticated: " + req.isAuthenticated() );
  if (req.isAuthenticated()) { return next(); }
  res.redirect('/login')
}