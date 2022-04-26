#!/bin/bash

if [ -z $API_USER ]
then
  echo "Username:";
  read API_USER;
fi

if [ -z $API_PASSWORD ]
then
  echo "Password:";
  read -s API_PASSWORD;
fi

aws cognito-idp sign-up \
  --region ${AWS_REGION} \
  --client-id ${APP_CLIENT_ID} \
  --username ${API_USER} \
  --password ${API_PASSWORD}

aws cognito-idp admin-set-user-password \
     --user-pool-id ${APP_USER_POOL_ID} \
     --username ${API_USER} \
     --password ${API_PASSWORD} \
     --permanent