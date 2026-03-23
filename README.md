# 🧠 Brain Tasks: End-to-End DevOps Pipeline
> **Aspiring DevOps & Cloud Infrastructure Project**
> A robust CI/CD and Monitoring solution leveraging AWS Managed Services, Jenkins, and Kubernetes.

---

## 📊 Project Overview
This project demonstrates a professional-grade hybrid CI/CD architecture. It automates the lifecycle of a containerized application from code commit to a high-availability deployment on **Amazon EKS**, featuring real-time observability and automated alerting.

### 🛠 Tech Stack
<p align="center">
  <img src="https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white" />
  <img src="https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/jenkins-%23D33833.svg?style=for-the-badge&logo=jenkins&logoColor=white" />
  <img src="https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white" />
  <img src="https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white" />
</p>

---

## 🏗 System Architecture
The workflow follows a **Manager-Worker** model where **AWS CodePipeline** orchestrates the stages and **Jenkins** performs the specialized build tasks.

```mermaid
graph TD
    %% Define Nodes
    A[Developer Push] -->|Webhook| B(GitHub Repository)
    B --> C{AWS CodePipeline}

    subgraph "Continuous Integration"
    C --> D[Jenkins Freestyle Job]
    D -->|Docker Build| E[Amazon ECR]
    E -->|Success Signal| C
    end

    subgraph "Continuous Deployment"
    C --> F[AWS EKS Deploy Action]
    F -->|Rollout| G[Amazon EKS Cluster]
    end

    subgraph "Real-time Observability"
    G --> H[Nginx Pods :80]
    H --- I[Prometheus + Blackbox]
    I --> J[Grafana Dashboard]
    J -->|SMTP Alert| K[Gmail Notification]
    end

    %% Styling
    style C fill:#f96,stroke:#333,stroke-width:2px
    style G fill:#326ce5,stroke:#fff,stroke-width:2px
    style D fill:#D33833,stroke:#fff,stroke-width:2px
📁 Project Structure
Plaintext
.
├── Dockerfile           # Multi-stage Docker build file
├── Jenkinsfile          # Pipeline-as-Code for CI stages
├── buildspec.yml        # AWS CodeBuild configuration
├── default.conf         # Nginx server configuration
├── deployment.yaml      # Kubernetes Deployment manifest
├── service.yaml         # Kubernetes Service (LoadBalancer) manifest
├── dist/                # Compiled application assets
└── images/              # Project documentation assets
    └── architecture.png
🚀 Key Features
1. Hybrid CI/CD Pipeline
Orchestration: Managed by AWS CodePipeline for enterprise reliability.

Build Specialist: Jenkins handles Docker image creation and ECR pushes.

Native Deployment: Automated manifest updates via EKS-native actions.

2. High-Availability Runtime
Nginx Optimized: Serves static assets on Port 80 with a custom configuration.

Scalable: Hosted on Amazon EKS with automated load balancing.

3. Monitoring & Alerting
Probing: Prometheus Blackbox verifies endpoint health every 15s.

Visuals: Custom Grafana dashboard for CPU, Memory, and Latency.

Alerting: Automated Gmail SMTP notifications for downtime and recovery.

👨‍💻 Author
Bibek Kumar Sahu Aspiring DevOps & Cloud Infrastructure Engineer LinkedIn | GitHub
