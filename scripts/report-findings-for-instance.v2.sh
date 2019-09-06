#!/usr/bin/env bash
# A script to report on findings by instance
# This version takes input parameters of INSTANCE_ID and INSPECTOR_ARN at run time
# set -e
# set -x

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}

INSTANCE_ID=${INSTANCE_ID}
CMD="aws ec2 describe-tags --filters Name=resource-id,Values=${INSTANCE_ID} --query Tags[?Key==\`Name\`].Value --output text"

INSTANCE_NAME=`$CMD`

echo ====    $INSTANCE_NAME    ========================================

RESULT=`aws inspector list-findings \
  --assessment-run-arns ${INSPECTOR_ARN} \
  --filter agentIds=${INSTANCE_ID},severities=High \
  --query findingArns[] \
  --output text`

echo "   "
echo "########## HIGH SEVERITY ##########"
for FINDING in $RESULT
do
  echo "- $FINDING"
  QUERY="findings[].[recommendation]"
  FINDING=`aws inspector describe-findings --finding-arns $FINDING --query $QUERY --output text`

  echo $FINDING
done

RESULT2=`aws inspector list-findings \
  --assessment-run-arns ${INSPECTOR_ARN} \
  --filter agentIds=${INSTANCE_ID},severities=Medium \
  --query findingArns[] \
  --output text`

echo "   "
echo "########## Medium Severity ##########"
for FINDING2 in $RESULT2
do
  echo "Finding: $FINDING2"
  QUERY2="findings[].[recommendation]"
  FINDING2=`aws inspector describe-findings --finding-arns $FINDING2 --query $QUERY2 --output text`

  echo "Recommendation: $FINDING2"
done
