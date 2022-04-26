#!/bin/bash
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs --enablerepo=nodesource
sudo yum install -y mysql
npm install forever -g