#!/usr/bin/env python
# Report which systems are ready for patching/inspection.
#
# Usage:
#
# report-coverage.py
#

import boto3
from pprint import pprint
import sys

def get_tag(info_hash, tag_key):
    tags = info_hash.get("Tags", {})
    for item in tags:
        if item['Key'] == tag_key:
            return item['Value']
    return ""

inspector_agent_health_decode = {
    "HEALTHY": "will be INSPECTED",
    "UNHEALTHY" : "UNHEALTHY - inspector agent is unhealthy and should be checked ",
    "UNKNOWN" : "will NOT be inspected"
}

ec2 = boto3.client('ec2')
ssm = boto3.client('ssm')
inspector = boto3.client('inspector')

# MAX_RESULTS = 50

next_token = None
instances_hash = {}
instance_ids_array = []
ssm_instance_info_hash = {}

#######################################################
# # EC2 info
#######################################################

while True:
    if next_token is not None:
        r = ec2.describe_instances(
            MaxResults = 1000,
            NextToken = next_token
        )
    else:
        r = ec2.describe_instances(
            MaxResults = 1000
        )
    for x in r['Reservations']:
        for y in x['Instances']:
            id = y['InstanceId']
            instances_hash[id] = y
            instance_ids_array.append(id)
    if 'nextToken' in r:
        next_token = r['nextToken']
    else:
        break
# pprint(instances_hash)

#######################################################
# # SSM info
#######################################################
STEP = 50
start = 0
while start < len(instances_hash):
    end = min(start + STEP - 1, len(instances_hash))
    # print('start: {} end: {}'.format(start, end))
    # pprint(instances_hash.keys()[start:end])
    r = ssm.describe_instance_information(
            Filters=[
                { 'Key': 'InstanceIds',
                    'Values': instance_ids_array[start:end]
                }
            ],
            MaxResults=STEP
        )
    for x in r['InstanceInformationList']:
        id = x['InstanceId']
        ssm_instance_info_hash[id] = x
    start += STEP
# pprint(ssm_instance_info_hash)

#######################################################
# # Inspector info
#######################################################

r = inspector.list_assessment_targets(
        maxResults=500
    )
inspector_target_arns = r['assessmentTargetArns']
# pprint(inspector_target_arns)

inspector_target_info_hash = {}
inspector_target_preview_hash = {}

r = inspector.describe_assessment_targets(
        assessmentTargetArns=inspector_target_arns
    )
for x in r['assessmentTargets']:
    arn = x['arn']
    inspector_target_info_hash[arn] = x
    response = inspector.preview_agents(
        previewAgentsArn=arn,
        maxResults=500
    )
    for target in response['agentPreviews']:
        id = target['agentId']
        if inspector_target_preview_hash.get(id, None) == None:
            inspector_target_preview_hash[id] = {}
        inspector_target_preview_hash[id][arn] = target

# pprint(inspector_target_info_hash)
# pprint(inspector_target_preview_hash)

#######################################################
# # output
#######################################################

for id in instances_hash:
    ec2_info = instances_hash[id]
    ssm_instance_info = ssm_instance_info_hash.get(id, {})
    
    print("instance: {}".format(id))
    print("\tName: {}".format(get_tag(ec2_info, "Name")))
    print("\tEC2 state: {}".format(ec2_info['State']['Name']))
    print("\tEC2 state reason: {}".format(ec2_info['StateTransitionReason']))
    print("\t----SSM/PATCH INFO----")
    print("\tPatch Group: {}".format(get_tag(ec2_info, "Patch Group")))
    print("\tMaintenance Group: {}".format(get_tag(ec2_info, "Maintenance Group")))
    print("\tSSM ping status: {}".format(ssm_instance_info.get('PingStatus', "")))
    print("\tSSM agent version: {}".format(ssm_instance_info.get('AgentVersion', "")))
    print("\tSSM agent latest? {}".format(ssm_instance_info.get('IsLatestVersion', "")))
    print("\t----INSPECTOR INFO----")
    print("\tInspector Group: {}".format(get_tag(ec2_info, "Inspector Group")))
    inspector_instance_info = inspector_target_preview_hash.get(id, {})
    inspector_agent_version = "n/a"
    for arn in inspector_target_arns:
        name = inspector_target_info_hash[arn]['name']
        iii = inspector_instance_info.get(arn, {})
        agent = iii.get('agentHealth', "")
        agent = inspector_agent_health_decode.get(agent, "will NOT be inspected")
        print("\tInspector Target \"{}\": {}".format(name, agent))
        if inspector_agent_version == "n/a":
            inspector_agent_version = iii.get('agentVersion', "n/a")
    print("\tInspector agent version: {}".format(inspector_agent_version))
