pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = "845561723983"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "brain-tasks-app"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI      = "${ECR_URL}/${ECR_REPO}:latest"
        CLUSTER_NAME   = "brain-tasks-cluster"
        GITHUB_CRED_ID = "github-cred"
    }

    stages {
        stage('Cleanup & Checkout') {
            steps {
                cleanWs()
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[url: 'https://github.com/Bibek-2024/brain-tasks-app.git', credentialsId: "${GITHUB_CRED_ID}"]]
                ])
            }
        }

        stage('ECR Login & Docker Build') {
            steps {
                script {
                    // Authenticate with AWS ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                    
                    // Build the image using the existing 'dist/' folder as specified in your Dockerfile
                    sh "docker build --no-cache -t ${IMAGE_URI} ."
                }
            }
        }

        stage('Push to AWS ECR') {
            steps {
                script {
                    // Push the 'latest' image for EKS to pull
                    sh "docker push ${IMAGE_URI}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // Point kubectl to your active EKS cluster
                    sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
                    
                    // Apply Kubernetes manifests
                    sh "kubectl apply -f deployment.yaml"
                    sh "kubectl apply -f service.yaml"
                    
                    // Force EKS to refresh the pods with the new image
                    sh "kubectl rollout restart deployment/brain-app"
                }
            }
        }

        stage('Cleanup Local Images') {
            steps {
                // Keep the EC2 storage clean
                sh "docker image prune -f"
            }
        }
    }

    post {
        success {
            echo "-----------------------------------------------------------"
            echo "DEPLOYMENT SUCCESSFUL!"
            echo "Run 'kubectl get svc brain-service' on your EC2 to get the URL."
            echo "-----------------------------------------------------------"
        }
        failure {
            echo "Build or Deployment failed. Check ECR permissions or EKS connectivity."
        }
    }
}
