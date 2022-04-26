#!/bin/bash

#Setup DB-Username & Password
echo "Set DB-User:";
read DB_USER;

echo "Set DB-User's password:";
read -s DB_PASSWORD;

#Setup API-Username & Password for API-Gateway access
echo "Set API-User:";
read API_USER;

echo "Set API-User's password:";
read -s API_PASSWORD;

#Deploy infrastructure
mkdir -p keys
terraform init
if terraform apply -auto-approve -var "database_user=${DB_USER}" -var "database_password=${DB_PASSWORD}"
then
    export AWS_REGION=$(terraform output --raw aws_region)
    export API_GW_URL=$(terraform output --raw api-gateway)
    export APP_CLIENT_ID=$(terraform output --raw cognito-app-client-id)
    export APP_USER_POOL_ID=$(terraform output --raw cognito-user-pool-id)
    export BASTION_IP=$(terraform output --raw bastion-public-ip)
    export APPSERVER_IP=$(terraform output --raw appserver-private-ip)
    export LEADS_API_HOST=$(terraform output --raw toxiproxy-public-ip)
    export DB_HOST=$(terraform output --raw database-endpoint)
fi

#Create API-User
source ./scripts/create_user.sh
source ./scripts/get_access_token.sh

#Create ToxiProxy for Leads-API server on Port 9999
source ./scripts/create_toxiproxy_config.sh
export LEADS_API_URI="http://${LEADS_API_HOST}:9999"

#Wait for server to be fully up and running
echo "Waiting 15 sec. for all servers to be up and running..."
sleep 15

#Deploy EC2 Node.JS app
cd servers/crmApp
npm install
cd ../..

chmod 400 ./keys/bastion_ec2key.pem
chmod 777 ./servers/crmApp
scp -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i ./keys/bastion_ec2key.pem -r ./servers/crmApp/ ec2-user@$BASTION_IP:~/
scp -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i ./keys/bastion_ec2key.pem -r ./keys/appserver_ec2key.pem ec2-user@$BASTION_IP:~/
scp -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i ./keys/bastion_ec2key.pem -r ./data/mysql/db.sql ec2-user@$BASTION_IP:~/
scp -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i ./keys/bastion_ec2key.pem -r ./scripts/install_app.sh ec2-user@$BASTION_IP:~/
ssh -q -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" -i ./keys/bastion_ec2key.pem  ec2-user@$BASTION_IP "LEADS_API_URI=${LEADS_API_URI}; API_GW_URL=${API_GW_URL}; DB_USER=${DB_USER}; DB_PASSWORD=${DB_PASSWORD}; DB_HOST=${DB_HOST}; EC2_IP=${APPSERVER_IP}; APP_CLIENT_ID=${APP_CLIENT_ID}; API_USER=${API_USER}; API_PASSWORD=${API_PASSWORD} source install_app.sh"



