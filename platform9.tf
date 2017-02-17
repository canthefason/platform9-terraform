#--------------------------------------------------------------
# Creates all resources necessary for stage environment
#--------------------------------------------------------------

variable "environment" {}

variable "region" {}

variable "availability_zones" {}

variable "vpc_cidr" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "p9_instance_ami" {}

variable "p9_instance_profile" {}

variable "p9_instance_key_name" {}

variable "kube_node_min" {}

variable "kube_node_max" {}

variable "kube_node_desired" {}

variable "kube_node_instance_type" {}

variable "kube_master_min" {}

variable "kube_master_max" {}

variable "kube_master_desired" {}

variable "kube_master_instance_type" {}

variable "bastion_instance_type" {}

#---------------------------------------------------------------
# Credentials - export AWS credentials using the commands below
#---------------------------------------------------------------

provider "aws" {
  region = "${var.region}"
}

module "iam" {
  source = "./modules/util/iam"
}

#----------------------------------------------------------------
# Modules - AWS Components
#----------------------------------------------------------------

module "network" {
  source = "./modules/network"

  name               = "${var.environment}"
  vpc_cidr           = "${var.vpc_cidr}"
  public_subnets     = "${var.public_subnets}"
  private_subnets    = "${var.private_subnets}"
  availability_zones = "${var.availability_zones}"
}

module "bastion" {
  source            = "./modules/compute/bastion"
  instance_type     = "${var.bastion_instance_type}"
  name              = "${var.environment}"
  vpc_cidr          = "${var.vpc_cidr}"
  vpc_id            = "${module.network.vpc_id}"
  public_subnet_ids = "${module.network.public_subnet_ids}"
  region            = "${var.region}"
  key_name          = "${var.p9_instance_key_name}"
}

module "kube-master" {
  source = "./modules/compute/kube-master"

  availability_zones = "${var.availability_zones}"
  name               = "${var.environment}"
  min_size           = "${var.kube_master_min}"
  max_size           = "${var.kube_master_max}"
  desired_capacity   = "${var.kube_master_desired}"
  instance_type      = "${var.kube_master_instance_type}"
  vpc_id             = "${module.network.vpc_id}"
  public_subnet_ids  = "${module.network.public_subnet_ids}"
  private_subnet_ids = "${module.network.private_subnet_ids}"
  iam_profile        = "${module.iam.instance_profile_name}"
  key_name           = "${var.p9_instance_key_name}"
  ami                = "${var.p9_instance_ami}"
}

module "kube-node" {
  source = "./modules/compute/kube-node"

  availability_zones = "${var.availability_zones}"
  name               = "${var.environment}"
  min_size           = "${var.kube_node_min}"
  max_size           = "${var.kube_node_max}"
  desired_capacity   = "${var.kube_node_desired}"
  instance_type      = "${var.kube_node_instance_type}"
  vpc_id             = "${module.network.vpc_id}"
  public_subnet_ids  = "${module.network.public_subnet_ids}"
  private_subnet_ids = "${module.network.private_subnet_ids}"
  iam_profile        = "${module.iam.instance_profile_name}"
  key_name           = "${var.p9_instance_key_name}"
  ami                = "${var.p9_instance_ami}"
  kube_master_sg_id  = "${module.kube-master.kube_master_sg_id}"
}

# VPC
output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.network.vpc_cidr}"
}
