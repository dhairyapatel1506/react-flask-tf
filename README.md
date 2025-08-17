# Description
Deploy a React frontend and Flask backend on AWS using **Terraform** and **GitHub Actions**.

## Flow
<img src="https://github.com/user-attachments/assets/8c02cb6f-61c0-474b-88f6-7838dab2ce14" />

## Infrastructure Overview
<img width=963 alt="react-flask-tf" src="https://github.com/user-attachments/assets/db1d3507-0cb3-48ec-8db0-1a0eb029800d" />

# Infrastructure Components

## Frontend
- **S3 bucket** for static website hosting.
- **config.json** dynamically updated with ALB URL using Actions.

## Backend
- **ECS Cluster (Fargate)** running Flask app.
- **ALB** to balance traffic between 2 ECS tasks.
- **ECR** for Docker images.

## CI/CD Automation
- **full-deploy.yml** workflow:
  - Builds Docker image & pushes to ECR.
  - Deploys backend with Terraform.
  - Retrieves ALB DNS and injects into frontend config.
  - Deploys frontend to S3.
- **full-destroy.yml** workflow:
  - Cleans up all resources.

## Terraform State
- Stored in a dedicated **S3 bucket**

# Setup
- **Step 1: Fork this repo.**
- **Step 2: Add your AWS Access Key ID and Secret Access Key as repository secrets in your repo's settings.**
- **Step 3: Clone your forked repo to your local machine.**
- **Step 4: Create an S3 bucket to store Terraform states (with versioning enabled).**
- **Step 5: Modify `backend.tf`, `ecr.tf` and `frontend.tf`.**
  - Replace "my-tf-state-bucket-" with the name of your Terrform state bucket.

# Usage
- Make any changes in the **frontend** or **backend** folder and push them to Github to trigger the workflow.
- Wait for your workflow to finish running.
- Click on the **deploy-frontend** job and scroll down to the end of the **Apply Terraform (Frontend)** step to find your website URL.
<img width="1315" height="774" alt="cefe5ee1-6425-4a22-b6e7-5806e6ea6f06 (1)" src="https://github.com/user-attachments/assets/8d9bafcb-cd2a-4d88-9340-9d51499fe597" />
