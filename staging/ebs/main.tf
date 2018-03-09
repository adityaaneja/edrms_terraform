/*
terraform {
  backend "s3" {
    bucket  = "ca.ualberta.srv.edrms-contentstore-experiment"
    key     = "staging/contentstore/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
*/

provider "aws" {
  region = "us-east-1"
}
/*
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ca.ualberta.srv.edrms-contentstore-experiment"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
  force_destroy = true
}
*/

data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}






resource "aws_ebs_volume" "ebs_contentstore" {
  availability_zone = "us-east-1a"
  size              = 1
  tags {
	Name = "edrms_contentstore_volume"
	}
}
