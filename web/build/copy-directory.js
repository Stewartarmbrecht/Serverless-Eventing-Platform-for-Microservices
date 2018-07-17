var ncp = require('ncp').ncp;

source = process.argv[3];
dest = process.argv[2];

console.log("     Source: " + source);
console.log("Destination: " + dest);

ncp.limit = 16;

ncp(source, dest, function(err) {
    if (err) {
        return console.error(err);
    }
    console.log('done!');
});