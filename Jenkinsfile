pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = "845561723983"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "brain-tasks-app"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI      = "${ECR_URL}/${ECR_REPO}:latest"
        
        // Port Mapping: External 80 -> Internal 3000
        HOST_PORT      = "80"
        CONTAINER_PORT = "3000"
        
        GITHUB_CRED_ID = "github-cred"
        BUILD_TAG      = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup Workspace') {
            steps { cleanWs() }
        }

        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[url: 'https://github.com/Bibek-2024/brain-tasks-app.git', credentialsId: "${GITHUB_CRED_ID}"]]
                ])
            }
        }

        stage('ECR Login') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                }
            }
        }

        stage('Build & Push') {
            steps {
                script {
                    sh "docker build --no-cache -t ${ECR_REPO}:latest ."
                    sh "docker tag ${ECR_REPO}:latest ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker tag ${ECR_REPO}:latest ${IMAGE_URI}"
                    sh "docker push ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker push ${IMAGE_URI}"
                }
            }
        }

        stage('Local EC2 Deploy') {
            steps {
                script {
                    echo "Force clearing Port ${HOST_PORT}..."
                    // Kill any container currently occupying the host port
                    sh """
                        OLD_CONTAINER=\$(docker ps -q --filter "publish=${HOST_PORT}")
                        if [ ! -z "\$OLD_CONTAINER" ]; then
                            docker stop \$OLD_CONTAINER || true
                            docker rm \$OLD_CONTAINER || true
                        fi
                        docker stop brain-app-test || true
                        docker rm brain-app-test || true
                    """
                    
                    echo "Deploying Brain Tasks App..."
                    sh "docker run -d --restart unless-stopped --name brain-app-test -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_URI}"
                }
            }
        }

        stage('Website Health Test') {
            steps {
                script {
                    echo "Waiting for Nginx to initialize..."
                    sleep 5
                    // Test the external accessibility
                    sh "curl -f http://localhost/health"
                }
            }
        }

        stage('ECR Retention') {
            steps {
                script {
                    sh "docker image prune -f"
                    sh """
                        IMAGES_TO_DELETE=\$(aws ecr describe-images --repository-name ${ECR_REPO} \
                        --query 'imageDetails[?imageTags!=null] | sort_by(@, &imagePushedAt) | [:-2].imageDigest' \
                        --output text)
                        
                        if [ ! -z "\$IMAGES_TO_DELETE" ]; then
                            for digest in \$IMAGES_TO_DELETE; do
                                aws ecr batch-delete-image --repository-name ${ECR_REPO} --image-ids imageDigest=\$digest
                            done
                        fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo "-----------------------------------------------------------"
            echo "SUCCESS: Brain Tasks App is LIVE on Port ${HOST_PORT}"
            echo "-----------------------------------------------------------"
        }
        failure {
            echo "DEPLOYMENT FAILED: Check if another service is using Port ${HOST_PORT}"
        }
    }
}pipeline {
    agent any
    
    environment {
        // AWS Configuration based on your Screenshot
        AWS_ACCOUNT_ID = "845561723983"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "brain-tasks-app"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI      = "${ECR_URL}/${ECR_REPO}:latest"
        
        // Port Mapping
        HOST_PORT      = "80"
        CONTAINER_PORT = "3000"
        
        // Credentials IDs from your Jenkins screenshot
        GITHUB_CRED_ID = "github-cred"
        
        // Versioning
        BUILD_TAG      = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                // Uses the credential ID 'github-cred' from your screenshot
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[url: 'https://github.com/Bibek-2024/brain-tasks-app.git', credentialsId: "${GITHUB_CRED_ID}"]]
                ])
            }
        }

        stage('ECR Login') {
            steps {
                script {
                    // Uses the AWS CLI installed on your m7i-flex
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Builds using the pre-built 'dist/' folder in your repo
                    sh "docker build --no-cache -t ${ECR_REPO}:latest ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Dual tagging for version history
                    sh "docker tag ${ECR_REPO}:latest ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker tag ${ECR_REPO}:latest ${IMAGE_URI}"
                    
                    sh "docker push ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker push ${IMAGE_URI}"
                }
            }
        }

        stage('Local EC2 Deploy') {
            steps {
                script {
                    echo "Deploying to local Nginx container..."
                    sh "docker stop brain-app-test || true"
                    sh "docker rm brain-app-test || true"
                    
                    // Maps External 80 to Internal 3000 with reboot protection
                    sh "docker run -d --restart unless-stopped --name brain-app-test -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_URI}"
                }
            }
        }

        stage('ECR Retention') {
            steps {
                script {
                    sh "docker image prune -f"
                    // Retention policy to keep last 2 builds in AWS ECR
                    sh """
                        IMAGES_TO_DELETE=\$(aws ecr describe-images --repository-name ${ECR_REPO} \
                        --query 'imageDetails[?imageTags!=null] | sort_by(@, &imagePushedAt) | [:-2].imageDigest' \
                        --output text)
                        
                        if [ ! -z "\$IMAGES_TO_DELETE" ]; then
                            for digest in \$IMAGES_TO_DELETE; do
                                aws ecr batch-delete-image --repository-name ${ECR_REPO} --image-ids imageDigest=\$digest
                            done
                        fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Build #${BUILD_TAG} is live at http://your-ec2-ip"
        }
    }
}
