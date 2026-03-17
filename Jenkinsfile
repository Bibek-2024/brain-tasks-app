pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "845561723983"
        AWS_DEFAULT_REGION = "ap-south-1"
        ECR_REPO = "brain-tasks-app"
        CLUSTER_NAME = "brain-cluster"
        IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:latest"
    }
    stages {
        stage('Docker Build & ECR Push') {
            steps {
                script {
                    // Login, Build, and Push in one block
                    sh """
                    aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
                    docker build -t ${IMAGE_URI} .
                    docker push ${IMAGE_URI}
                    """
                }
            }
        }
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
    }
}
