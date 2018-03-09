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

/*
data "aws_ebs_volume" "edrms_ebs_volume" {
  most_recent = "true"
  filter {
	name = "tag:Name"
	values = ["edrms_contentstore_volume"]
	}
}
*/

resource "aws_security_group" "contentstore_clientsg" {
  name        = "edrms_contentstore_clientsg"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["142.244.161.85/32","142.244.161.39/32","142.244.5.35/32","75.158.126.212/32"]
  }

  egress {
    from_port   = 2049
    to_port     = 2049 
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

    egress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    from_port   = 20048
    to_port     = 20048
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }


  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }




}




/*

resource "aws_volume_attachment" "ebs_contentstore_att" {
  device_name = "/dev/xvdh"
  volume_id   = "${data.aws_ebs_volume.edrms_ebs_volume.id}"
  instance_id = "${aws_instance.edrms_contentstore.id}"
}

*/
resource "aws_instance" "edrms_contentstore_client" {
  ami               = "ami-0036ab7a"
  availability_zone = "us-east-1a"
  instance_type     = "t2.micro"
  security_groups = ["edrms_contentstore_clientsg"]
  key_name = "mykey"

  tags {
    Name = "Contentstoreclient"
  }

  user_data = "${file("files/mount_ebs_nfs.sh")}"
}
/*
resource "aws_ebs_volume" "ebs_contentstore" {
  availability_zone = "us-east-1a"
  size              = 1
}
*/

