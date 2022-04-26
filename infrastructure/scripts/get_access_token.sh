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

if [ -z $APP_CLIENT_ID ]
then
  echo "App-Client-Id:";
  read APP_CLIENT_ID;
fi

curl --location --request POST https://cognito-idp.${AWS_REGION}.amazonaws.com \
--header 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' \
--header 'Content-Type: application/x-amz-json-1.1' \
--data-raw '{
   "AuthParameters" : {
      "USERNAME" : "'${API_USER}'",
      "PASSWORD" : "'${API_PASSWORD}'"
   },
   "AuthFlow" : "USER_PASSWORD_AUTH",
   "ClientId" : "'${APP_CLIENT_ID}'"
}' \
| python -mjson.tool