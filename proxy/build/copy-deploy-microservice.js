var fs = require('fs');
fs.createReadStream('../../scripts/deploy-microservice.sh').pipe(fs.createWriteStream('../deploy/deploy-microservice.sh'));