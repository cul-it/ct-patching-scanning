# Reporting Scripts

These scripts are used by Jenkins jobs to report on patching and scanning results.

## Prerequisites

You will need the [AWS CLI]( https://aws.amazon.com/cli/) installed to run these scripts. The Bash scripts assume that you have the CLI configured with appropriate access keys and/or environment variables (see https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

The Inspector reporting requires Python, as does the variant of the patch reporting that handles >= 50 instances. All these Python scripts should work with either Python 2.x or 3.x. In either case, you will need to the [Boto3 AWS SDK](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html) installed.


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
