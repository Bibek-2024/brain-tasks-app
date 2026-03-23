# 🧠 Brain Tasks: End-to-End DevOps Pipeline
> **Aspiring DevOps & Cloud Infrastructure Project**
> A robust CI/CD and Monitoring solution leveraging AWS Managed Services, Jenkins, and Kubernetes.

---

## 📊 Project Overview
This project demonstrates a professional-grade hybrid CI/CD architecture. It automates the lifecycle of a containerized application from code commit to a high-availability deployment on **Amazon EKS**, featuring real-time observability and automated alerting.

### 🛠 Tech Stack
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%23D33833.svg?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)

---

## 🏗 System Architecture
The workflow follows a "Manager-Worker" model where **AWS CodePipeline** orchestrates the stages and **Jenkins** performs the specialized build tasks.

```mermaid
graph LR
    A[Developer Push] -->|Webhook| B[GitHub]
    B --> C[AWS CodePipeline]
    subgraph "CI Stage"
    C --> D[Jenkins Freestyle Job]
    D -->|Docker Build| E[Amazon ECR]
    E -->|Success Signal| C
    end
    subgraph "CD Stage"
    C --> F[AWS CodeDeploy/EKS]
    F -->|Deploy| G[Amazon EKS Cluster]
    end
    subgraph "Observability"
    G --> H[Nginx Pods :80]
    H --- I[Prometheus + Blackbox]
    I --> J[Grafana Dashboard]
    J -->|Alert| K[Gmail SMTP Notification]
    end
📁 Project Structure
Plaintext
.
├── Dockerfile           # Multi-stage Docker build file
├── Jenkinsfile          # Pipeline-as-Code for CI stages
├── README.md            # Project documentation
├── buildspec.yml       # AWS CodeBuild configuration
├── default.conf         # Nginx server configuration
├── deployment.yaml      # Kubernetes Deployment manifest
├── service.yaml         # Kubernetes Service (LoadBalancer) manifest
├── dist/                # Compiled application assets (Vite/JS)
│   ├── assets/          # Static JS and CSS files
│   ├── index.html       # Application entry point
│   └── vite.svg         # App logo
└── images/              # Project documentation assets
    └── Brain tasks DevOps architecture diagram.png
🚀 Key Features
1. Hybrid CI/CD Pipeline
Automated Orchestration: Managed by AWS CodePipeline for high reliability.

Build Specialist: Jenkins (Freestyle) handles Docker image creation and ECR pushes.

Native Deployment: Uses AWS native EKS actions to update cluster manifests via deployment.yaml.

2. High-Availability Runtime
Nginx Optimized: Uses default.conf to serve the dist/ folder on Port 80.

Load Balanced: Exposed via service.yaml using an AWS Classic Load Balancer.

3. Advanced Monitoring & Alerting
Blackbox Probing: Prometheus monitors the external Load Balancer URL.

Site Reliability: Real-time "ONLINE/OFFLINE" status tracking.

Automated Notifications: 📧 Gmail SMTP sends critical alerts if the app is offline and restoration alerts when it's back up.

📸 Dashboard & Architecture
The project architecture is visually documented in the images/ directory:

Architecture Diagram: images/Brain tasks DevOps architecture diagram.png

👨‍💻 Author
Bibek Kumar Sahu Aspiring DevOps & Cloud Infrastructure Engineer LinkedIn | Portfolio
