pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sabarirko/web-app"
        DOCKER_TAG = "${env.BUILD_ID}"
        DOCKER_BUILDKIT = "0" // Disable BuildKit to avoid buildx error
    }

    stages {
        stage('Verify Tools') {
            steps {
                script {
                    sh '''
                        echo "=== Docker Version Check ==="
                        docker --version
                        git --version
                        kubectl version --client=true
                    '''
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        sh """
                            docker build \
                              -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                              -t ${DOCKER_IMAGE}:latest \
                              .
                        """
                    } catch (Exception e) {
                        error("❌ Docker build failed: ${e.message}")
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    script {
                        try {
                            sh """
                                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                                docker push ${DOCKER_IMAGE}:latest
                            """
                        } catch (Exception e) {
                            error("❌ Docker push failed: ${e.message}")
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG')]) {
                    script {
                        try {
                            sh """
                                export KUBECONFIG=${KUBECONFIG}
                                kubectl apply -f deployment.yaml
                                kubectl apply -f service.yaml
                                kubectl rollout status deployment/web-app --timeout=2m
                            """
                        } catch (Exception e) {
                            error("❌ Kubernetes deployment failed: ${e.message}")
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ SUCCESS: App deployed to Kubernetes!"
            script {
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    echo "Access your app at: http://\$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}'):30008"
                """
            }
        }
        failure {
            echo "❌ FAILURE: Check pipeline logs for details."
        }
    }
}
