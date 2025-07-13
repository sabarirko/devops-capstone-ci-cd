pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/sabarirko/website.git'  // Your repo
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t sabarirko/web-app:${BUILD_ID} .'
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                    sh 'docker tag sabarirko/web-app:${BUILD_ID} sabarirko/web-app:latest'
                    sh 'docker push sabarirko/web-app:latest'
                }
            }
        }
        stage('Deploy to K8s') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'
            }
        }
    }
}
