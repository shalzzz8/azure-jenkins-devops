# End-to-End DevOps Project Execution Guide

This guide walks you through every step required to provision Azure infrastructure using Terraform, configure Jenkins CI/CD, set up GitHub automated triggers, and continuously deploy the containerized web app to Azure.

---

## Part 1: Provision Infrastructure on Azure using Terraform

### 1. Prerequisites
- **Azure CLI**: Install Azure CLI (`az`) or run via Azure Cloud Shell / PowerShell.
- **Terraform CLI**: Terraform >= 1.5.0 installed.
- **SSH Key Pair**: If you don't have one, generate it:
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
  ```

### 2. Log in to Azure
```bash
az login
# (Optional) Verify your active subscription
az account show --output table
```

### 3. Initialize & Apply Terraform Configuration
Navigate to the `terraform/` folder:
```bash
cd terraform
```

Review or customize `terraform.tfvars`:
```bash
cp terraform.tfvars.example terraform.tfvars
```
*(Make sure `ssh_public_key_path` points to your public key, typically `~/.ssh/id_rsa.pub` on Linux/macOS or `C:/Users/<Username>/.ssh/id_rsa.pub` on Windows).*

Initialize Terraform providers:
```bash
terraform init
```

Preview the infrastructure to be created:
```bash
terraform plan
```
This will plan the creation of:
1. `azurerm_resource_group`: Resource Group (`rg-devops-cicd-prod`)
2. `azurerm_virtual_network`: VNet (`10.0.0.0/16`)
3. `azurerm_subnet`: Subnet (`10.0.1.0/24`)
4. `azurerm_public_ip`: Static Public IP for VM
5. `azurerm_network_security_group`: NSG with ports 22 (SSH), 80 (HTTP), 3000 (App), 8080 (Jenkins)
6. `azurerm_network_interface`: NIC binding public IP and subnet
7. `azurerm_linux_virtual_machine`: Ubuntu 22.04 VM with automated cloud-init Docker installation

Apply the configuration:
```bash
terraform apply -auto-approve
```

Save the output values:
- `public_ip_address` (e.g., `20.120.45.67`)
- `ssh_connection_command` (e.g., `ssh azureuser@20.120.45.67`)

Test SSH connectivity to the new Azure VM:
```bash
ssh azureuser@<YOUR_PUBLIC_IP>
```
Verify Docker was installed automatically by cloud-init:
```bash
docker --version
docker ps
exit
```

---

## Part 2: Push Project to GitHub

1. Create a new GitHub repository (e.g. `azure-jenkins-devops`).
2. In your local project directory:
   ```bash
   git init
   git add .
   git commit -m "feat: initial commit with Terraform, Node.js app and Jenkinsfile"
   git branch -M main
   git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/azure-jenkins-devops.git
   git push -u origin main
   ```

---

## Part 3: Set Up Jenkins CI/CD

You can run Jenkins on your local machine using Docker or inside an Azure VM.

### Option A: Running Jenkins via Docker (Recommended for simplicity)
Navigate to `jenkins/`:
```bash
cd jenkins
docker compose up -d
```
1. Open your browser at `http://localhost:8080`.
2. Retrieve the initial admin password:
   ```bash
   docker exec -it jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Follow the setup wizard:
   - Click **Install suggested plugins**.
   - Create your Admin User.

### Option B: Required Jenkins Plugins
Go to **Manage Jenkins** -> **Plugins** -> **Available plugins**, install:
- **SSH Agent Plugin** (`ssh-agent`)
- **GitHub Integration Plugin**
- **Pipeline** (included by default)

Restart Jenkins if prompted.

### Option C: Configure Jenkins Credentials
Go to **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials (unrestricted)** -> **+ Add Credentials**:

1. **Azure VM SSH Private Key**:
   - **Kind**: `SSH Username with private key`
   - **ID**: `azure-vm-ssh-key` (Must match the ID in `Jenkinsfile`)
   - **Username**: `azureuser`
   - **Private Key**: Select `Enter directly` -> Paste the contents of your private key file (`~/.ssh/id_rsa`).
   - Click **Create**.

2. **Azure VM Public IP Secret**:
   - **Kind**: `Secret text`
   - **ID**: `AZURE_VM_PUBLIC_IP`
   - **Secret**: `<YOUR_AZURE_VM_PUBLIC_IP>` (from `terraform output public_ip_address`)
   - Click **Create**.

---

## Part 4: Create the Jenkins Pipeline Job

1. On the Jenkins dashboard, click **New Item**.
2. Enter item name: `azure-cicd-pipeline`.
3. Select **Pipeline** and click **OK**.
4. Scroll down to **Build Triggers**:
   - Check **GitHub hook trigger for GITScm polling** (for Webhooks).
   - *(Optional Fallback)* Check **Poll SCM** and enter `H/2 * * * *` (polls GitHub every 2 minutes if webhooks are unreachable).
5. Scroll down to **Pipeline**:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/<YOUR_GITHUB_USERNAME>/azure-jenkins-devops.git`
   - **Branch Specifier**: `*/main`
   - **Script Path**: `jenkins/Jenkinsfile`
6. Click **Save**.

---

## Part 5: Integrate GitHub Webhooks

1. Go to your GitHub repository on github.com.
2. Click **Settings** -> **Webhooks** -> **Add webhook**.
3. **Payload URL**:
   - If Jenkins is hosted on a public IP: `http://<JENKINS_PUBLIC_IP>:8080/github-webhook/`
   - If Jenkins is running locally, use a tunnel like `ngrok http 8080` or smee.io to get a public URL:
     `https://<your-subdomain>.ngrok-free.app/github-webhook/`
4. **Content type**: `application/json`
5. **Which events would you like to trigger this webhook?**: `Just the push event`.
6. Click **Add webhook**.

---

## Part 6: Test Continuous Deployment

1. Make a small code change in `app/public/index.html` (for example, edit the subtitle or bump version in `app/package.json` to `1.1.0`).
2. Commit and push:
   ```bash
   git add .
   git commit -m "chore: bump version to 1.1.0"
   git push origin main
   ```
3. Watch Jenkins:
   - Jenkins immediately detects the push and starts the pipeline.
   - Stage 1: Checkout Git code.
   - Stage 2: Runs unit tests (`npm test`).
   - Stage 3: Packages application tarball.
   - Stage 4: SSHs into Azure VM and runs `deploy.sh` to build & deploy the Docker container.
   - Stage 5: Runs smoke test probe against `http://<AZURE_VM_PUBLIC_IP>/health`.
4. Open `http://<AZURE_VM_PUBLIC_IP>` in your browser to view your live deployed DevOps dashboard!

---

## Part 7: Teardown & Clean Up (Avoid Unwanted Cloud Costs)

When finished testing or demonstrating the project:
```bash
cd terraform
terraform destroy -auto-approve
```
This tears down all Azure resources cleanly (VM, NIC, IP, VNet, Subnet, NSG, Resource Group).
