#!/bin/bash

# Provides desummary tailed information about patch status of each running instance.

set -e
# set -x

## PARMS
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}

TARGET_INSTANCES=`aws ssm describe-instance-information --query 'InstanceInformationList[*].InstanceId' --output text`

aws ssm describe-instance-patch-states --instance-ids $TARGET_INSTANCES --query 'InstancePatchStates[*].{A_InstanceId:InstanceId, B_FailedCount:FailedCount, C_MissingCount:MissingCount, D_InstalledCount:InstalledCount, E_InstalledOtherCount:InstalledOtherCount, F_NotApplicableCount:NotApplicableCount}' --output table
