const express = require('express')
const mysql = require('promise-mysql')
const winston = require('winston');
const got = require('got');

const app = express();
const port = 8080;

const logConfiguration = {
  'transports': [
    new winston.transports.File({
      filename: 'logs/app.log'
  })
  ]
};

const logger = winston.createLogger(logConfiguration);

// logger.info("DB_HOST: " + process.env.DB_HOST);
// logger.info("DB_USER: " + process.env.DB_USER);
// logger.info("DB_PASSWORD: " + process.env.DB_PASSWORD);
// logger.info("API_USER: " + process.env.API_USER);
// logger.info("API_PASSWORD: " + process.env.API_PASSWORD);
// logger.info("APP_CLIENT_ID: " + process.env.APP_CLIENT_ID);
// logger.info("API_GW_URL: " + process.env.API_GW_URL);

const getDbConnection = async () => {
  return await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: 'cecs'
  })
};

app.get('/crm/customers', async (req, res) => {
  var customers = [];
  var projects = [];

  // Reading all customer projects from AWS Lambda API
  try{
    logger.info("Reading customer projects from API");
    const auth_response = await got.post('https://cognito-idp.eu-central-1.amazonaws.com', {
      body: `{ "AuthParameters" : { "USERNAME" : "${process.env.API_USER}", "PASSWORD" : "${process.env.API_PASSWORD}" }, "AuthFlow" : "USER_PASSWORD_AUTH", "ClientId" : "${process.env.APP_CLIENT_ID}" }`,
      headers: {
          "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth",
          "Content-Type": "application/x-amz-json-1.1"
      }
    }).json();

    projects = await got.get(`${process.env.API_GW_URL}/projects`,{
      headers: {
        "Authorization": auth_response.AuthenticationResult.AccessToken
      }
    }).json();

  } catch(error){
    logger.error(JSON.stringify(error.message));
    res.status(500);
    res.send('Error while reading customer projects');
  }

  // Reading all customers
  try{
    logger.info("Reading customers from DB");
    const db = await getDbConnection()
    customers = await db.query("SELECT * FROM customers");
    await db.end();
    customers.forEach(customer => {
      customer.projects = [];
      projects.forEach(project => {
        if(customer.customerId === project['customer-id']){
          customer.projects.push(project);
        }
      })
    });
  } catch(error){
    logger.error("Error while reading customers", error);
    res.status(500);
    res.send('Error while reading customers');
  }

  res.type('application/json');
  res.send(JSON.stringify(customers));
})

app.get('/crm/salesLeads', async (req, res) => {
  var salesLeads = [];
  try{
    logger.info("Reading sales leads");
    forbesList = await got.get(`${process.env.LEADS_API_URI}/api/forbes400`, {
      headers: {
          "Host": "forbes400.herokuapp.com"
      }
    }).json();

    forbesList.forEach(item => {
      var lead = {
        "contactPerson": item.personName,
        "state": item.state,
        "city": item.city,
        "company": item.source,
        "industries": item.industries
      }
      salesLeads.push(lead);
    })
  } catch(error){
    logger.error(JSON.stringify(error.message));
    res.status(500);
    res.send('Error while reading sales leads');
  }

  res.type('application/json');
  res.send(JSON.stringify(salesLeads));
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})