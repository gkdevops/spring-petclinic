pipeline {
    agent {
        label 'jenkins-agent-dev'
    }

    parameters {
        string defaultValue: 'main', description: 'Provide the GitHub Branch name to checkout code from', name: 'branch_name'
        choice choices: ['dev', 'sit', 'uat', 'prod'], description: 'Select the environment to deploy the code.', name: 'environment'
    }

    tools {
        jdk 'JDK17'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
    }

    options {
        authorizationMatrix([user(name: 'alice', permissions: ['Job/Build', 'Job/Cancel', 'Job/Read', 'Job/Workspace'])])
        disableConcurrentBuilds()
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')
        timestamps()
        timeout(10)
    }

    triggers {
        cron '30 12 * * *'
    }

    stages {
        stage('Code Checkout') {
            steps {
                deleteDir()
                git branch: '$branch_name', credentialsId: 'github-credentials', url: 'https://github.com/gkdevops/spring-petclinic.git'
            }
        }

        stage('Maven Package') {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }
        stage('SonarQube Scan') {
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
                sh '''
                    /home/ec2-user/tools/trivy fs --format cyclonedx --output result.json .
                    #/home/ec2-user/tools/trivy sbom result.json --severity MEDIUM --exit-code 1
                '''
            }
        }
        stage('Build Docker Image'){
            steps {
                sh '''
                COMMIT_ID=`git log -1 --format=%h`
                IMAGE_TAG=$COMMIT_ID-$BUILD_ID
                docker image build -t petclinic:$IMAGE_TAG .
                docker image tag petclinic:$IMAGE_TAG 339712947205.dkr.ecr.us-east-1.amazonaws.com/petclinic:$IMAGE_TAG
                docker image push 339712947205.dkr.ecr.us-east-1.amazonaws.com/petclinic:$IMAGE_TAG
                '''
            }
        }
        stage('Scan Docker Image'){
            steps {
                sh '''
                    COMMIT_ID=`git log -1 --format=%h`
                    IMAGE_TAG=$COMMIT_ID-$BUILD_ID
                    #/home/ec2-user/tools/trivy image 339712947205.dkr.ecr.us-east-1.amazonaws.com/petclinic:$IMAGE_TAG
                '''
            }
        }
        stage('Deploy to EKS'){
            steps {
                sh '''
                    COMMIT_ID=`git log -1 --format=%h`
                    IMAGE_TAG=$COMMIT_ID-$BUILD_ID
                    cd helm/petclinic
                    sed -i 's/tag: .*/tag: '"$IMAGE_TAG"'/' values.yaml
                    helm upgrade --install petclinic . -f values.yaml
                '''
            }
        }
    }
}
