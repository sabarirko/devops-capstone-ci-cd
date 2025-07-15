pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "sabarirko/web-app"
        DOCKER_TAG = "${env.BUILD_ID}"
    }
    
    stages {
        // ===== TOOL VERIFICATION =====
        stage('Verify Tools') {
            steps {
                script {
                    try {
                        sh '''
                            echo "=== Checking Required Tools ==="
                            
                            # Install kubectl if missing
                            if ! command -v kubectl >/dev/null 2>&1; then
                                echo "Installing kubectl..."
                                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                                chmod +x kubectl
                                sudo mv kubectl /usr/local/bin/
                            fi
                            
                            # Verify tools
                            git --version || { echo "Git missing"; exit 1; }
                            docker --version || { echo "Docker missing"; exit 1; }
                            kubectl version --client || { echo "kubectl missing"; exit 1; }
                        '''
                    } catch (Exception e) {
                        error("Tool verification failed: ${e.message}")
                    }
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
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
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
                                docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
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
                                kubectl cluster-info
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
        always {
            echo "Pipeline execution completed"
        }
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
