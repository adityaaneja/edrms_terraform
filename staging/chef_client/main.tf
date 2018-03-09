provider "aws" {
  region = "${var.aws_region}"
}

/*
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["centos/images/hvm-ssd/centos-trusty-14.04-amd64-server-20171115.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

*/


 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}


resource "aws_instance" "lamp" {
#  ami           = "${data.aws_ami.centos.id}"
   ami = "ami-0063927a"
  instance_type = "${var.ec2_instance_type}"
  security_groups = ["lamp_allow_all"]
  key_name = "mykey"
  count = "${length(var.instancelist)}"
  tags {
    Name = "ChefClient_${element(var.instancelist, count.index)}"
  }
 # subnet_id="${var.aws_subnetid}"
  availability_zone="${var.aws_az}"
 # count = "${length(var.instancelist)}"
  #name = "${element(var.instancelist, count.index)}"
  connection {
    type     = "ssh"
    user     = "centos"
    private_key = "${file("${path.module}/mykey.pem")}"
  }


/*

   provisioner "chef" {

    environment     = "_default"
    node_name       = "webserver_${element(var.instancelist, count.index)}"
    run_list        = ["alfresco-db","java","alfresco-appserver","alfresco-webserver","alfresco-webserver::start"]
    server_url      = "https://${var.chefserverfqdn}/organizations/adityauoa"
    recreate_client = true
    user_name       = "chefadmin"
    user_key        = "${file("${path.module}/files/chefadmin.pem")}"
    version	    = "12.21.20"
    ssl_verify_mode = ":verify_none"
  }

*/

  provisioner "remote-exec" {
    script         = "${path.module}/files/setupclient.sh"
  } 

/*
  provisioner "file" {
    source="files/ec2_rsa"
    destination="/home/centos/.ssh/ec2_rsa"
  }

 provisioner "remote-exec" {
    inline = [ "chmod 600 /home/centos/.ssh/ec2_rsa" ]
  }

  provisioner "file" {
    source="files/ec2_rsa.pub"
    destination="/home/centos/.ssh/ec2_rsa.pub"
  }

  provisioner "remote-exec" {
    inline =  "cat /home/centos/.ssh/ec2_rsa.pub >> /home/centos/.ssh/authorized_keys" 
  }


  provisioner "remote-exec" {
    inline         = [ "sudo mkdir -p /opt/chef-repo/.chef",
                       "sudo chmod 777 /opt/chef-repo/.chef"]
  }

  provisioner "remote-exec" {
    inline        = "scp -oStrictHostKeyChecking=no -i /home/centos/.ssh/ec2_rsa ubuntu@${var.chefserver}:/drop/* /opt/chef-repo/.chef/"
  }

  provisioner "file" {
    content = "${data.template_file.knife.rendered}"
    destination = "/opt/chef-repo/.chef/knife.rb"
  }

  provisioner "remote-exec" {
    inline         = [ "sudo chmod 755 /opt/chef-repo/.chef",
                       "sudo knife ssl fetch -c /opt/chef-repo/.chef/knife.rb"]
  }
*/
/*
  provisioner "remote-exec" {
    inline         = ["sudo knife ssl fetch -c /opt/chef-repo/.chef/knife.rb",
                      "sudo knife  bootstrap `hostname` --sudo --ssh-user centos --identity-file /home/centos/.ssh/ec2_rsa --node-name `hostname` -c /opt/chef-repo/.chef/knife.rb"]
  }
*/

}


resource "aws_security_group" "lamp_allow_all" {
  name        = "lamp_allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["142.244.161.85/32","142.244.161.39/32","142.244.5.36/32","75.158.126.212/32","172.31.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

 egress {
    from_port   = 22
    to_port     = 22
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
data "template_file" "lamp" {

    template = "${file("${path.module}/files/output.rb.tpl")}"
    vars {
      chefclient = "${aws_instance.lamp.*.public_dns}"
    }
 }

 output "rendered" {
  value = "${data.template_file.lamp.rendered}"
}
*/


data "template_file" "knife" {

   template = "${file("${path.module}/files/knife.rb.tpl")}"
   vars {
      chefserver = "${var.chefserverfqdn}"
   }
}


