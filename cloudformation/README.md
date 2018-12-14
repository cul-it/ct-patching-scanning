# CloudFormation templates

## 10-s3.yaml

Creates an S3 bucket with lifecycle (expiration) policy to hold output from scanning and patching tasks

## 20-patching.yaml

Creates Systems Manager Maintenance Windows, Tasks, etc. to implement a basic patching and patch scanning process.

## 30-inspector.yaml

Creates Inspector configuration run inspector evaluations against targeted instances.

## 99-test-instances.yaml

Creates EC2 instances of various OS flavors to test SSM documents
