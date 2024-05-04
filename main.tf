terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "example_ec2" {
    ami             = "ami-0c55b159cbfafe1f0"
    instance_type   = "t2.micro"
    subnet_id       = "subnet-0120c55b159cbfafe1f0"
    key_name        = "vps-test-key"
    tags            = {
        name        = "test-instance"
    }    
}
