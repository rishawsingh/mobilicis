pipeline {
  agent any
  
  environment {
    AWS_DEFAULT_REGION = "us-east-1"
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    
    stage('Build') {
      steps {
        sh 'npm install'
        sh 'npm run build'
      }
    }
    
    stage('Test') {
      steps {
        sh 'npm run test'
      }
    }

    stage('Deploy') {
      steps {
        withAWS(region: 'us-east-1', credentials: 'aws-creds') {
          sh 'scp -r build/* ec2-user@ec2-12DIGITACCOUNT.us-east-1.compute.amazonaws.com:/var/www/html'
        }
      }
    }
  }
}
