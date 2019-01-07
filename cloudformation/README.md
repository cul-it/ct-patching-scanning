# CloudFormation templates

## 10-s3.yaml

Creates an S3 bucket with lifecycle (expiration) policy to hold output from scanning and patching tasks

## 20-patching.yaml

Creates Systems Manager Maintenance Windows, Tasks, etc. to implement a basic patching and patch scanning process.

## 30-inspector.yaml

Creates Inspector configuration run inspector evaluations against targeted instances.

## 99-test-instances.windows.yaml

Creates Windows EC2 instances to test SSM documents and patch baselines.

*NOTE* Since initial launch of Windows instances take so long to do the initialization/patching, we want to delay the association that does the patching. So, the instances are launched with "Maitnance Group" = "test-windows-XXX". Change that to "test-windows" once CPUs settle down (~ 1 hr) to make the association with the SSM document. Then the SSM document will run for another round of patching.

After the association is successful, manually launch/run the Windows Inspector template defined in the this CloudFormation template.

## 99-test-instances-linux.yaml

Creates linux EC2 instances to test SSM documents and patch baselines.

After the association is successful, manually launch/run the linux Inspector templates defined in the this CloudFormation template.
