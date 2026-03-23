pipeline {
    agent any
    
    environment {
        // AWS & ECR Configuration
        AWS_ACCOUNT_ID = "845561723983"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "brain-tasks-app"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_URI      = "${ECR_URL}/${ECR_REPO}:latest"
        
        // GitHub Credentials ID from your Jenkins Console
        GITHUB_CRED_ID = "github-cred"
        
        // Build Versioning
        BUILD_TAG      = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                // Ensures a fresh start for every build
                cleanWs()
            }
        }

        stage('Checkout SCM') {
            steps {
                // Pulls the latest code from your main branch
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[url: 'https://github.com/Bibek-2024/brain-tasks-app.git', credentialsId: "${GITHUB_CRED_ID}"]]
                ])
            }
        }

        stage('Install & Build React') {
            steps {
                script {
                    // Prepares the 'dist/' folder required by your Dockerfile
                    sh "npm install"
                    sh "npm run build"
                }
            }
        }

        stage('ECR Login & Docker Build') {
            steps {
                script {
                    // Authenticates Jenkins to push to your private AWS registry
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                    
                    // Builds the image using the freshly created 'dist/' assets
                    sh "docker build --no-cache -t ${ECR_REPO}:latest ."
                }
            }
        }

        stage('Push to AWS ECR') {
            steps {
                script {
                    // Tags the image with both the Build Number and 'latest' for EKS
                    sh "docker tag ${ECR_REPO}:latest ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker tag ${ECR_REPO}:latest ${IMAGE_URI}"
                    
                    // Pushes the images to AWS ECR
                    sh "docker push ${ECR_URL}/${ECR_REPO}:${BUILD_TAG}"
                    sh "docker push ${IMAGE_URI}"
                }
            }
        }

        stage('Cleanup Local Images') {
            steps {
                // Prevents your m7i-flex.large from running out of space
                sh "docker image prune -f"
            }
        }
    }

    post {
        success {
            echo "-----------------------------------------------------------"
            echo "BUILD SUCCESSFUL: Image pushed to ECR."
            echo "AWS CodePipeline will now take over for EKS Deployment."
            echo "-----------------------------------------------------------"
        }
        failure {
            echo "Build failed. Please check the 'ECR Login' or 'Docker Build' stages."
        }
    }
}
