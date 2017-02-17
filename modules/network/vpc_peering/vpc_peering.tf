variable peer_vpc_id {}

variable peer_owner_id {}

variable local_vpc_id {}

variable local_vpc_cidr {}

variable local_route_table_id {}

variable peer_route_table_ids {}

variable peer_vpc_cidr {}

variable peer_name {}

variable name {}

resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  vpc_id        = "${var.local_vpc_id}"
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name = "VPC Peering between ${var.peer_name} and ${var.name}"
  }
}

resource "aws_route" "peer" {
  route_table_id            = "${element(split(",", var.peer_route_table_ids), 0)}"
  destination_cidr_block    = "${var.local_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
}

resource "aws_route" "peer-public" {
  route_table_id            = "${element(split(",", var.peer_route_table_ids), 1)}"
  destination_cidr_block    = "${var.local_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
}

resource "aws_route" "local" {
  route_table_id            = "${var.local_route_table_id}"
  destination_cidr_block    = "${var.peer_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
}

#resource "aws_route" "local-public" {
#route_table_id            = "${var.local_public_route_table_id}"
#destination_cidr_block    = "${var.peer_vpc_cidr}"
#vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
#}

output "peering_id" {
  value = "${aws_vpc_peering_connection.peer.id}"
}
