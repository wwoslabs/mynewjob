# Trucking Tracker Web Server Deployment: Infrastructure & Configuration Automation

## Project Overview: Infrastructure as Code (IaC) for TruckCo Logistics

This project implements a robust, two-phase automated deployment for the initial web server footprint of the TruckCo Logistics application using industry-leading DevOps practices.

Phase 1: Infrastructure Provisioning (Terraform)
Terraform provisions all immutable Azure resources, including secure networking, a Linux Virtual Machine, and a dynamic public IP address.

Phase 2: Configuration Management (Ansible)
Ansible automatically connects to the newly provisioned VM to harden security, install dependencies (Nginx), configure the host firewall, and deploy the application stub.

### Key Design Decisions

Component

Design Decision

Rationale/Best Practice

Authentication

SSH Key-Based Only (No Passwords)

Adheres to the security principle of Zero Trust. SSH keys are inherently more secure and difficult to brute-force than passwords.

Access Control

Azure NSG + Host UFW

Implements a Defense-in-Depth strategy. The NSG (Network Security Group) provides the first layer of protection at the network perimeter. The UFW (Uncomplicated Firewall) provides the second layer at the OS level, ensuring protection regardless of external network configuration.

Integration

Dynamic Ansible Inventory

Terraform uses the local_file resource and a template to automatically generate hosts.ini with the VM's Public IP. This ensures the configuration pipeline is fully automated and idempotent, removing manual steps.

Security Scope

Strict SSH Restriction

The NSG rule for Port 22 (SSH) is locked down to a single IP address (10.2.82.15/32), following the Principle of Least Privilege to minimize the internet-facing attack surface.

## Prerequisites and Environment Setup

To successfully run this deployment pipeline, ensure the following tools are installed and configured:

Azure CLI: Used for authentication (az login).

Terraform (v1.0+): Installed and accessible via your PATH.

Ansible (v2.10+): Installed, along with the community.general collection (required for the ufw module):

ansible-galaxy collection install community.general


SSH Key Pair: A working private key (~/.ssh/id_rsa) and public key (~/.ssh/id_rsa.pub) are required for Ansible connectivity and VM provisioning, respectively.

### Variable Configuration

The deployment uses the admin username marciomjr. Create a file named terraform.tfvars in the root directory to provide the necessary secrets and location parameters:

Variable

Current Value (as per request)

Description

my_public_ip_cidr

10.2.82.15/32

The specific CIDR for your local machine's public IP to allow SSH access through the Azure NSG. Note: If this is a private IP, you must change it to your actual public IP for successful connectivity.

ssh_public_key_path

(User defined, e.g., "~/.ssh/id_rsa.pub")

The absolute path to the public key used for provisioning the VM.

Example terraform.tfvars:

# This IP is used to restrict SSH access on the Azure Network Security Group (NSG)
my_public_ip_cidr   = "10.2.82.15/32"

# This path is used to inject your key into the new Azure VM
ssh_public_key_path = "~/.ssh/id_rsa.pub"


## Execution Steps

Step 1: Deploy Azure Infrastructure (Terraform)

This step creates all resources and dynamically generates the Ansible inventory file (hosts.ini).

Authenticate to Azure:

az login


Initialize Terraform:

terraform init


Review the Execution Plan: (Always review before applying)

terraform plan -var-file="terraform.tfvars"


Apply and Provision:

terraform apply -var-file="terraform.tfvars"


Confirm with yes when prompted. Upon completion, the VM's public IP will be displayed, and the hosts.ini file will be ready.

### Step 2: Configure Server (Ansible)

This step connects to the VM using the generated inventory and applies the desired state configuration.

Execute the Playbook:

ansible-playbook -i hosts.ini setup_server.yml


The playbook will execute the 11 tasks outlined below.

## Ansible: setup_server.yml Configuration

The Ansible playbook is a declarative configuration file that ensures the server reaches the desired, secured state.

Task #

Goal

Ansible Module

Configuration Details

Rationale

1

System Update

ansible.builtin.apt

Updates package cache, performs a distribution upgrade (upgrade: dist), and removes unnecessary packages (autoremove: yes).

Ensures the VM is patched against known vulnerabilities before installing services.

2, 3

Web Server Install

ansible.builtin.apt & ansible.builtin.service

Installs Nginx and ensures it is both started immediately and enabled to launch automatically on reboot.

Establishes the core web serving functionality.

4

Application Stub Deployment

ansible.builtin.copy

Pushes the provided HTML content, including minimal modern styling, to the webroot (/var/www/html/index.html).

Deploys the initial application state and provides immediate visual confirmation of Nginx functionality.

5, 6, 7, 8

Host Firewall (UFW)

ansible.builtin.apt & community.general.ufw

Installs UFW, explicitly allows SSH (22) and HTTP (80) inbound, and then enables the firewall with a default reject policy.

Essential security hardening. The default reject policy ensures any port not explicitly opened is blocked at the host level.

9, 10, 11

SSH Hardening

ansible.builtin.lineinfile & ansible.builtin.service

Edits /etc/ssh/sshd_config to set PermitRootLogin no and PasswordAuthentication no. The SSH service is then restarted.

Enforces key-based authentication for the administrative user (marciomjr) and disables the highest-privilege entry point, enhancing overall system security.

## Verification

Upon successful execution of both Terraform and Ansible:

Retrieve the public_ip_address from the final Terraform output.

Open your browser and navigate to: http://<VM_PUBLIC_IP_ADDRESS>

The portal should load, displaying the "Welcome to the TruckCo Logistics Portal. (Under Construction)" message.

Security Test: Attempt to SSH into the VM using a different computer or a user other than marciomjr. The connection should be immediately refused by the NSG or the SSH daemon.

## Clean Up

To destroy all deployed Azure resources and avoid incurring charges, run:

terraform destroy -var-file="terraform.tfvars"


Confirm with yes.
