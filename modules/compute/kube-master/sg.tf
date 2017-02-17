variable "vpc_id" {}

resource "aws_security_group" "kube-master" {
  name   = "${var.name}-kube-master"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "https-self" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.elb-kube-master.id}"
  security_group_id        = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "etcd-self" {
  type      = "ingress"
  from_port = 4001
  to_port   = 4001
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "etcd" {
  type      = "ingress"
  from_port = 4001
  to_port   = 4001
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.elb-kube-master.id}"
  security_group_id        = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "etcd-peer" {
  type      = "ingress"
  from_port = 2380
  to_port   = 2380
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "kubelet" {
  type      = "ingress"
  from_port = 10250
  to_port   = 10250
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "flannel" {
  type      = "ingress"
  from_port = 8285
  to_port   = 8285
  protocol  = "udp"
  self      = true

  security_group_id = "${aws_security_group.kube-master.id}"
}

resource "aws_security_group_rule" "egress" {
  # outbound internet access
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.kube-master.id}"
}

#----------------------------------------------------------------
# Modules - Kube Master ELB Security Group
#----------------------------------------------------------------

resource "aws_security_group" "elb-kube-master" {
  name   = "${var.name}-elb-kube-master"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4001
    to_port     = 4001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "kube_master_sg_id" {
  value = "${aws_security_group.kube-master.id}"
}
