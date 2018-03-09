variable "aws_region" {
  description = "The AWS region to use"
  default     = "us-east-1"
}

variable "aws_vpc" {
  description = "The name of the vpc to use "
  default     = "vpc-72fc5d0a"
}

variable "aws_az" {
  description = "The name of the AZ to use "
  default     = "us-east-1a"
}

variable "ec2_instance_type" {
  description = "The instance type for EC2 "
  default     = "t2.medium"
}


