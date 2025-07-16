pipeline {
    agent none

    stages {
        stage('Hello') {
            agent { label 'k8s-m' }
            steps {
                echo 'Hello World'
            }
        }

        stage('Git Checkout') {
            agent { label 'k8s-m' }
            steps {
                git 'https://github.com/sabarirko/website.git'
            }
        }

        stage('Docker Build and Push') {
            agent { label 'k8s-m' }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: '69cb3e3b-969f-4a84-94b0-b1f8fef6eec4',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        docker build -t sabarirko/project-2 .
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push sabarirko/project-2
                    '''
                }
            }
        }

        stage('Kubernetes Deploy') {
            agent { label 'k8s-m' }
            steps {
                sh '''
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                '''
            }
        }
    }
}
