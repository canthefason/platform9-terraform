#--------------------------------------------------------------
# This module creates all resources necessary for an ASG
#--------------------------------------------------------------

variable "name" {}

variable "ami" {}

variable "instance_type" {}

variable "iam_profile" {}

variable "key_name" {}

variable "max_size" {}

variable "min_size" {}

variable "desired_capacity" {}

variable "public_subnet_ids" {}

variable "private_subnet_ids" {}

variable "availability_zones" {}

resource "aws_elb" "kube-node" {
  name = "${var.name}-kube-node"

  #availability_zones    = ["${split(",", var.availability_zones)}"]
  subnets         = ["${split(",", var.public_subnet_ids)}"]
  security_groups = ["${aws_security_group.elb-kube-node.id}"]

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:443"
    interval            = 30
  }
}

resource "aws_launch_configuration" "kube-node" {
  name                 = "${var.name}-kube-node"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.p9-instance.id}"]
  iam_instance_profile = "${var.iam_profile}"
  key_name             = "${var.key_name}"

  #user_data                   = "${file("../data/platform9-install.sh")}"
  #associate_public_ip_address = true
  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_autoscaling_group" "kube-node" {
  #availability_zones    = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier  = ["${split(",", var.private_subnet_ids)}"]
  name                 = "${var.name}-kube-node"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  load_balancers       = ["${aws_elb.kube-node.name}"]
  launch_configuration = "${aws_launch_configuration.kube-node.name}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "environment"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "kube-node.${var.name}.autoscale"
    propagate_at_launch = true
  }
}
