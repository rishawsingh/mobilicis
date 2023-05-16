# mobilicis

- The repository contains terraform script, python script and Jenkinsfile for the assignment.

- To use terraform script simply replace the "access_key" and "secret_key" with your credentials. 

- To use cloudwatch.py simply replace SNS_TOPIC_ARN with the ARN of an SNS topic that you have created to receive the alert notifications.

- To use Jenkinsfile you need a Jenkins job that uses this Jenkinsfile and is triggered when you push changes to your SCM.
