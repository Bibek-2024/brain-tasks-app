pipeline {
    agent any
    
    environment {
        // AWS & ECR Configuration
        AWS_ACCOUNT_ID = "845561723983"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "brain-tasks-app"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI      = "${ECR_URL}/${ECR_REPO}:latest"
        
        // Port Mapping: External 80 -> Internal 3000
        HOST_PORT      = "80"
        CONTAINER_PORT = "3000"
        
        // Credentials ID from your Jenkins Console
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
                // Pulls code using your stored 'github-cred'
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

        stage('Build & Push Image') {
            steps {
                script {
                    // Builds using the 'dist/' folder logic in your Dockerfile
                    sh "docker build --no-cache -t ${ECR_REPO}:latest ."
                    
                    // Tag and Push
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
                    echo "Stopping any existing container on Port ${HOST_PORT}..."
                    // This block prevents the 'Port already allocated' error
                    sh """
                        CONTAINER_ID=\$(docker ps -q --filter "publish=${HOST_PORT}")
                        if [ ! -z "\$CONTAINER_ID" ]; then
                            docker stop \$CONTAINER_ID || true
                            docker rm \$CONTAINER_ID || true
                        fi
                        docker stop brain-app-test || true
                        docker rm brain-app-test || true
                    """
                    
                    echo "Deploying new version to Port ${HOST_PORT}..."
                    sh "docker run -d --restart unless-stopped --name brain-app-test -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_URI}"
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "Waiting for container to start..."
                    sleep 10
                    // Verifies the app is actually reachable on Port 80
                    sh "curl -f http://localhost/health"
                }
            }
        }

        stage('ECR Retention') {
            steps {
                script {
                    sh "docker image prune -f"
                    // Keeps ECR clean (last 2 images only)
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
            echo "SUCCESS: Build #${BUILD_TAG} is LIVE"
            echo "Access here: http://your-ec2-public-ip"
            echo "-----------------------------------------------------------"
        }
        failure {
            echo "Build failed. Check the console logs for syntax or permission errors."
        }
    }
}
