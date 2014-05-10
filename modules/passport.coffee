passport          = require 'passport'
FacebookStrategy  = require('passport-facebook').Strategy;
LocalStrategy     = require('passport-local').Strategy;

# Passport
FACEBOOK_APP_ID       = global.conf.facebook.app_id
FACEBOOK_APP_SECRET   = global.conf.facebook.app_secret
FACEBOOK_CALLBACK_URL = global.conf.facebook.callback_url

Models = (require './mongoose').models
UserModel = Models.User

# passport initialize
passport.serializeUser( (user,done) -> done(null ,user._id) )

passport.deserializeUser( (id,done) -> 
  UserModel.findById id, (err,usr) ->
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
    UserModel.findOne {email:email}, (err,user) ->
      return done(null, user) if user
      UserModel.create { email:email, passwordHash: sha256(pwd) }, (err) ->
        return done(err, false) if err
        UserModel.findOne { email:email }, (err, usr) ->
          return done(err, false) if err
          done(null, usr)
))

passport.use( new LocalStrategy(
  (email, pwd, done) ->
    UserModel = Models.User
    UserModel.findOne { email:email }, (err, usr) ->
      console.log usr
      return done err,  false if err
      return done null, false unless usr
      return done null, false if (sha256 pwd) != usr.passwordHash
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
  UserModel = Models.User

  if pwd != pwd_c
    res.render 'signup', { error: 'passwords do not match.' }
  else
    UserModel.findOne {email:email}, (err, usr) ->
      if usr
        res.render 'signup', { error: 'email already exists' }
      else
        UserModel.create { email:email, passwordHash: sha256(pwd) }, (err) ->
          if err
            res.render 'signup', { error: 'cannot create user: ' + err }
          else 
            next()  
            
global.changePassword = (req,res,next) ->
  info req.user
  original = req.body.original
  pwd      = req.body.password
  pwd_c    = req.body.password_confirmation
  uid      = req.user.id
  
  UserModel.findById uid, (err,usr) ->
    next() if err
    if usr.passwordHash != sha256(original)
      res.render 'password', {error: "wrong password"}
    else if pwd != pwd_c
      res.render 'password', {error: "passwords do not match."}
    else
      usr.passwordHash = sha256 pwd
      usr.save () ->
        res.redirect '/'
        
module.exports = passport
