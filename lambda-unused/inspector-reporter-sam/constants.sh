#!/usr/bin/env bash

export S3_BUCKET="cu-example-inspector-resources"

# Arbitrary name of the ZIP file to upload.
export CODE_ZIPFILE="inspector-reporter-v1.0.zip"

# Prefix of S3 key for the CODE_ZIPFILE
export S3_KEY_PREFIX="lambda/"
# Full S3 key name is $S3_KEY_PREFIX$CODE_ZIPFILE
