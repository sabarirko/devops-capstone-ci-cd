pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sabarirko/web-app:${BUILD_ID}"
    }

    stages {
        stage('Verify Tools') {
            steps {
                script {
                    echo "=== Verifying Tools ==="
                    sh 'git --version'
                    sh 'docker --version'
                    sh 'kubectl version --client=true'
                }
            }
        }

        stage('Checkout') {
            steps {
                git 'https://github.com/sabarirko/website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push to Do
