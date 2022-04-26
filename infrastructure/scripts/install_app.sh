#!/bin/bash
chmod 400 appserver_ec2key.pem
printf "[mysql] \n user=${DB_USER} \n password=${DB_PASSWORD}" > ~/.my.cnf
mysql -h $DB_HOST -u $DB_USER < db.sql

server_startup="#!/bin/bash
export LEADS_API_URI=${LEADS_API_URI};
export API_GW_URL=${API_GW_URL};
export DB_HOST=${DB_HOST};
export DB_USER=${DB_USER};
export DB_PASSWORD=${DB_PASSWORD};
export APP_CLIENT_ID=${APP_CLIENT_ID};
export API_USER=${API_USER};
export API_PASSWORD=${API_PASSWORD};
forever stopall;
cd /home/ec2-user/crmApp
forever start app.js"

printf "${server_startup}" > server.sh

scp -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i appserver_ec2key.pem -r ./crmApp/ ec2-user@$EC2_IP:~/
scp -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i appserver_ec2key.pem -r ./server.sh ec2-user@$EC2_IP:~/
scp -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i appserver_ec2key.pem -r ./reboot_nodjs_app.service ec2-user@$EC2_IP:~/
ssh -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i appserver_ec2key.pem  ec2-user@$EC2_IP "chmod +x server.sh; echo "@reboot /home/ec2-user/server.sh" >> crontab_new; crontab crontab_new; sh server.sh"
rm -f appserver_ec2key.pem
rm -rf ./crmApp/