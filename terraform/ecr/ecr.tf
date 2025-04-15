terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket-26032025"
    key            = "ecr/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Create ECR repo
resource "aws_ecr_repository" "backend_repo" {
  name = "backend-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
}