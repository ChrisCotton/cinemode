Features
========

#### 2013-6-3
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
2. facebook developer account


### Setup/Installation ###
1. set up database, replace <user_name> with you mysql admin name

      mysql -u <user_name> -p < ./utility/setup_db.sql
    
2. copy config/cinemode.conf.template to config/cinemode.conf
   fill in all the missing info.

      {
        "host":
          "http://XXXX.com"
        ,
        "facebook" : 
          { "app_id"        : "111111111111111"
          , "app_secret"    : "00000000000000000000000000000000"
          , "callback_url"  : "http://XXXX.com/auth/facebook/callback"
          }
        ,
        "mysql" :
          { "host" : "XXXX"
          , "user" : "XXXX"
          , "database" : "cinemode"
          , "password" : "XXXXXX"
          }
      }

    
4. install node.js package, in root directory
    
      npm install -g coffee-script
      npm install 
    
    
### Start ###
In root directory
  
    sudo coffee app.coffee