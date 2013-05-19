var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')
  , url = require('url')

app.listen(80);

function handler (req, res) {
  var pathname = url.parse(req.url).pathname;
  console.log(pathname);

  fs.readFile(__dirname + pathname,
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading '+pathname);
    }

    res.writeHead(200);
    res.end(data);
  });
}

io.sockets.on('connection', function (socket) {
  console.log('connection');

  socket.on('play', function(socket){
    console.log('play');
    socket.broadcast.emit('play');
  });

  socket.on('pause', function(socket){
    console.log('pause');
    socket.broadcast.emit('pause');
  });

  socket.on('stop', function(socket){
    console.log('stop');
  });

  socket.on('disconnect', function () {
    io.sockets.emit('user disconnected');
  });
});

