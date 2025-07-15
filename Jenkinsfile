pipeline {
    agent any
    
    environment {
        // Docker configuration
        DOCKER_IMAGE = "sabarirko/web-app"
        DOCKER_TAG = "${env.BUILD_ID}"
        
        // Kubernetes configuration (using secret text credential)
        KUBECONFIG = credentials('kubeconfig-secret')  // Your credential ID
    }
    
    stages {
        // ===== VERIFICATION STAGE =====
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
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
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
                    sh """
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        // ===== KUBERNETES DEPLOYMENT =====
        stage('Deploy') {
            steps {
                script {
                    // Write kubeconfig to file
                    writeFile file: 'kubeconfig.yaml', text: "${env.KUBECONFIG}"
                    
                    sh '''
                        # Set temporary kubeconfig
                        export KUBECONFIG=kubeconfig.yaml
                        
                        # Verify cluster access
                        kubectl cluster-info
                        kubectl get nodes
                        
                        # Apply manifests
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        
                        # Verify deployment
                        kubectl rollout status deployment/web-app --timeout=2m
                        kubectl get svc -o wide
                    '''
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup
            sh 'rm -f kubeconfig.yaml || true'
            cleanWs()
        }
        success {
            echo "Pipeline succeeded! Access your app at: http://<node-ip>:30008"
        }
        failure {
            echo "Pipeline failed! Check logs above."
        }
    }
}
