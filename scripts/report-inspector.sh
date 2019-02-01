#!/bin/bash

set -e
# set -x

BSD_DATE=false
if date --version >/dev/null 2>&1 ; then
    BSD_DATE=false
else
    BSD_DATE=true
fi

LAUNCH_DIR=`dirname $0`
echo Launch dir: $LAUNCH_DIR

## PARMS
REPORT_FORMAT=${REPORT_FORMAT:-"PDF"}
REPORT_TYPE=${REPORT_TYPE:-"FINDING"}

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}

rm -f $REPORT_FILENAME || true

NOW=`date +%s`
LAST_WEEK=$(( $NOW -  7 * 86400 ))

FILTER="states=COMPLETED,completionTimeRange={beginDate=$LAST_WEEK,endDate=$NOW}"
# FILTER="states=COMPLETED,completionTimeRange={beginDate=$YESTERDAY,endDate=$NOW}"

RUNS=`aws inspector list-assessment-runs --filter "$FILTER" --query "assessmentRunArns" --output text`

echo Reporting on assessment runs: [$RUNS]

for ASSESSMENT_ARN in $RUNS
do
  $LAUNCH_DIR/inspector-findings-summary.py $ASSESSMENT_ARN
  COMPLETED_AT=`aws inspector describe-assessment-runs --assessment-run-arns $ASSESSMENT_ARN --query "assessmentRuns[0].completedAt" --output text`

  if [ "$BSD_DATE" = true ] ; then
    COMPLETED_AT=`date -r ${COMPLETED_AT%.*} +%FT%H%M`
  else
    COMPLETED_AT=`date -d @$COMPLETED_AT +%FT%H%M`
  fi
  echo COMPLETED_AT = [$COMPLETED_AT]
  REPORT_FILENAME="inspector-report-$COMPLETED_AT.pdf"

  echo ============================================================================
  echo Assessment completed: $COMPLETED_AT
  aws inspector describe-assessment-runs --assessment-run-arns $ASSESSMENT_ARN --query assessmentRuns[0].findingCounts --output table

  while [ "$REPORT_STATUS" != "COMPLETED" ]
  do

    RESULT=`aws inspector get-assessment-report --assessment-run-arn $ASSESSMENT_ARN --report-file-format $REPORT_FORMAT --report-type $REPORT_TYPE --output text`

    REPORT_STATUS=`echo $RESULT | cut -f1 -d " "`
    REPORT_URL=`echo $RESULT | cut -f2 -d " "`
    echo Status: $REPORT_STATUS

    if [ "$REPORT_STATUS" != "COMPLETED" ] ; then
      sleep 10
    fi
  done
  echo Report is now available. Saving to $REPORT_FILENAME.
  curl -s $REPORT_URL > $REPORT_FILENAME

done
