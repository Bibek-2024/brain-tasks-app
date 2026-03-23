pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "845561723983"
        AWS_DEFAULT_REGION = "ap-south-1"
        ECR_REPO = "brain-tasks-app"
        CLUSTER_NAME = "brain-cluster"
        IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:latest"
        BUILD_TAG = "${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Docker Build & ECR Push') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
                    docker build --no-cache -t ${IMAGE_URI} -t ${ECR_REPO}:${BUILD_TAG} .
                    docker tag ${ECR_REPO}:${BUILD_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:${BUILD_TAG}
                    docker push ${IMAGE_URI}
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:${BUILD_TAG}
                    """
                }
            }
        }

        stage('Local EC2 Deploy (For Testing)') {
            steps {
                script {
                    echo "Deploying brain-tasks-app locally for validation..."
                    sh """
                    docker stop brain-app-test || true
                    docker rm brain-app-test || true
                    docker run -d --restart unless-stopped --name brain-app-test -p 80:80 ${IMAGE_URI}
                    """
                }
            }
        }

        // KEEP THIS COMMENTED OUT UNTIL YOUR EKS CLUSTER IS LIVE
        /*
        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                    aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_DEFAULT_REGION}
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    kubectl rollout restart deployment/brain-app
                    """
                }
            }
        }
        */

        stage('Cleanup') {
            steps {
                script {
                    sh "docker image prune -f"
                    // Keep last 2 images in ECR
                    sh """
                    IMAGES_TO_DELETE=\$(aws ecr describe-images --repository-name ${ECR_REPO} --query 'imageDetails[?imageTags!=null] | sort_by(@, &imagePushedAt) | [:-2].imageDigest' --output text)
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
