pipeline {
    
    agent {
        label 'jenkins-agent'
    }

    environment {
        myname = "PREPZEE"
        SCANNER_HOME = tool 'sonarqube-scanner'
    }

    triggers {
      cron '0 * * * *'
    }
    
    tools {
      maven 'maven3'
      jdk 'java17'
    }

    options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')
      disableConcurrentBuilds()
      timeout(30)
      timestamps()
    }

    stages {

        stage ('Code Checkout'){
            steps {
                deleteDir()
                git branch: 'main', url: 'https://github.com/gkdevops/spring-petclinic.git'
            }
        }
        
        stage ('SCA Analysis') {
            steps {
                sh '''
                    trivy fs --format cyclonedx --output result.json .
                    trivy sbom result.json --severity CRITICAL --exit-code 1
                    rm result.json
                '''
            }
        }
        stage('Compile Code') {
            steps {
                sh "mvn test-compile"
            }
        }
      /*
        stage('SAST Analysis') {
            steps {
                withSonarQubeEnv(installationName: 'sonarqube') {
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.java.binaries=. -Dsonar.projectName=PetClinic -Dsonar.projectKey=PetClinic"
                }
            }
        }
        */
        stage('Package Code') {
            steps {
                sh "mvn package -DskipTests -Dcheckstyle.skip"
            }
        }
        stage('Docker Build & Scan') {
            steps {
                sh '''
                IMAGE_TAG=`git log -1 --format=%h`
                docker image build -t petclinic:$IMAGE_TAG
                trivy image petclinic:$IMAGE_TAG
                '''
            }
        }
    }
    
    post {
        always {
            echo "This will always run"
        }
        failure {
            echo "This will be printed if only pipeline fails"
        }
        success {
            echo "This will be printed only when pipeline succeeds"
        }
    }
}
