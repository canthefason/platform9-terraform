#--------------------------------------------------------------
# This module creates all resources necessary for a private
# subnet
#--------------------------------------------------------------

variable "name" {
  default = "private"
}

variable "vpc_id" {}

variable "private_subnets" {}

variable "availability_zones" {}

variable "nat_gateway_ids" {}

variable "public_subnet_ids" {}

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
  count             = "${length(split(",", var.private_subnets))}"

  tags {
    Name = "${var.name}.${element(split(",", var.availability_zones), count.index)}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(split(",", var.nat_gateway_ids), count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",", var.private_subnets))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"

  lifecycle {
    create_before_destroy = true
  }
}

output "subnet_ids" {
  value = "${join(",", aws_subnet.private.*.id)}"
}

output "private_route_table_id" {
  value = "${aws_route_table.private.id}"
}
