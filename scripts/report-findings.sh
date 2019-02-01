#!/usr/bin/env bash

# A script to report on findings by instance

# set -e
# set -x

INSTANCE_ID=i-09b8e69b75b4814cd
CMD="aws ec2 describe-tags --filters Name=resource-id,Values=i-09b8e69b75b4814cd --query Tags[?Key==\`Name\`].Value --output text"

INSTANCE_NAME=`$CMD`

echo ====$INSTANCE_NAME========================================

RESULT=`aws inspector list-findings \
  --assessment-run-arns arn:aws:inspector:us-east-1:095493758574:target/0-upam1Mi6/template/0-nyZxudNI/run/0-5YvUT3oX \
  --filter agentIds=$INSTANCE_ID,severities=High \
  --query findingArns[] \
  --output text`

for FINDING in $RESULT
do
  echo "- $FINDING"
  QUERY="findings[].[arn,'|',severity,'|',recommendation,'|',attributes[?key==\`package_name\`].value,'|',assetAttributes.agentId,'|',assetAttributes.tags[?key==\`Name\`].value]"
  FINDING=`aws inspector describe-findings --finding-arns $FINDING --query $QUERY --output text`

  echo $FINDING
done



#
# aws inspector describe-findings --finding-arns
