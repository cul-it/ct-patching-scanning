#!/usr/bin/env bash

# zip the lambda source code and upload it to S3

# setup environment
source ./constants.sh

# zip contents
zip -qr lambda-code.zip inspector-reporter/index.js inspector-reporter/node_modules/nodemailer

# load to S3
aws s3 cp ./lambda-code.zip s3://$S3_BUCKET/$S3_KEY_PREFIX$CODE_ZIPFILE