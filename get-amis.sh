#!/usr/bin/env bash

FILTER="Name=state,Values=available Name=architecture,Values=x86_64 Name=root-device-type,Values=ebs Name=virtualization-type,Values=hvm"

OPTIONS="--output text --query Images[*].[ImageId,Architecture,CreationDate,Name,Description,VirtualizationType,RootDeviceType,Architecture,State] "

SORT="sort -k 2"

echo Ubunut1404
aws ec2 describe-images --owners 099720109477 --filters 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-????????' $FILTER $OPTIONS | $SORT

echo Ubuntu1604
aws ec2 describe-images --owners 099720109477 --filters 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-????????' $FILTER $OPTIONS | $SORT

echo Ubunut1804
aws ec2 describe-images --owners 099720109477 --filters 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-????????' $FILTER $OPTIONS | $SORT

echo AmazonLinux2
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' $FILTER $OPTIONS | $SORT

echo AmazonLinux
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn-ami-hvm-????.??.?.????????-x86_64-gp2' $FILTER $OPTIONS | $SORT

echo RHEL6
aws ec2 describe-images --owners 309956199498 --filters 'Name=name,Values=RHEL-6.?_HVM_GA*' $FILTER $OPTIONS | $SORT

echo RHEL7
aws ec2 describe-images --owners 309956199498 --filters 'Name=name,Values=RHEL-7.?_HVM_GA*' $FILTER $OPTIONS | $SORT

echo SUSE
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=suse-sles-??-v????????-hvm-ssd-x86_64' $FILTER $OPTIONS | $SORT

echo Centos6
aws ec2 describe-images --owners aws-marketplace --filters 'Name=product-code,Values=6x5jmcajty9edm3f211pqjfn2' $FILTER $OPTIONS | $SORT

echo Centos7
aws ec2 describe-images --owners aws-marketplace --filters 'Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce' $FILTER $OPTIONS | $SORT

echo Debian 6.x Squeeze
aws ec2 describe-images --owners 379101102735 --filters "Name=name,Values=*squeeze*"  $FILTER $OPTIONS | $SORT

echo Debian 7.x Wheezy
aws ec2 describe-images --owners 379101102735 --filters "Name=name,Values=*wheezy*"  $FILTER $OPTIONS | $SORT

echo Debian 8.x Jessie
aws ec2 describe-images --owners 379101102735 --filters "Name=name,Values=debian-jessie-*"  $FILTER $OPTIONS | $SORT

echo Debian 9.x Stretch
aws ec2 describe-images --owners 379101102735 --filters "Name=name,Values=debian-stretch-*"  $FILTER $OPTIONS | $SORT

echo Windows 2016
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=Windows_Server-2016*English*Core-Base*'  $FILTER $OPTIONS | $SORT

echo Windows 2012
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=Windows_Server-2012-RTM*English*Base*'  $FILTER $OPTIONS | $SORT

echo Windows 2012R2
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=Windows_Server-2012-R2_RTM*English*Base*'  $FILTER $OPTIONS | $SORT

echo Windows 2008R2
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=Windows_Server-2008-R2*English*Base*'  $FILTER $OPTIONS | $SORT
