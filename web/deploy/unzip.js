// require modules
var fs = require('fs');
var zs = require('zstream');
var fstream = require('fstream');

dest = process.argv[2];
target = process.argv[3];
console.log('SOURCE:' + target);

// create a file to stream archive data to.
console.log('SOURCE:' + target);
console.log('DEST:' + dest);
fs.createReadStream(target).pipe(new zs.UnzipStream())
    .pipe(fstream.Writer(dest));