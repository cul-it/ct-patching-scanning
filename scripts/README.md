# Reporting Scripts

These scripts are used by Jenkins jobs to report on patching and scanning results.

## Prerequisites

You will need the [AWS CLI]( https://aws.amazon.com/cli/) installed to run these scripts. The Bash scripts assume that you have the CLI configured with appropriate access keys and/or environment variables (see https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

The Inspector reporting requires Python, as does the variant of the patch reporting that handles >= 50 instances. All these Python scripts should work with either Python 2.x or 3.x. In either case, you will need to the [Boto3 AWS SDK](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html) installed.


## Coverag Reporting

The `report-coverage.py` analyzes all EC2 instances in the current AWS region and provides what information it can relevant to patching and scanning. Included info:

```
instance: i-0e69c96038c1d5584        ==> instance ID
        Name: cu-aws-accounts        ==> name of the instance
        EC2 state: running           ==> current state of the instance
        EC2 state reason:            ==> info about the state (e.g., when the instance was stopped)
        ----SSM/PATCH INFO----
        Patch Group: cu-cit-cloud-team-patching ==> which patch baseline will be used
        Maintenance Group: 24x7-group-a         ==> value of the "Maintenance Group" EC2 tag
        SSM ping status: Online                 ==> whether SSM is commuinicating with the instance
        SSM agent version: 2.3.542.0            ==> version of the SSM agent
        SSM agent latest? True                  ==> whether that version is the latest version available
        ----INSPECTOR INFO----
        Inspector Group: default                ==> value of the "Inspector Group" EC2 tag
        Inspector Target "Default Assessment Group Target": will be INSPECTED
        Inspector Target "test-inspector-group": will NOT be inspected
        Inspector agent version: 1.1.1446.0     ==> version of the Inspector agent
```

## Patch Reporting

`report-patching-summary.sh` provides a summary of instance patch states, but is limited to < 50 instances. Use `report-patching-summary.py` if there is any possbility of having more than 50 instances. 

`report-patching.sh` provides a long, detailed report of the patching situation for all instances.

### Jenkins Job

A weekly Jenkins job for patch reporting might look like this:
```bash
export AWS_DEFAULT_REGION=us-east-1
echo "BEGIN_REPORT"
scripts/report-patching-summary.sh
# OR
scripts/report-patching-summary.py
echo "END_REPORT"

scripts/report-patching.sh > detailed-patch-report.txt
```

Your Jenkins job should probably include the console output in a notification email, and also attach `detailed-patch-report.txt` for detailed information.

## Inspector Reporting

`report-inspector.sh` searches for Inspector assessment results from the past week and uses `inspector-findings-summary.py` to report the details of each.

### Jenkins Job

A weekly Jenkins job for Inspector reporting might look like this:
```bash
export AWS_DEFAULT_REGION=us-east-1
echo "BEGIN_REPORT"
scripts/report-inspector.sh
echo "END_REPORT"
```

Your Jenkins job should probably include the console output in a notification email, and also attach `*.pdf` files that the script generated for detailed information.
