/*
terraform {
  backend "s3" {
    bucket  = "mysql-aamyuser"
    key     = "stage/services/mysql-cluster/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
*/

provider "aws" {
  region = "${var.aws_region}"
}

 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}


/*
resource "aws_s3_bucket" "terraform_state" {
  bucket = "mysql-aamyuser"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}
*/
/*
resource "aws_db_instance" "example" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin"
  password          = "${var.db_password}"
}
*/

resource "aws_db_instance" "alfresco" {
  identifier	      = "edrms-db"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = "db.t2.micro"
  name                 = "alfresco"
  username             = "alfresco"
  password             = "alfresco2251"
/*  db_subnet_group_name = "my_database_subnet_group"*/
  parameter_group_name = "default.mysql5.6"
  availability_zone     = "us-east-1a"
  publicly_accessible  = false 
  vpc_security_group_ids = ["${aws_security_group.database_sg.id}"]
  skip_final_snapshot = true

}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow all inbound traffic to Mysql"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

}

