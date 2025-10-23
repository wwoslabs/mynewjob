# TruckCo — Azure web server deployment (Terraform + Ansible)

This repository demonstrates an automated, best-practice deployment of a Linux web server on Azure using **Terraform** (infrastructure provisioning) and **Ansible** (configuration management). The server is a starter footprint for a trucking logistics application (TruckCo).

---

## What this repo creates

- Azure Resource Group
- Virtual Network + Subnet
- Network Security Group (NSG)
  - Allow SSH (port 22) **from your IP only** (CIDR).
  - Allow HTTP (port 80) from anywhere.
  - Default Azure NSG inbound deny for other traffic.
- Public static IP
- Network Interface
- Linux VM (Ubuntu LTS)
- Terraform will write an Ansible inventory file with the VM public IP so you can run the Ansible playbook automatically.

Ansible will:
- Update system packages
- Disable root login and password-based SSH auth (enforce key-based)
- Install and enable `nginx`
- Deploy a simple `index.html` to `/var/www/html/`
- Install and configure `ufw` to allow SSH and HTTP only

---

## Repository structure

truckco-azure-deploy/
├─ ansible/
│ ├─ playbook.yml
│ └─ files/index.html
├─ terraform/
│ ├─ main.tf
│ ├─ variables.tf
│ ├─ outputs.tf
│ ├─ providers.tf
│ └─ versions.tf
├─ .gitignore
└─ README.md


---

## Prerequisites

1. **Azure account** with permission to create resources (VMs, networking, IPs, resource groups).
2. **Azure CLI** installed and logged in:

   ```bash
   az login
   az account set --subscription "your-subscription-id-or-name"

3. **Terraform (>= 1.2).**
4. **Ansible (>= 2.9 recommended).**
5. **SSH key pair on your workstation. Example generate:**

    ```bash
    ssh-keygen -t ed25519 -f ~/.ssh/truckco -C "truckco"

    - Public key path: ~/.ssh/truckco.pub
    - Private key path: ~/.ssh/truckco

Terraform will inject the public key into the VM to allow key-based login as the admin user.

How to run
1) Prepare variables

Edit terraform/terraform.tfvars OR pass -var values. A sample terraform/terraform.tfvars.example is provided.

Make sure to set my_ip_cidr to your current public IP in CIDR form (e.g. 203.0.113.45/32). This will allow SSH from your IP only.

2) Authenticate to Azure

Use Azure CLI:

az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

3) Terraform init / apply

Change to the terraform directory:

cd terraform
terraform init
terraform plan -out plan.tfplan
terraform apply "plan.tfplan"

Terraform will:

Create the infra

Generate ansible/hosts.ini with the VM public IP (path configurable via ansible_inventory_path variable)

Example ansible/hosts.ini generated:

[truckco]
20.30.40.50 ansible_user=truckcoadmin

4) Run Ansible playbook

Back in the repo root:

# Use the private key that pairs with the public key you supplied to Terraform
ansible-playbook -i terraform/../ansible/hosts.ini ansible/playbook.yml --private-key ~/.ssh/truckco


This runs the playbook against the VM, installing nginx, configuring SSH and UFW, and dropping the index.html file.



