pipeline {
    agent any
    
    environment {
        // AWS Configuration
        AWS_ACCOUNT_ID = "845561723983"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "brain-tasks-app"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI      = "${ECR_URL}/${ECR_REPO}:latest"
        
        // Port Configuration
        HOST_PORT      = "80"
        CONTAINER_PORT = "3000"
        
        // EKS Configuration (For later)
        CLUSTER_NAME   = "brain-cluster"
        
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
                // Pulls from https://github.com/Bibek-2024/brain-tasks-app.git
                checkout scm
            }
        }

        stage('ECR Login') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Builds using your Dockerfile which copies the 'dist/' folder
                    sh "docker build --no-cache -t ${ECR_REPO}:latest ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Tag with unique Build Number and 'latest'
                    sh "docker tag ${ECR_REPO}:latest ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker tag ${ECR_REPO}:latest ${IMAGE_URI}"
                    
                    // Push both tags to AWS
                    sh "docker push ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker push ${IMAGE_URI}"
                }
            }
        }

        stage('Local EC2 Deploy (3000 to 80)') {
            steps {
                script {
                    echo "Stopping previous app instance..."
                    sh "docker stop brain-app-test || true"
                    sh "docker rm brain-app-test || true"
                    
                    echo "Deploying Brain Tasks App: Internal ${CONTAINER_PORT} -> External ${HOST_PORT}"
                    // Maps Host 80 to Container 3000 and ensures it stays up after reboot
                    sh "docker run -d --restart unless-stopped --name brain-app-test -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_URI}"
                }
            }
        }

        /* UNCOMMENT THIS STAGE ONLY AFTER YOUR EKS CLUSTER IS CREATED
        stage('Deploy to EKS') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}"
                    sh "kubectl apply -f deployment.yaml"
                    sh "kubectl apply -f service.yaml"
                    sh "kubectl rollout restart deployment/brain-app"
                }
            }
        }
        */

        stage('Cleanup & Retention') {
            steps {
                script {
                    echo "Pruning local images..."
                    sh "docker image prune -f"
                    
                    echo "Retaining only last 2 images in ECR..."
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
            echo "SUCCESS: ${ECR_REPO} Build #${BUILD_TAG} is live on Port ${HOST_PORT}"
        }
        failure {
            echo "FAILURE: Check Jenkins console for Docker or AWS permission errors."
        }
    }
}
