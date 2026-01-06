pipeline {

    agent {
        label 'jenkins-nonprod-agents'
    }

    options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
      timestamps()
    }

    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
    }

    triggers {
      cron '30 7 * * *'
    }

    parameters {
      choice choices: ['DEV', 'SIT', 'UAT'], description: 'Please select an environment to deploy code', name: 'environment'
      string defaultValue: 'main', description: 'Branch name to checkout the code', name: 'branch_name', trim: true
    }

    tools {
      jdk 'jdk17'
      maven 'maven3'
    }

    stages {
      stage('checkout code') {
        steps {
          deleteDir()
          echo "checkout code starting..."
          git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/gkdevops/spring-petclinic.git'
        }
      }
    
      stage('compile code') {
        steps {
          sh "mvn clean package -DskipTests"
        }
      }

      stage('SAST - SonarQube Scan') {
        steps {
            withSonarQubeEnv(installationName: 'sonarqube') {
                sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.java.binaries=. -Dsonar.projectName=PetClinic -Dsonar.projectKey=PetClinic"
            }
        }
      }

     /*      
      stage('SonarQube Quality Gate') {
        steps {
          timeout(time: 5, unit: 'MINUTES') {
              waitForQualityGate abortPipeline: true
          }
        }
      }
      */

      stage('SCA Scan') {
        steps {
          sh """
          trivy fs --format cyclonedx --output sbom.json .
          trivy sbom sbom.json
          """
        }
      }

        stage('Build Docker Image'){
            steps {
                sh '''
                COMMIT_ID=`git log -1 --format=%h`
                IMAGE_TAG=$COMMIT_ID-$BUILD_ID
                docker image build -t petclinic:$IMAGE_TAG .
                #docker image tag petclinic:$IMAGE_TAG 339712947205.dkr.ecr.us-east-1.amazonaws.com/petclinic:$IMAGE_TAG
                #docker image push 339712947205.dkr.ecr.us-east-1.amazonaws.com/petclinic:$IMAGE_TAG
                '''
            }
        }
        
        stage('Scan Docker Image'){
            steps {
                sh '''
                    COMMIT_ID=`git log -1 --format=%h`
                    IMAGE_TAG=$COMMIT_ID-$BUILD_ID
                    trivy image petclinic:$IMAGE_TAG
                '''
            }
        }
    }
}
