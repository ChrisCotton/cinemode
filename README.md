Features
========
2013-6-3
- sychronize sliding of products with the playing time of video
- allow one user per room


Source
======
the branch **socket.io** is the latest one. you can download it by issuing
> git clone  git@github.com:ChrisCotton/cinemode.git -b socket.io


How to use
==========

### prerequisite ###
1. mysql (or mariadb)


### Setup/Installation ###
1. set up database, replace <user_name> with you mysql admin name

    mysql -u <user_name> -p < ./utility/setup_db.sql
    
1.1 modify the mysql login information in modules/conn.coffee
    
    ...
    conn = mysql.createConnection(
      { host: 'localhost'
      , user: 'admin'
      , database: 'cinemode'
      , password: '123123123'})
    conn.connect()
    ...
    
2. install node.js package, in root directory

    npm install -g coffee-script
    npm install 
    
    
### Start ###
coffee app.coffee