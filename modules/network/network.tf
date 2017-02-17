#--------------------------------------------------------------
# This module creates all networking resources
#--------------------------------------------------------------

variable "name" {}

variable "vpc_cidr" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "availability_zones" {}

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name               = "${var.name}-public-subnet"
  vpc_id             = "${module.vpc.vpc_id}"
  public_subnets     = "${var.public_subnets}"
  availability_zones = "${var.availability_zones}"
}

#module "r53" {
#source = "./r53"
#}

module "nat" {
  source = "./nat"

  name               = "${var.name}-nat"
  availability_zones = "${var.availability_zones}"
  public_subnet_ids  = "${module.public_subnet.subnet_ids}"
}

module "private_subnet" {
  source = "./private_subnet"

  name               = "${var.name}-private"
  vpc_id             = "${module.vpc.vpc_id}"
  private_subnets    = "${var.private_subnets}"
  availability_zones = "${var.availability_zones}"

  nat_gateway_ids   = "${module.nat.nat_gateway_ids}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

# VPC
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}

# Subnets
output "public_subnet_ids" {
  value = "${module.public_subnet.subnet_ids}"
}

#output "r53_zone_id" {
#value = "${module.r53.zone_id}"
#}

output "private_subnet_ids" {
  value = "${module.private_subnet.subnet_ids}"
}

# NAT
output "nat_gateway_ids" {
  value = "${module.nat.nat_gateway_ids}"
}

output "private_route_table_id" {
  value = "${module.private_subnet.private_route_table_id}"
}

output "public_route_table_id" {
  value = "${module.public_subnet.public_route_table_id}"
}
