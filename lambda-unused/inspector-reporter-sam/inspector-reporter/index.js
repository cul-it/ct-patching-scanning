// Handles notifications from Inspector and emails findings from Inspector assessments.

'use strict';

var MAX_TRIES = 4;
var PAUSE_PERIOD_SECONDs = 5;

var REPORT_FILE_FORMAT = process.env.REPORT_FILE_FORMAT ? process.env.REPORT_FILE_FORMAT : "PDF";
var REPORT_TYPE = process.env.REPORT_TYPE ? process.env.REPORT_TYPE : "FINDING";
var EMAIL_FROM_ADDRESS = process.env.EMAIL_FROM_ADDRESS ? process.env.EMAIL_FROM_ADDRESS:"commapps.aws@cornell.edu";
var EMAIL_TO_ADDRESSES = process.env.EMAIL_TO_ADDRESSES ? process.env.EMAIL_TO_ADDRESSES:"pea1@cornell.edu";

// Example notification from SNS, which is input to the Lambda function handler:
// {
//     "Records": [
//         {
//             "EventSource": "aws:sns",
//             "EventVersion": "1.0",
//             "EventSubscriptionArn": "arn:aws:sns:us-east-1:012345678901:alert-pea1:c22b0dbc-6b1b-4bce-8ca1-2aa37b1566b5",
//             "Sns": {
//                 "Type": "Notification",
//                 "MessageId": "bf990d61-d6c4-59a4-a625-5e59e67ff7c4",
//                 "TopicArn": "arn:aws:sns:us-east-1:012345678901:alert-pea1",
//                 "Subject": null,
//                 "Message": "{\"template\":\"arn:aws:inspector:us-east-1:012345678901:target/0-oMBW7xzC/template/0-h3pdIpMY\",\"run\":\"arn:aws:inspector:us-east-1:012345678901:target/0-oMBW7xzC/template/0-h3pdIpMY/run/0-44oJJkCM\",\"time\":\"2018-03-30T12:32:59.685Z\",\"event\":\"ASSESSMENT_RUN_STARTED\",\"target\":\"arn:aws:inspector:us-east-1:011817729931:target/0-oMBW7xzC\"}",
//                 "Timestamp": "2018-03-30T12:32:59.707Z",
//                 "SignatureVersion": "1",
//                 "Signature": "g26TimOVEqDZT+X9ntljHQrxOtOJMXHzLbWP4movYfxXEmOm+OA/wNcn+RZJSEmEyUPoKGhezVh6jZWNNeKNrRAUEutDUlpDxFj8B8FA0pxC94QipL3hXBgO8vSAgrEypGQR9V/EpMQIXmG7YOFte8P8VYtn62mRLd8rdjaxg8EForBekPivIo0tJEARPOfsXBQLmDtYtkVU5hc+Fd9GaFHQ/qhSMuUjG0+rwsUi43NQ4wys/dPotJTzuigLmgvkW3smp6lbc6I7xmcUxpHZt6CpMJq48Fl62fNvdX/p5PRXEi5ZnapubvGbiPN+4xDDUK0wzq0FQi0pqFC0tPO0eg==",
//                 "SigningCertUrl": "https://sns.us-east-1.amazonaws.com/SimpleNotificationService-433026a4050d206028891664da859041.pem",
//                 "UnsubscribeUrl": "https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:012345678901:alert-pea1:c22b0dbc-6b1b-4bce-8ca1-2aa37b1566b5",
//                 "MessageAttributes": {}
//             }
//         }
//     ]
// }

var AWS = require('aws-sdk');
AWS.config.update({region: process.env.AWS_REGION});

var inspector = new AWS.Inspector({apiVersion: '2016-02-16'});

var nodemailer = require('nodemailer');
var transporter = nodemailer.createTransport({ SES: new AWS.SES({apiVersion: '2010-12-01'}) });

// Example "event" passed to sendEmail() and getReport():
// {
//     "template": "arn:aws:inspector:us-east-1:012345678901:target/0-oMBW7xzC/template/0-h3pdIpMY",
//     "findingsCount": "{arn:aws:inspector:us-east-1:316112463485:rulespackage/0-gEjTy7T7=4}",
//     "run": "arn:aws:inspector:us-east-1:012345678901:target/0-oMBW7xzC/template/0-h3pdIpMY/run/0-52kTrMB2",
//     "time": "2018-03-30T13:20:45.050Z",
//     "event": "ASSESSMENT_RUN_COMPLETED",
//     "target": "arn:aws:inspector:us-east-1:012345678901:target/0-oMBW7xzC"
// }

var getReport = function getReport(event) {
    var params = {
      assessmentRunArn: event.run,
      reportFileFormat: REPORT_FILE_FORMAT,
      reportType: REPORT_TYPE
    };
    return inspector.getAssessmentReport(params).promise();
}

var sendEmail = function sendEmail(event, url) {

    var params = {
        assessmentTemplateArns: [ event.template ]
      };
    return inspector.describeAssessmentTemplates(params).promise().then(
        function (data) {

            var message = `Here is your AWS Inspector assessment findings report from ${event.time} using assessment template "${data.assessmentTemplates[0].name}". `;
            return transporter.sendMail({
                from: EMAIL_FROM_ADDRESS,
                to: EMAIL_TO_ADDRESSES,
                subject: `Inspector Report for ${data.assessmentTemplates[0].name}`,
                text: message,
                attachments: [
                    {
                        filename: `InspectorFindings-${data.assessmentTemplates[0].name}-${event.time}.pdf`,
                        path: url
                    }
                ]}
            );
        }
    );
};

function sendAssessmentFindings(event, tryNumber) {

    if (tryNumber <= 0) {
        console.log("ERROR! Maximum retries reached.");
        return;
    }

    getReport(event)
        .then(function(data) {
            console.log('data:', JSON.stringify(data));
            switch (data.status) {
                case "COMPLETED":
                    console.log(`Report status: ${data.status}`);
                    return sendEmail(event, data.url);
                default:
                    console.log(`Unhandled status: ${data.status}`);
                    setTimeout(function() { sendAssessmentFindings(event, tryNumber-1);}, PAUSE_PERIOD_SECONDs*1000);
                    break;
            }
        })
        .catch(console.error.bind(console));
}

exports.handler = (messages, context, callback) => {

    // console.log('SNS Notification:', JSON.stringify(messages));

    for (var i in messages.Records) {

        // Parse the message property into real JSON
        var event = JSON.parse(messages.Records[i].Sns.Message)

        console.log('Received event:', JSON.stringify(event));

        switch(event.event) {
            case "ASSESSMENT_RUN_COMPLETED":
                console.log(`-----> ${event.event}`);
                sendAssessmentFindings(event, MAX_TRIES);
                break;
            default:
                console.log(`WARNING! Unhandled event: ${event.event}`);
                break;
        }
    }
    callback(null, "Success");
};
