# ct-patching-scanning
# Cornell University Cloud Team Patching and Scanning Automation

Scripts and templates relevant to patching and scanning EC2 instances

See https://confluence.cornell.edu/display/CLOUD/Beta+AWS+Inspector+and+Patching

## Table of Contents

* [cloudformation](cloudformation) contains CloudFormation templates for deploying this functionality.

* [lambda-unused](lambda-unused) contains a lambda function developed to catch Inspector notifications and send Inspector reports

* [scripts](scripts) contains reporting scripts used by Jenkins jobs

## Patch Testing

### Amazon Linux and Amazon Linux 2

These custom patch baselines work (with delay of 0 days) and produce zero Inspector findings against:
- AmazonLinux2: ami-013be31976ca2c322 # amzn2-ami-hvm-2.0.20181024-x86_64-gp2
- AmazonLinux: ami-0ff8a91507f77f867 # amzn-ami-hvm-2018.03.0.20180811-x86_64-gp2
- AmazonLinuxECS: ami-13401669 # amzn-ami-2017.09.e-amazon-ecs-optimized

```
AmazonLinuxPatchBaseline:
  Type: "AWS::SSM::PatchBaseline"
  Properties:
    Name: cu-cit-cloud-team-patching-AmazonLinux
    OperatingSystem: AMAZON_LINUX
    Description: "Patch baseline for use with https://github.com/CU-CommunityApps/ct-patching-scanning"
    PatchGroups:
      - cu-cit-cloud-team-patching
    ApprovalRules:
      PatchRules:
        - PatchFilterGroup:
            PatchFilters:
              - Key: CLASSIFICATION
                Values:
                  - Security
                  - Bugfix
          ApproveAfterDays: !Ref PatchApprovalDelayParam
```

```
AmazonLinux2PatchBaseline:
  Type: "AWS::SSM::PatchBaseline"
  Properties:
    Name: cu-cit-cloud-team-patching-AmazonLinux2
    OperatingSystem: AMAZON_LINUX_2
    Description: "Patch baseline for use with https://github.com/CU-CommunityApps/ct-patching-scanning"
    PatchGroups:
      - cu-cit-cloud-team-patching
    ApprovalRules:
      PatchRules:
        - PatchFilterGroup:
            PatchFilters:
              - Key: CLASSIFICATION
                Values:
                  - Security
                  - Bugfix
          ApproveAfterDays: !Ref PatchApprovalDelayParam
```

### RHEL

#### RHEL Patch Baseline No. 1

With zero days delay, this patch baseline gave only 2 findings (severity = high) against:
- RHEL7: ami-a8d369c0 # RHEL-7.0_HVM_GA-20141017-x86_64-1-Hourly2-GP2

Findings:
- CVE-2018-15688 Use your Operating System's update feature to update package NetworkManager-config-server-1:1.4.0-20.el7_3.
- CVE-2017-0553 Use your Operating System's update feature to update package NetworkManager-config-server-1:1.4.0-20.el7_3

A manual `yum update --bugfix` gives a several patches that need to be applied, so the patch baseline is not right yet.

```
RHELPatchBaseline:
  Type: "AWS::SSM::PatchBaseline"
  Properties:
    Name: cu-cit-cloud-team-patching-RHEL
    OperatingSystem: REDHAT_ENTERPRISE_LINUX
    Description: "Patch baseline for use with https://github.com/CU-CommunityApps/ct-patching-scanning"
    PatchGroups:
      - cu-cit-cloud-team-patching
    ApprovalRules:
      PatchRules:
        - PatchFilterGroup:
            PatchFilters:
              - Key: CLASSIFICATION
                Values:
                  - Security
                  - Bugfix
          ApproveAfterDays: !Ref PatchApprovalDelayParam
```

### RHEL Patch Baseline No. 2

This one seems to do a better job at applying missing required updates. No updates required with a manual `yum update --bugfix`.

This patch baseline resulted in zero findings against AMI:
- RHEL7: ami-a8d369c0 # RHEL-7.0_HVM_GA-20141017-x86_64-1-Hourly2-GP2

```
RHELPatchBaseline:
  Type: "AWS::SSM::PatchBaseline"
  Properties:
    Name: cu-cit-cloud-team-patching-RHEL
    OperatingSystem: REDHAT_ENTERPRISE_LINUX
    Description: "Patch baseline for use with https://github.com/CU-CommunityApps/ct-patching-scanning"
    PatchGroups:
      - cu-cit-cloud-team-patching
    ApprovalRules:
      PatchRules:
        - PatchFilterGroup:
            PatchFilters:
              - Key: CLASSIFICATION
                Values:
                  - Security
          ApproveAfterDays: !Ref PatchApprovalDelayParam
          # ComplianceLevel: String
          # EnableNonSecurity: Boolean
        - PatchFilterGroup:
            PatchFilters:
              - Key: CLASSIFICATION
                Values:
                  - Bugfix
          ApproveAfterDays: !Ref PatchApprovalDelayParam
````

### Ubuntu

#### AWS Default Ubuntu Patch Baseline

Results in 8 inspector findings across Ubuntu 14.04, 16.04, and 18.04. Findings: https://console.aws.amazon.com/inspector/home?region=us-east-1#/finding?filter=%7B%22assessmentRunArns%22:%5B%20%20%22arn:aws:inspector:us-east-1:225162606092:target%2F0-Xypkhvql%2Ftemplate%2F0-XjCVZwcA%2Frun%2F0-47CWVdpN%22%5D%7D

AMIs:
- Ubuntu1804: ami-432eb53c # ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20180522
  - CVE-2016-4484 update package cryptsetup-2:1.6.1-1ubuntu1
  - CVE-2018-1000021 git-1:2.17.1-1ubuntu0.4
- Ubuntu1604: ami-0f9351b59be17920e
  - CVE-2017-9525 update package cron-0:3.0pl1-124ubuntu2
  - CVE-2015-1336 update package man-db-0:2.6.7.1-1
  - CVE-2016-4484 update package cryptsetup-2:1.6.1-1ubuntu1
- Ubuntu1404: ami-8827efe0 # ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-20140724
  - CVE-2017-9525 update package cron-0:3.0pl1-124ubuntu2
  - CVE-2015-1336 update package man-db-0:2.6.7.1-1
  - CVE-2016-4484 update package cryptsetup-2:1.6.1-1ubuntu1

#### Custom Ubuntu Patch Baseline No. 1

This also results in 8 findings for the same AMIs.

```
UbuntuPatchBaseline:
  Type: "AWS::SSM::PatchBaseline"
  Properties:
    Name: cu-cit-cloud-team-patching-Ubuntu
    OperatingSystem: UBUNTU
    Description: "Patch baseline for use with https://github.com/CU-CommunityApps/ct-patching-scanning"
    PatchGroups:
      - cu-cit-cloud-team-patching
    ApprovalRules:
      PatchRules:
        - PatchFilterGroup:
            PatchFilters:
              - Key: PRODUCT
                Values:
                  - "*"
              - Key: PRIORITY
                Values:
                  - Required
                  - Important
                  - Standard
                  - Optional
                  - Extra
              - Key: SECTION
                Values:
                  - "*"
          ApproveAfterDays: !Ref PatchApprovalDelayParam
          # ComplianceLevel: String
          # EnableNonSecurity: Boolean
```

### Windows

#### Custom Windows Patch Baselines No. 1

The custom patch baseline below, results in 17 (medium severity) findings (https://console.aws.amazon.com/inspector/home?region=us-east-1#/finding?filter=%7B%22assessmentRunArns%22:%5B%20%20%22arn:aws:inspector:us-east-1:225162606092:target%2F0-UeLT6sGX%2Ftemplate%2F0-yDYiyxjF%2Frun%2F0-sTqkMFc1%22%5D%7D) across 4 AMIs:

- Windows2016Base ami-0e60df717fb6cce0e Windows_Server-2016-English-Core-Base-2018.09.15
- Windows2012R2Base ami-04b06bdb58cae787d Windows_Server-2012-R2_RTM-English-64Bit-Base-2018.09.15
- Windows2012Base ami-05c2bf574678ef72a Windows_Server-2012-RTM-English-64Bit-Base-2018.09.15
- Windwos2008R2Base ami-07138e4994095c6b6 Windows_Server-2008-R2_SP1-English-64Bit-Base-2018.09.15

```
WindowsPatchBaseline:
  Type: "AWS::SSM::PatchBaseline"
  Properties:
    Name: cu-cit-cloud-team-patching-Windows
    OperatingSystem: WINDOWS
    Description: "Patch baseline for use with https://github.com/CU-CommunityApps/ct-patching-scanning"
    PatchGroups:
      - cu-cit-cloud-team-patching
    ApprovalRules:
      PatchRules:
        - PatchFilterGroup:
            PatchFilters:
              - Key: PRODUCT
                Values:
                  - "*"
              - Key: CLASSIFICATION
                Values:
                  - CriticalUpdates
                  - SecurityUpdates
              - Key: MSRC_SEVERITY
                Values:
                  - Critical
                  - Important
          ApproveAfterDays: !Ref PatchApprovalDelayParam
          # ComplianceLevel: String
          # EnableNonSecurity: Boolean
    ApprovedPatchesComplianceLevel: CRITICAL
```
