These scripts are used by Jenkins jobs to report on patching and scanning results.

`report-inspector.sh` searches for Inspector assessment results from the past week and uses `inspector-findings-summary.py` to report the details of each.

`report-patching-summary.sh` provides a summary of instance patch states, but is limited to < 50 instances. Use `report-patching-summary.py` if there is any possbility of having more than 50 instances. 

`report-patching.sh` provides a long, detailed report of the patching situation for all instances.

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

A weekly Jenkins job for Inspector reporting might look like this:
```bash
export AWS_DEFAULT_REGION=us-east-1
echo "BEGIN_REPORT"
scripts/report-inspector.sh
echo "END_REPORT"
```
