pipeline {

    agent {
        label 'jenkins-agent'
    }
 
    environment {
      SCANNER_HOME = tool 'sonarqube-scanner'
      NAME = "GOUTHAM"
    }
 
    tools {
      maven 'MAVEN3'
      jdk 'JAVA17'
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

    stages {
      stage('code checkout') {
        steps {
            deleteDir()
            git branch: '$branch_name', url: 'https://github.com/gkdevops/spring-petclinic.git'
        }
      }

      stage('compile code') {
        steps {
            sh "mvn clean package -DskipTests"
        }
      }

      stage('SAST Analysis') {
        steps {
            withSonarQubeEnv(installationName: 'sonarqube') {
                sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.java.binaries=. -Dsonar.projectName=PetClinic -Dsonar.projectKey=PetClinic -Dsonar.qualitygate.wait=true"
            }
        }
      }
/*
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }        
*/
        stage ('SCA Analysis') {
            steps {
                sh '''
                    trivy fs --format cyclonedx --output result.json .
                    #trivy sbom result.json --severity MEDIUM --exit-code 1
                    rm result.json
                '''
            }
        }

    stage('Docker Build & Image') {
        steps {
            sh '''
              COMMIT_ID=`git log -1 --format=%h`
              IMAGE_TAG=$COMMIT_ID-$BUILD_ID
              docker image build -t petclinic:$IMAGE_TAG .
              trivy image petclinic:$IMAGE_TAG
              docker image tag petclinic:$IMAGE_TAG 339712947205.dkr.ecr.us-east-1.amazonaws.com/petclinic:$IMAGE_TAG
              docker image push 339712947205.dkr.ecr.us-east-1.amazonaws.com/petclinic:$IMAGE_TAG
              '''
        }
    }
    stage('Deploy to k8s') {
        steps {
            withCredentials([file(credentialsId: 'kubeconfig-dev', variable: 'kubeconfig')]) {
                sh "kubectl apply -f ./k8s/ --kubeconfig=$kubeconfig"
            }
        }
    }
    }
}
