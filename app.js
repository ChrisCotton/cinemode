var express = require('express');
var http    = require('http');
var url     = require('url');
var fs      = require('fs');

var app     = express();
var server  = http.createServer(app);
var io      = require('socket.io').listen(server);


app.use(express.compress()); // gzip
app.use(express.static(__dirname + '/public') );

app.get('/', function(req,res){
  res.sendfile(__dirname + '/tv.html');
});

app.get('/tablet.html', function(req,res){
  res.sendfile(__dirname + '/tablet.html');
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

server.listen( process.env.PORT || 80 );