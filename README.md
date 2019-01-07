# ct-patching-scanning

# Cornell University Cloud Team Patching and Scanning Automation

Scripts and templates relevant to patching and scanning EC2 instances

See https://confluence.cornell.edu/display/CLOUD/Beta+AWS+Inspector+and+Patching

## Table of Contents

* [cloudformation](cloudformation) contains CloudFormation templates for deploying this functionality.

* [lambda-unused](lambda-unused) contains a lambda function developed to catch Inspector notifications and send Inspector reports

* [scripts](scripts) contains reporting scripts used by Jenkins jobs

## Patch Baseline Testing

The patch baselines in [cloudformation/15-patch-baselines.yaml](cloudformation/15-patch-baselines.yaml) are based on the AWS default patch baselines, but slightly modified to patch additional packages that Inspector would otherwise trigger on.
