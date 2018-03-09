terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-iam-aamyuser"
    key    = "global/iam/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_iam_user" "example" {
  count = "${length(var.user_names)}"
  name = "${element(var.user_names, count.index)}"
}

