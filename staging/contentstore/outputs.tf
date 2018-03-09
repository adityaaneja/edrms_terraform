output "ec2_dns_name" {
  value = "${aws_instance.edrms_contentstore.public_dns}"
}

