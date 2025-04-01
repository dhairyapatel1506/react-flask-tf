variable "app_name" { default = "flask-app" }
variable "region" { default = "us-east-1" }
variable "aws_profile" { default = "default" }
variable "container_port" { default = 5000 }
variable "desired_count" { default = 1 }  # Number of running tasks
variable "ecr_image_url" { default = "851617285991.dkr.ecr.us-east-1.amazonaws.com/backend-repo:latest" }
variable "vpc_id" { default = "vpc-0030bede84069e169" }
variable "subnet_ids" { default = ["subnet-006515bc4ecbf0fbc", "subnet-0fee8939bd6a90ca8"] }