# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Adding credentials
provider "aws" {
  region     = "us-east-2"
  access_key = "AKIAW6TMXYOU6VDQQ2OU"
  secret_key = "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"
}

# Provides a VPC resource
resource "aws_vpc" "main" {
  cidr_block = "200.0.0.0/24"
  tags = {
    Name = "Jnana VPC"
  }
}

# Provides an VPC subnet resource
resource "aws_subnet" "mysubnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "200.0.0.0/25"

  tags = {
    Name = "Jnana Subnet1"
  }
}

