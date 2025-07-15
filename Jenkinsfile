pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "sabarirko/web-app"
        DOCKER_TAG = "${env.BUILD_ID}"
    }
    
    stages {
        stage('Verify Tools') {
            steps {
                script {
                    sh '''
                        echo "=== Checking Required Tools ==="
                        git --version || { echo "Git missing"; exit 1; }
                        docker --version || { echo "Docker missing"; exit 1; }
                        kubectl version --client --short || { echo "kubectl missing"; exit 1; }
                    '''
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG')]) {
                    script {
                        sh '''
                            export KUBECONFIG=$KUBECONFIG
                            kubectl cluster-info
                            kubectl apply -f deployment.yaml
                            kubectl apply -f service.yaml
                            kubectl rollout status deployment/web-app --timeout=2m
                        '''
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "Pipeline succeeded! Access your app at: http://<node-ip>:30008"
        }
        failure {
            echo "Pipeline failed! Check logs above."
        }
    }
}
