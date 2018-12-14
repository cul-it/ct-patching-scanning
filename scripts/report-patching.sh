#!/bin/bash

# Provides detailed information about patch status of each running instance.

set -e
# set -x

BSD_DATE=false
if date --version >/dev/null 2>&1 ; then
    BSD_DATE=false
else
    BSD_DATE=true
fi

## PARMS
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}

TARGET_INSTANCES=`aws ssm describe-instance-information --query 'InstanceInformationList[*].InstanceId' --output text`

for INSTANCE in $TARGET_INSTANCES
do

  echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  aws ec2 describe-instances --instance-ids $INSTANCE --query 'Reservations[*].Instances[*].{InstanceId:InstanceId, LaunchTime:LaunchTime, State:State.Name, Name:Tags[?Key==`Name`]|[0].Value}' --output table

  echo ========== PATCH SUMMARY ==========================================

  PATCH_TIMES=`aws ssm describe-instance-patch-states --instance-ids $INSTANCE --query InstancePatchStates[*].OperationEndTime --output text`

  echo Scan dates:
  for PATCH_TIME in $PATCH_TIMES
  do
    if [ "$BSD_DATE" = true ] ; then
      RESULT=`date -r ${PATCH_TIME%.*}`
    else
      RESULT=`date -d @$PATCH_TIME`
    fi
    echo "- $RESULT"
  done

  aws ssm describe-instance-patch-states --instance-ids $INSTANCE --output table

  echo ========== MISSING PATCHES ========================================
  aws ssm describe-instance-patches --instance-id $INSTANCE --filters Key=State,Values=Missing --output table

  echo ========== FAILED PATCHES =========================================
  aws ssm describe-instance-patches --instance-id $INSTANCE --filters Key=State,Values=Failed --output table

  echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  echo
  echo
  echo

done

