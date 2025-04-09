variable "app_name" { default = "flask-app" }
variable "region" { default = "us-east-1" }
variable "aws_profile" { default = "default" }
variable "container_port" { default = 5000 }
variable "desired_count" { default = 2 }  # Number of running tasks
variable "ecr_image_url" { default = "851617285991.dkr.ecr.us-east-1.amazonaws.com/backend-repo:latest" }