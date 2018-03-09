output "ec2_dns_name" {
  value = "${aws_instance.edrms_contentstore_client.public_dns}"
}

