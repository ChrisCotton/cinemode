Features
========
2013-6-3
- sychronize sliding of products with the playing time of video
- allow one user per room


Source
======
The program is still under development. Currently, the branch **express.io** is the latest one. you can download it by issuing

    git clone  git@github.com:ChrisCotton/cinemode.git -b socket.io


How to use
==========

### prerequisite ###
1. mysql (or mariadb)


### Setup/Installation ###
1. set up database, replace <user_name> with you mysql admin name

    mysql -u <user_name> -p < ./utility/setup_db.sql
    
1.1 replace the mysql login information with yours in modules/conn.coffee
    
    ...
    conn = mysql.createConnection(
      { host:     'localhost'
      , user:     'admin'
      , database: 'cinemode'
      , password: '123123123'})
    conn.connect()
    ...

2. set up facebook login, replace the facebook app info with yours in modules/passport.coffee

    ...
    HOST                  = "http://digitalfood.me"
    FACEBOOK_APP_ID       = "579460945427195"
    FACEBOOK_APP_SECRET   = "46acd35a5b81f470c7912533573a34bf";
    FACEBOOK_CALLBACK_URL = "http://digitalfood.me/auth/facebook/callback";
    ...
    
3. install node.js package, in root directory

    npm install -g coffee-script
    npm install 
    
    
### Start ###
In root directory
  
    coffee app.coffee