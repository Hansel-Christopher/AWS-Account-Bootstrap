terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


  backend "s3" {
    bucket = "aws-infra-tfstate-001"
    key    = "vpn/terraform.tfstate"    
  }
}

# Configure the AWS Provider
provider "aws" {}