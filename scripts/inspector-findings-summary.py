#!/usr/bin/env python3

# summarize AWS Inspector findings
# Usage:
#
# inspector-findings-summary.py AssessmentRunArn1 AssessmentRunArn2 ...
#

import boto3
from pprint import pprint
import sys

sample_arn = 'arn:aws:inspector:us-east-1:095493758574:target/0-upam1Mi6/template/0-nyZxudNI/run/0-B61BZFB3'

runs = []
if len(sys.argv) < 2:
    # print("Using sample AssessmentRunArn:" + sample_arn)
    runs = [ sample_arn ]
else:
    runs = sys.argv[1:len(sys.argv)]

# print("Using Assessment Run Arns:")
# pprint(runs)

client = boto3.client('inspector')
# ec2 = boto3.resource('ec2')

next_token = None
findings = []
while True:
    if next_token is not None:
        r = client.list_findings(
            assessmentRunArns = runs,
            nextToken= next_token,
            maxResults=999
        )
    else:
        r = client.list_findings(assessmentRunArns = runs, maxResults = 999)
    findings = findings + r['findingArns']
    if 'nextToken' in r:
        next_token = r['nextToken']
    else:
        break

print(f'Total Findings: {len(findings)}')

start = 0
details = []
while start < len(findings):
    end = min(start + 99, len(findings))
    # print(f'start: {start} end: {end}')
    r = client.describe_findings(
        findingArns=findings[start:end],
        locale='EN_US'
    )
    details = details + r['findings']
    start += 100

# pprint(details)

instances = {}
severity_types = {'High', 'Medium', 'Low', 'Informational'}
for f in details:
    id = f['assetAttributes']['agentId']
    name = id
    for t in f['assetAttributes']['tags']:
        if t['key'] == 'Name':
            name = t['value']
            break;
    record = instances.get(id, { 'findings': [] })
    record['findings'].append(f)
    record['name'] = name
    severity = f['severity']
    severity_types.add(severity)
    record[severity] = record.get(severity, 0) + 1
    instances[id] = record

for id,record in instances.items():
    print(f'Instance: {record["name"]} ({id})')
    print(f'\tTotal findings: {len(record["findings"])}')
    # i = ec2.Instance(id)
    for s in severity_types:
        print(f'\t{s}: {record.get(s, 0)}')
