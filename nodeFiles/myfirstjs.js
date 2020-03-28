var http = require('http');
var argArray = process.argv.slice(1);

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end(argArray[0]);
}).listen(1313);
