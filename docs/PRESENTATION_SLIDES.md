# PRESENTATION SLIDES & SPEAKER NOTES
## Automated Cloud Infrastructure Provisioning and Continuous Deployment (CI/CD) Pipeline

---

### **Slide 1: Title Slide**
- **Slide Title**: Automated Cloud Infrastructure Provisioning & CI/CD Pipeline
- **Subtitle**: End-to-End DevOps Implementation using Terraform, Microsoft Azure, Jenkins, Docker, and GitHub
- **Presenter Info**:
  - Name: [Your Name]
  - Roll No / Register ID: [Your ID]
  - Department: [Computer Science / Information Technology]
  - Institution: [Your College / University Name]
- **Visuals**: Logo icons for Terraform, Microsoft Azure, Jenkins, Docker, and GitHub.
- **Speaker Notes**:
  > *"Good morning/afternoon respected professors and evaluators. Today, I am presenting my DevOps project: an End-to-End Continuous Integration and Continuous Deployment pipeline where all cloud infrastructure is codified using Terraform on Microsoft Azure, and application delivery is completely automated with Jenkins and Docker."*

---

### **Slide 2: Problem Statement & Motivation**
- **Slide Title**: Problem Statement & The Need for DevOps
- **Bullet Points**:
  - **Manual Provisioning**: Clicking in cloud consoles leads to configuration drift, human mistakes, and slow deployments.
  - **"It Works on My Machine"**: Environment mismatches between developer machines and production servers cause release crashes.
  - **Slow Delivery Cycles**: Manual testing and deployment create bottlenecks, delaying features and critical bug fixes.
  - **The DevOps Solution**: Replace manual steps with **Infrastructure as Code (IaC)**, **Containerization**, and an automated **CI/CD Pipeline**.
- **Visuals**: Comparison graphic showing "Manual Lifecycle (Slow, Error-prone)" vs. "DevOps Lifecycle (Automated, Fast, Reliable)".
- **Speaker Notes**:
  > *"Traditionally, deploying software required manual server setup, manual dependency installation, and manual deployments. This often causes downtime and human error. Our goal was to build a system where developers simply push code to GitHub, and the infrastructure, tests, and deployment happen automatically with zero manual effort."*

---

### **Slide 3: Project Objectives**
- **Slide Title**: Core Project Objectives
- **Bullet Points**:
  - **1. Infrastructure as Code (IaC)**: Automate creation of cloud resources on Microsoft Azure using Terraform.
  - **2. Version Control Integration**: Host configuration and application code on GitHub with automated triggers.
  - **3. Continuous Integration (CI)**: Automatically build and execute unit tests in Jenkins upon code commit.
  - **4. Containerized Packaging**: Package the application into an isolated, lightweight Docker container.
  - **5. Continuous Deployment (CD)**: Automatically deploy and expose the new container on Azure with post-deployment health probes.
- **Visuals**: Checkmark badges highlighting the 5 key pillars.
- **Speaker Notes**:
  > *"We established five clear goals: provision all Azure infrastructure using Terraform code, package the application in Docker, write automated tests, build an automated Jenkins pipeline, and achieve true continuous deployment without manual intervention."*

---

### **Slide 4: System Architecture & Workflow**
- **Slide Title**: High-Level System Architecture
- **Bullet Points**:
  - **Developer Push**: Code commit pushed to GitHub repository (`shalzzz8/azure-jenkins-devops`).
  - **Automated SCM Trigger**: Jenkins polls GitHub every 2 minutes (`H/2 * * * *`).
  - **CI Phase**: Jenkins pulls code and executes `npm test` unit tests.
  - **CD Phase**: Jenkins builds the Docker image and recreates the container on Port 80.
  - **Smoke Test**: Automated cURL probe tests the `/health` endpoint before release completion.
  - **Live Access**: End users access the production web application on Azure Public IP `9.205.24.219:80`.
- **Visuals**: Architecture diagram showing Developer ➔ GitHub ➔ Jenkins ➔ Docker ➔ Azure VM.
- **Speaker Notes**:
  > *"This diagram represents the entire architecture. When a developer pushes code to GitHub, Jenkins detects the commit, runs automated unit tests, builds a fresh Docker image, deploys it to Port 80 on the Azure Linux VM, and validates the health endpoint."*

---

### **Slide 5: Infrastructure as Code (Terraform on Azure)**
- **Slide Title**: Cloud Provisioning with Terraform
- **Bullet Points**:
  - **Declarative HCL**: All infrastructure defined in version-controlled `.tf` files.
  - **Resources Created in Azure (`denmarkeast`)**:
    - Resource Group (`rg-devops-denmark`)
    - Virtual Network (`10.0.0.0/16`) & Subnet (`10.0.1.0/24`)
    - Network Security Group (Firewall rules for Ports 22, 80, 8080, 3000)
    - Static Public IP (`9.205.24.219`) & Network Interface (NIC)
    - Ubuntu 22.04 LTS Virtual Machine (`Standard_B1s`)
  - **Cloud-Init Automation**: Shell script pre-installs Docker Engine during the first VM boot.
- **Visuals**: Terraform code snippet from `main.tf` and Azure resource topology diagram.
- **Speaker Notes**:
  > *"Instead of creating resources manually in the Azure portal, we used Terraform. With a single 'terraform apply' command, Azure provisions the resource group, network, firewall rules, and virtual machine. Furthermore, we used cloud-init automation to ensure Docker was pre-installed the moment the VM started."*

---

### **Slide 6: Application Development & Containerization**
- **Slide Title**: Application & Docker Packaging
- **Bullet Points**:
  - **Full-Stack Application**: Node.js & Express web application with a responsive glassmorphic UI.
  - **Telemetry Endpoints**:
    - `/health`: Health status payload (`status: "UP"`, uptime, container hostname).
    - `/api/info`: Live server metrics (OS, CPU count, free RAM, cloud metadata).
  - **Docker Best Practices**:
    - Multi-stage build based on lightweight `node:20-alpine`.
    - Non-root user execution (`USER node`) for enterprise security.
    - Minimal image size with production dependency pruning (`npm ci --only=production`).
- **Visuals**: Screenshot of the live Web Dashboard and Dockerfile snippet.
- **Speaker Notes**:
  > *"The application is a Node.js Express service featuring a live DevOps telemetry dashboard. It exposes a '/health' endpoint used by Jenkins to verify deployment status. We packaged it into a secure, lightweight Docker container using node:20-alpine, running under a non-root user for security."*

---

### **Slide 7: Continuous Integration & Automated Testing**
- **Slide Title**: CI Stage: Automated Unit Testing
- **Bullet Points**:
  - **Test Suite**: Built using Node.js standard test runner (`node:test` and `node:assert`).
  - **Validation Targets**:
    - Test 1: Verifies `/health` returns HTTP 200 and `{ status: "UP" }`.
    - Test 2: Verifies `/api/info` returns correct Azure and Terraform metadata.
  - **Fail-Safe Mechanism**:
    - If any unit test fails, Jenkins immediately aborts the pipeline.
    - Broken code is prevented from reaching production.
- **Visuals**: Screenshot of Jenkins test execution log showing `1..2 # pass 2, # fail 0`.
- **Speaker Notes**:
  > *"Quality assurance is automated within the pipeline. Before any container is built, Jenkins runs unit tests. If a developer introduces broken code, the test fails, Jenkins aborts the pipeline, and the faulty code is blocked from ever reaching the production server."*

---

### **Slide 8: Continuous Deployment Pipeline (Jenkins)**
- **Slide Title**: Declarative Jenkins Pipeline Stages
- **Bullet Points**:
  - **Stage 1: Checkout Source**: Clones latest commit from GitHub repository.
  - **Stage 2: Test & Validate (CI)**: Runs `npm install` and executes `npm test`.
  - **Stage 3: Build Docker Container**: Compiles `devops-cicd-app:latest` container image.
  - **Stage 4: Deploy to Azure VM (CD)**: Stops previous container and launches new container on Port 80.
  - **Stage 5: Smoke Test & Health Probe**: Pings `/health` to confirm the app is responsive.
- **Visuals**: Jenkins Stage View showing all 5 stages in green checkmarks.
- **Speaker Notes**:
  > *"Our Jenkinsfile defines five declarative stages. It checks out the code, executes tests, builds the Docker image, deploys the container to Port 80, and runs a smoke test probe. In our test run, Build #3 passed every stage seamlessly."*

---

### **Slide 9: Engineering Challenges Solved**
- **Slide Title**: Technical Challenges & Solutions
- **Bullet Points**:
  - **1. Azure Region Capacity Restrictions**:
    - *Problem*: `SkuNotAvailable` error on B-series VMs in US East data centers.
    - *Solution*: Queried Azure CLI (`az vm list-skus`) to discover unrestricted capacity in `denmarkeast`.
  - **2. Docker Container Localhost Isolation**:
    - *Problem*: `curl http://localhost:80` failed inside Jenkins container.
    - *Solution*: Dynamically queried the container's bridge IP using `docker inspect` for the health probe.
  - **3. Git Identity Conflict**:
    - *Problem*: Windows Credential Manager cached an outdated GitHub user.
    - *Solution*: Flushed stored credentials and explicitly bound the Git remote URL to `shalzzz8`.
- **Visuals**: Problem-Solution summary table.
- **Speaker Notes**:
  > *"During development, we solved real-world engineering issues. When Azure's East US data centers had capacity constraints, we used the Azure CLI to query available regions and migrated to Denmark East. We also solved Docker container network isolation during health probes by inspecting container bridge IPs."*

---

### **Slide 10: Results & Verification**
- **Slide Title**: Project Results & Live Verification
- **Bullet Points**:
  - **Live Application URL**: `http://9.205.24.219:80` (Active and publicly accessible).
  - **Jenkins CI/CD Server**: `http://9.205.24.219:8080`.
  - **Automated SCM Trigger Proof**: Build #3 triggered automatically with status `"Started by an SCM change"`.
  - **Zero Downtime**: Container replacement executed in under 3 seconds.
  - **Cost Efficiency**: Entire project executed well within the Azure Free Tier (<$0.50 used).
- **Visuals**: Side-by-side screenshots: Jenkins Build #3 Success badge + Live Web Dashboard.
- **Speaker Notes**:
  > *"Here are the project results. The application is running live at our Azure public IP address. In Jenkins Build #3, you can see that the build was triggered automatically by an SCM change when code was pushed to GitHub, demonstrating true continuous deployment."*

---

### **Slide 11: Future Enhancements**
- **Slide Title**: Future Roadmap & Scaling
- **Bullet Points**:
  - **Kubernetes Orchestration**: Migrate from single-VM Docker to Azure Kubernetes Service (AKS) for horizontal auto-scaling and self-healing.
  - **Observability**: Implement Prometheus and Grafana for metrics monitoring and alerting.
  - **Security**: Integrate Azure Key Vault to manage sensitive secrets and API tokens.
  - **HTTPS & SSL/TLS**: Configure an NGINX reverse proxy with automated Let's Encrypt certificates.
- **Visuals**: Diagram showing future evolution to Kubernetes (AKS) and Prometheus/Grafana.
- **Speaker Notes**:
  > *"As for future work, we plan to migrate from single-host Docker to Azure Kubernetes Service (AKS) for container orchestration, integrate Prometheus and Grafana for observability, and configure Let's Encrypt SSL certificates for HTTPS encryption."*

---

### **Slide 12: Conclusion & Q&A**
- **Slide Title**: Conclusion & Questions
- **Bullet Points**:
  - **Key Achievements**:
    - ✅ 100% Automated Infrastructure as Code via Terraform.
    - ✅ Automated Continuous Integration with unit tests.
    - ✅ Hands-free Continuous Deployment on Microsoft Azure via Jenkins.
    - ✅ Secure, reproducible Docker containerization.
  - **GitHub Repository**: `https://github.com/shalzzz8/azure-jenkins-devops`
  - **Thank You! Open for Questions.**
- **Visuals**: Project summary badge and Q&A prompt.
- **Speaker Notes**:
  > *"In conclusion, this project demonstrates a complete, modern DevOps engineering lifecycle from code push to cloud deployment. Thank you for your time and attention. I am now open to any questions!"*
