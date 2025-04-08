pipeline {

    agent {
        label 'jenkins-agent'
    }
 
    options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')
      timeout(5)
      disableConcurrentBuilds()
      timestamps()
    }

    parameters {
      string defaultValue: 'develop', description: 'The Branch from which code is checked out', name: 'branch_name', trim: true
      choice choices: ['dev', 'sit', 'uat'], description: 'Select the environment to deploy the code', name: 'environment'
    }

    triggers {
      cron '30 5 * * *'
    }

    stages {
      stage('code checkout') {
        steps {
            git branch: '$branch_name', url: 'https://github.com/gkdevops/spring-petclinic.git'
        }
      }

      stage('compile code') {
        steps {
            echo "stage 2"
            sleep 10
        }
      }
    }
}
