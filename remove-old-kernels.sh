#!/usr/bin/env bash

# A script to remove old linux kernels from a yum-based and apt-get-based linux distros.

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
