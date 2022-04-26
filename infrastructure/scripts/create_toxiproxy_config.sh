#!/bin/bash

curl --location --request POST http://${LEADS_API_HOST}:8474/proxies \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "Leads-API",
    "listen": "[::]:9999",
    "upstream": "forbes400.herokuapp.com:80",
    "enabled": true
}' \
| python -mjson.tool