variable "name" {}

variable "ami" {}

variable "instance_type" {}

variable "iam_profile" {}

variable "key_name" {}

variable "min_size" {}

variable "max_size" {}

variable "desired_capacity" {}

variable "availability_zones" {}

variable "private_subnet_ids" {}

resource "aws_launch_configuration" "kube-master" {
  name                 = "${var.name}-kube-master"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.kube-master.id}"]
  iam_instance_profile = "${var.iam_profile}"
  key_name             = "${var.key_name}"

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_autoscaling_group" "kube-master" {
  availability_zones  = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${split(",", var.private_subnet_ids)}"]
  name                = "${var.name}-kube-master"
  max_size            = "${var.max_size}"
  min_size            = "${var.min_size}"
  desired_capacity    = "${var.desired_capacity}"

  load_balancers       = ["${aws_elb.kube-master.name}"]
  launch_configuration = "${aws_launch_configuration.kube-master.name}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "kube-master.autoscale"
    propagate_at_launch = true
  }

  tag {
    key                 = "Roles"
    value               = "kube-master"
    propagate_at_launch = true
  }
}
