terraform {
  required_version = "~> 1.12.2"

  required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = var.terraform_state_bucket
    key            = "/eks/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfiles    = true
    encrypt        = true
  }
}

  provider "aws" {
    region = var.aws-region
  }