Modified Project Architecture Diagram
Breakdown of the Architectural Flow
Source Control & Webhook: The developer pushes code to GitHub. This change automatically triggers a Webhook, which notifies AWS CodePipeline to start.

AWS CodePipeline (The Manager): CodePipeline starts the run. Its first action is to contact your Jenkins server (which is polling the pipeline for new jobs).

Jenkins Build Stage (The Worker):

Jenkins (using your new Freestyle project with the CodePipeline plugin) downloads the source artifact.

It builds the Docker image and pushes it to your Amazon ECR repository.

Once done, Jenkins sends a "Success" signal back to CodePipeline.

AWS CodePipeline (The Deployer): CodePipeline receives the success signal. It uses the native EKS Deploy Action (not a kubectl command from Jenkins) to update your Kubernetes cluster's deployment.yaml with the new image tag.

Amazon EKS (The Runtime): Your Brain Tasks app runs on Nginx (mapped to Port 80). EKS handles the rolling update to ensure zero-downtime.

The Monitoring Layer (The Watchdog):

Prometheus (using the Blackbox Exporter) continues probing your public Load Balancer URL.

Grafana reads this data to show you the green "ONLINE" status on your custom "Brain Tasks" dashboard.

If the probe returns a 0 (Offline), an alert is triggered in Grafana.

Gmail SMTP then automatically sends you a notification.
