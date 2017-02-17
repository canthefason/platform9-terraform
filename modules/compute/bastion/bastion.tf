#--------------------------------------------------------------
# This module creates all resources necessary for a Bastion
# host
# TODO: Understand key_name and choose AMI
#--------------------------------------------------------------

variable "name" {
  default = "bastion"
}

variable "region" {}

variable "public_subnet_ids" {}

variable "key_name" {}

variable "instance_type" {}

module "ami" {
  source        = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type = "${var.instance_type}"

  region       = "${var.region}"
  distribution = "trusty"
}

// TODO It will be better to create an autoscaling group and an ELB

resource "aws_instance" "bastion" {
  ami                         = "${module.ami.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true

  tags {
    Name = "${var.name}-bastion"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "user" {
  value = "ubuntu"
}

output "private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}

output "public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
