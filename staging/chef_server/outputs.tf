
output "ec2_dns_name" {
  value = "${aws_instance.web.public_dns}"
}

output "ec2_private_ip" {
  value = "${aws_instance.web.private_ip}"
}


