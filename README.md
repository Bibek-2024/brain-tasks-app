# <p align="center">🧠 Brain Tasks: Managed Cloud-Native DevOps Project</p>

<p align="center">
<img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" />
<img src="https://img.shields.io/badge/CodePipeline-FF9900?style=for-the-badge&logo=awscodepipeline&logoColor=white" />
<img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white" />
<img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" />
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
<img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
<img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
</p>

<p align="center">
  <strong>Orchestrating a Professional CI/CD Lifecycle using AWS CodePipeline, Jenkins, and EKS for High-Availability Applications.</strong>
</p>

---

## 📌 Table of Contents
* [Overview](#-overview)
* [Tools & Technologies](#-tools--technologies)
* [Project Structure](#-project-structure)
* [Pipeline Architecture](#-pipeline-architecture)
* [Monitoring & Alerting](#-monitoring--alerting)
* [How to Run This Project](#-how-to-run-this-project)
* [Author & Contact](#-author--contact)

---

## 📖 Overview
This project showcases a hybrid **DevOps Ecosystem** for the "Brain Tasks" application. It transitions from a standard Jenkins flow to a managed **AWS CodePipeline** orchestrator. By leveraging **Jenkins** as a specialized build provider and **Amazon EKS** as the runtime, the project achieves enterprise-grade deployment reliability and real-time observability.

---

## 🛠 Tools & Technologies

| Category | Tools Used |
| :--- | :--- |
| **Orchestration** | AWS CodePipeline |
| **Continuous Integration** | Jenkins (Pipeline Item), GitHub Webhooks |
| **Containerization** | Docker (Multi-stage), Amazon ECR |
| **Cloud Runtime** | Amazon EKS (Kubernetes) |
| **Web Server** | Nginx (Port 80) |
| **Observability** | Prometheus, Grafana, Blackbox Exporter |

---

## 📂 Project Structure

Below is the local directory structure of the `brain-tasks-app` repository:

```text
.
├── Dockerfile           # Multi-stage Docker build (Nginx-based)
├── Jenkinsfile          # Jenkins Pipeline definition
├── README.md            # Project documentation
├── buildspec.yml        # AWS CodeBuild / Pipeline configuration
├── default.conf         # Custom Nginx configuration (Port 80)
├── deployment.yaml      # K8s Deployment manifest
├── service.yaml         # K8s LoadBalancer manifest
├── dist/                # Production-ready application assets
│   ├── assets/          # Optimized static JS/CSS
│   └── index.html       # Application entry point
├── images/              # Documentation assets & screenshots
│   └── Brain tasks DevOps architecture diagram.png
└── .dockerignore        # Build optimization
```

---

## 🏗️ Pipeline Architecture

The workflow implements a Manager-Worker model. AWS CodePipeline manages the lifecycle, while Jenkins handles the heavy lifting of Docker builds.

<p align="center">
  <img src="images/Brain%20tasks%20DevOps%20architecture%20diagram.png" alt="Architecture Diagram" width="850">
</p>

### **🚀 CI/CD Execution Flow**

> **Developer Push ➔ GitHub Webhook ➔ AWS CodePipeline ➔ Jenkins Build ➔ Amazon ECR ➔ AWS EKS Deploy**

---

---

## 📊 Monitoring & Alerting

We implemented a proactive "Watchdog" strategy using the Prometheus Operator stack:

* **Uptime Tracking:** Prometheus Blackbox Exporter probes the EKS LoadBalancer endpoint.
* **Alerting:** Configured Gmail SMTP via Grafana for instant 🚨 [FIRING] notifications if pods drop below 1.
* **Dashboards:** Real-time visualization of CPU, Memory, and Network traffic in Grafana.
* **Visual Dashboards:** Real-time Grafana tracking for Site Status (Online/Offline), Latency, and Pod CPU/Memory.

---

## ⚙️ How to Run This Project

### 1. Clone & Initialize

```bash
git clone [https://github.com/Bibek-2024/brain-tasks-app.git](https://github.com/Bibek-2024/brain-tasks-app.git)
cd brain-tasks-app

```
### 2. Initialize Jenkins

Create a jenkis pipeline item named exactly as referenced in your Pipeline.

Configure the Build Trigger to poll AWS CodePipeline.

---

### 3. Deploy Stack

```bash
# The Jenkins pipeline handles this automatically, but you can manually trigger:
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

```
---

### 4. Verification

```bash
# Verify pods are running on Port 80
kubectl get pods -n monitoring
kubectl get svc

```
---

## 👤 Author & Contact

### **Bibek Kumar Sahu**

*Aspiring DevOps & Cloud Infrastructure Engineer*

📫 **Email:** [bibekkumarsahu2011@gmail.com](mailto:bibekkumarsahu2011@gmail.com)
🔗 **LinkedIn:** [bibekkumarsahu](https://www.linkedin.com/in/bibekkumarsahu/)
📁 **GitHub:** [Bibek-2024](https://github.com/Bibek-2024/brain-tasks-app.git)

---
