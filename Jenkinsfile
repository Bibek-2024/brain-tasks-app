pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = "845561723983"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "brain-tasks-app"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI      = "${ECR_URL}/${ECR_REPO}:latest"
        
        HOST_PORT      = "80"
        CONTAINER_PORT = "3000"
        
        GITHUB_CRED_ID = "github-cred"
        BUILD_TAG      = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup Workspace') {
            steps { cleanWs() }
        }

        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[url: 'https://github.com/Bibek-2024/brain-tasks-app.git', credentialsId: "${GITHUB_CRED_ID}"]]
                ])
            }
        }

        stage('ECR Login & Build') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                    sh "docker build --no-cache -t ${ECR_REPO}:latest ."
                }
            }
        }

        stage('Push to AWS ECR') {
            steps {
                script {
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
                    sh """
                        CONTAINER_ID=\$(docker ps -q --filter "publish=${HOST_PORT}")
                        if [ ! -z "\$CONTAINER_ID" ]; then
                            docker stop \$CONTAINER_ID || true
                            docker rm \$CONTAINER_ID || true
                        fi
                        docker stop brain-app-test || true
                        docker rm brain-app-test || true
                        
                        docker run -d --restart unless-stopped --name brain-app-test -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_URI}
                    """
                }
            }
        }

        stage('Verification') {
            steps {
                script {
                    echo "Validating Deployment..."
                    sleep 10
                    sh "curl -s -f http://localhost/health || exit 1"
                }
            }
        }

        stage('Retention') {
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
}
