#!/usr/bin/env python
# Provides summary detailed information about patch status of each running instance.
# Should work equally well with python2 or python3 as long as boto3 is installed.
# 
# Usage:
#
# report-patching-summary.py
#

import boto3
from pprint import pprint

client = boto3.client('ssm')

MAX_RESULTS = 50

next_token = None
info = []
while True:
    if next_token is not None:
        r = client.describe_instance_information(
            MaxResults = MAX_RESULTS,
            NextToken = next_token
        )
    else:
        r = client.describe_instance_information(
            MaxResults = MAX_RESULTS
        )
    info = info + r['InstanceInformationList']
    if 'nextToken' in r:
        next_token = r['nextToken']
    else:
        break

instance_ids = list(map(lambda x: x['InstanceId'], info))
patch_states = []
x = 0
while x < len(instance_ids):
    temp = instance_ids[x:min(x+MAX_RESULTS, len(instance_ids))]
    x += MAX_RESULTS
    next_token = None
    while True:
        if next_token is not None:
            r = client.describe_instance_patch_states(
                InstanceIds=temp,
                NextToken=next_token,
                MaxResults=MAX_RESULTS
            )
        else:
            r = client.describe_instance_patch_states(
                InstanceIds=temp,
                MaxResults=MAX_RESULTS
            )
        patch_states = patch_states + r['InstancePatchStates']
        if 'nextToken' in r:
            next_token = r['nextToken']
        else:
            break

print('InstanceId           Failed Missing Installed InstalledOther InstalledRejected NotApplicable PatchGroup                 Date/Time')
for p in patch_states:
    print('{:20.20} {:6}  {:6}    {:6}         {:6}            {:6}        {:6} {:26.26} {}'.format(p['InstanceId'],p['FailedCount'],p['MissingCount'],p['InstalledCount'],p['InstalledOtherCount'],p['InstalledRejectedCount'],p['NotApplicableCount'],p['PatchGroup'],p['OperationStartTime']))