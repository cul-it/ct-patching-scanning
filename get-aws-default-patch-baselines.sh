#!/usr/bin/env bash

echo ============================================================================
echo UBUNTU
echo ============================================================================
aws ssm get-patch-baseline --baseline-id arn:aws:ssm:us-east-1:075727635805:patchbaseline/pb-0c7e89f711c3095f4

echo ============================================================================
echo CENTOS
echo ============================================================================
aws ssm get-patch-baseline --baseline-id arn:aws:ssm:us-east-1:075727635805:patchbaseline/pb-03e3f588eec25344c

echo ============================================================================
echo RHEL
echo ============================================================================
aws ssm get-patch-baseline --baseline-id arn:aws:ssm:us-east-1:075727635805:patchbaseline/pb-0cbb3a633de00f07c

echo ============================================================================
echo Amazon Linux
echo ============================================================================
aws ssm get-patch-baseline --baseline-id arn:aws:ssm:us-east-1:075727635805:patchbaseline/pb-0c10e657807c7a700

echo ============================================================================
echo Amazon Linux 2
echo ============================================================================
aws ssm get-patch-baseline --baseline-id arn:aws:ssm:us-east-1:075727635805:patchbaseline/pb-0be8c61cde3be63f3

echo ============================================================================
echo SUSE
echo ============================================================================
aws ssm get-patch-baseline --baseline-id arn:aws:ssm:us-east-1:075727635805:patchbaseline/pb-07d8884178197b66b

echo ============================================================================
echo Windows
echo ============================================================================
aws ssm get-patch-baseline --baseline-id arn:aws:ssm:us-east-1:075727635805:patchbaseline/pb-09ca3fb51f0412ec3
