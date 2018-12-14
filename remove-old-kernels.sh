#!/usr/bin/env bash

# set -e
set -x

if [ -n "$(command -v yum)" ] ; then
  echo Using yum
  # Amazon Linux, CentOS, RHEL
  uname -r
  rpm -qa kernel
  # package-cleanup --oldkernels --count=1
  # rpm -qa kernel
elif [ -n "$(command -v apt-get)" ] ; then
  echo Using apt-get
else
  echo Not using yum or apt-get
fi

# aws ssm send-command --document-name "pea1-test-RemoveOldKernelsSSMDoc-1UIKWDA68YEUT" --document-version "\$DEFAULT" --targets "Key=instanceids,Values=i-0e57245de458ce68b" --parameters '{}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "cu-cs-sandbox-patching-logs" --output-s3-key-prefix "pea1/" --region us-east-1
