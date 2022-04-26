#!/bin/bash

export AWS_REGION='eu-central-1'
export API_ENDPOINT='https://9b85gb3lx8.execute-api.eu-central-1.amazonaws.com/crm'
export API_USER='anro'
export APP_CLIENT_ID='18fcepadkfevsbc6pa4gkbjntq'
export TOXI_PROXY_HOST='3.71.244.4'
export APPSERVER_EC2_ID='i-0f8c760c24b43210b'

echo "API-Password:";
read -s API_PASSWORD;

API_TOKEN=$(curl --location --request POST https://cognito-idp.${AWS_REGION}.amazonaws.com \
--header 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' \
--header 'Content-Type: application/x-amz-json-1.1' \
--data-raw '{
   "AuthParameters" : {
      "USERNAME" : "'${API_USER}'",
      "PASSWORD" : "'${API_PASSWORD}'"
   },
   "AuthFlow" : "USER_PASSWORD_AUTH",
   "ClientId" : "'${APP_CLIENT_ID}'"
}' | python2.7 -c "import sys, json; print json.load(sys.stdin)['AuthenticationResult']['AccessToken']")

export API_TOKEN

#Create python virtual environment and install all packages
python3 -m venv ~/.venvs/chaostk
source ~/.venvs/chaostk/bin/activate
pip install chaostoolkit
pip install chaostoolkit-toxiproxy
pip install chaostoolkit-aws
pip install chaostoolkit-reporting