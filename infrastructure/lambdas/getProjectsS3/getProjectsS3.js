const AWS = require('aws-sdk');
const s3 = new AWS.S3();

const bucketParams = {
  Bucket: 'cecs-s3-bucket',
  Key: 'project_list.json'
};

module.exports.handler = async (event) => {
  try {
    const data = await s3.getObject(bucketParams).promise();
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: data.Body.toString('ascii')
    }
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: "Error while reading data from S3"
    }
  }
};