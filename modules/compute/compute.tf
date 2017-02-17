#--------------------------------------------------------------
# This module creates all compute resources
#--------------------------------------------------------------

variable "environment" {}

variable "availability_zones" {}

variable "name" {}

variable "min_size" {}

variable "max_size" {}

variable "desired_capacity" {}

variable "instance_type" {}

variable "vpc_id" {}

variable "public_subnet_ids" {}

variable "private_subnet_ids" {}

variable "p9_instance_profile" {}

variable "p9_instance_key_name" {}

variable "p9_instance_ami" {}

variable "vpc_cidr" {}

variable "control_vpc_cidr" {}

module "kube-node" {
  source             = "./kube-node"
  availability_zones = "${var.availability_zones}"
  name               = "${var.name}"
  min_size           = "${var.min_size}"
  max_size           = "${var.max_size}"
  desired_capacity   = "${var.desired_capacity}"
  instance_type      = "${var.instance_type}"
  vpc_id             = "${var.vpc_id}"
  public_subnet_ids  = "${var.public_subnet_ids}"
  private_subnet_ids = "${var.private_subnet_ids}"

  p9_instance_profile  = "${var.p9_instance_profile}"
  p9_instance_key_name = "${var.p9_instance_key_name}"
  p9_instance_ami      = "${var.p9_instance_ami}"

  environment      = "${var.environment}"
  control_vpc_cidr = "${var.control_vpc_cidr}"
}
