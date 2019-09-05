#!/usr/bin/env bash
# A script to report on findings by instance
# This version takes input parameters of INSTANCE_ID and INSPECTOR_ARN at run time
# set -e
# set -x

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}

INSTANCE_ID=${INSTANCE_ID}
CMD="aws ec2 describe-tags --filters Name=resource-id,Values=${INSTANCE_ID} --query Tags[?Key==\`Name\`].Value --output text"

INSTANCE_NAME=`$CMD`

echo ====$INSTANCE_NAME========================================

RESULT=`aws inspector list-findings \
  --assessment-run-arns ${INSPECTOR_ARN} \
  --filter agentIds=${INSTANCE_ID},severities=High \
  --query findingArns[] \
  --output text`

for FINDING in $RESULT
do
  echo "- $FINDING"
  QUERY="findings[].[arn,'|',severity,'|',recommendation,'|',attributes[?key==\`package_name\`].value,'|',assetAttributes.agentId,'|',assetAttributes.tags[?key==\`Name\`].value]"
  FINDING=`aws inspector describe-findings --finding-arns $FINDING --query $QUERY --output text`

  echo $FINDING
done
