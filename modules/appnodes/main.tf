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

data "aws_instance" "edrms_contentstore_ec2" {
    filter {
		name = "tag:Name"
		values = ["Contentstore"]
	}
}


data "aws_instance" "chefserver_ec2" {
    filter {
                name = "tag:Name"
                values = ["ChefServer"]
        }
}


data "aws_db_instance" "edrms_rds" {
    db_instance_identifier = "edrms-db"
}



 data "aws_vpc" "main" {
  id = "${var.aws_vpc}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/files/user-data.sh")}"

  vars {
    server_port = "80"
    db_address  = "localhost"
    db_port     = "3306"
    server_text = "test data"
  }
}




resource "aws_launch_configuration" "lamp" {
   image_id = "ami-6be91416"
  instance_type = "${var.ec2_instance_type}"
  security_groups = ["lamp_allow_all","edrms_contentstore_clientsg"]
  key_name = "mykey"
  count = "${length(var.instancelist)}"

  user_data       = "${data.template_file.user_data.rendered}"
/*  tags {
    Name = "ChefClient_${element(var.instancelist, count.index)}"
  }
*/
/*
  availability_zone="${var.aws_az}"
*/
  connection {
    type     = "ssh"
    user     = "centos"
    private_key = "${file("${path.module}/mykey.pem")}"
  }

/*
  provisioner "file" {
    source="files/alfresco.war"
    destination="/home/centos/alfresco.war"
  }

 provisioner "file" {
    source="files/share.war"
    destination="/home/centos/share.war"
  }

provisioner "remote-exec" {
    inline         = [ "sudo yum install nfs-utils -y",
                       "sudo mount ${data.aws_instance.edrms_contentstore_ec2.private_ip}:/media /media"]
}


   provisioner "chef" {

    attributes_json = <<-EOF
	{
	"database_address": "${data.aws_db_instance.edrms_rds.address}",
	"database_port": "${data.aws_db_instance.edrms_rds.port}"
	}
	EOF

    environment     = "_default"
    node_name       = "webserver_${element(var.instancelist, count.index)}"
    run_list        = ["edrms"]
    server_url      = "https://${data.aws_instance.chefserver_ec2.public_ip}/organizations/adityauoa"
    recreate_client = true
    user_name       = "chefadmin"
    user_key        = "${file("${path.module}/files/chefadmin.pem")}"
    version	    = "12.21.20"
    ssl_verify_mode = ":verify_none"
  }
*/

lifecycle {
	create_before_destroy = true
	}
}


resource "aws_autoscaling_group" "edrms-ag" {
  name                 = "edrms-autoscaling-group"
  launch_configuration = "${aws_launch_configuration.lamp.id}"
  min_size             =  2
  max_size             =  5
  min_elb_capacity     =  3
  availability_zones   = ["us-east-1a"]
  load_balancers       = ["${aws_elb.edrms-elb.name}"]
  health_check_type    = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "edrms-autoscaling-group"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name  = "scale-out-during-bussiness-hours"
  min_size               = 2
  max_size               = 5
  desired_capacity       = 3 
  recurrence             = "0 9 * * *"
  autoscaling_group_name = "edrms-autoscaling-group"
}

resource "aws_autoscaling_schedule" "scale_in_during_night_hours" {
  scheduled_action_name  = "scale-in-during-night-hours"
  min_size               = 2
  max_size               = 5
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = "edrms-autoscaling-group"
}


resource "aws_elb" "edrms-elb" {
  name               = "edrms-elb"
  availability_zones = ["us-east-1a"]
  security_groups    = ["${aws_security_group.edrms-elbsg.id}"]

  lifecycle {
    create_before_destroy = true
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2 
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/share/page"
  }

}


resource "aws_lb_cookie_stickiness_policy" "edrms-elb-sticky" {
  name                     = "edrmselbstickypolicy"
  load_balancer            = "${aws_elb.edrms-elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_security_group" "edrms-elbsg" {
  name = "edrms_elbsg"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.edrms-elbsg.id}"
  from_port         =  80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.edrms-elbsg.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}




resource "aws_security_group" "lamp_allow_all" {
  name        = "lamp_allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"
  
  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["142.244.161.85/32","142.244.161.39/32","142.244.5.36/32","75.158.126.212/32","172.31.0.0/16","162.211.117.188/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

 ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

 egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["172.31.0.0/16"]
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

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }


}

resource "aws_security_group" "contentstore_clientsg" {
  name        = "edrms_contentstore_clientsg"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  lifecycle {
    create_before_destroy = true
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


}




