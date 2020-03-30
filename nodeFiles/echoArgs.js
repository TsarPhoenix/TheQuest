var http = require('http');
var args = process.argv.slice(2)
var argStr = ""

args.forEach(function(arg){
  argStr = argStr.concat(' ', arg);
})

console.log(argStr);

http.createServer(function(req, res) {
  res.writeHead(200, {
    'Content-Type': 'text/html'
  });
  res.write('<!doctype html>\n<html lang="en">\n' +
    '\n<meta charset="utf-8">\n<title>The Quest is Complete</title>\n' +
    '<style type="text/css">* {font-family:arial, sans-serif;}</style>\n' +
    '\n\n<h1>echoing: ' + argStr + '</h1>\n' +
    '\n\n');
  res.end();
}).listen(1313);
