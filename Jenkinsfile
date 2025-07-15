pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "sabarirko/web-app"
        DOCKER_TAG = "${env.BUILD_ID}"
        DOCKER_BUILDKIT = "1"  # Enable BuildKit
    }
    
    stages {
        // ===== TOOL SETUP =====
        stage('Setup Environment') {
            steps {
                script {
                    sh '''
                        echo "=== Configuring Docker ==="
                        docker --version
                        docker buildx version || docker buildx install
                    '''
                }
            }
        }

        // ===== CHECKOUT CODE =====
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // ===== BUILD DOCKER IMAGE =====
        stage('Build') {
            steps {
                script {
                    try {
                        sh """
                            docker buildx build \
                              -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                              -t ${DOCKER_IMAGE}:latest \
                              --platform linux/amd64 \
                              --load .
                        """
                    } catch (Exception e) {
                        error("Docker build failed: ${e.message}")
                    }
                }
            }
        }

        // ===== PUSH TO DOCKER HUB =====
        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    script {
                        try {
                            sh """
                                docker login -u $DOCKER_USER -p $DOCKER_PASS
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                                docker push ${DOCKER_IMAGE}:latest
                            """
                        } catch (Exception e) {
                            error("Docker push failed: ${e.message}")
                        }
                    }
                }
            }
        }

        // ===== KUBERNETES DEPLOYMENT =====
        stage('Deploy') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG')]) {
                    script {
                        try {
                            sh '''
                                export KUBECONFIG=${KUBECONFIG}
                                kubectl apply -f deployment.yaml
                                kubectl apply -f service.yaml
                                kubectl rollout status deployment/web-app --timeout=2m
                            '''
                        } catch (Exception e) {
                            error("Kubernetes deployment failed: ${e.message}")
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "SUCCESS: App deployed to Kubernetes!"
            sh '''
                export KUBECONFIG=${KUBECONFIG}
                echo "Access your app at: http://$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}'):30008"
            '''
        }
        failure {
            echo "FAILURE: Check pipeline logs for errors"
        }
    }
}
