variable "vpc_id" {}

variable "kube_master_sg_id" {}

resource "aws_security_group" "elb-kube-node" {
  name   = "${var.name}-elb-kube-node"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "p9-instance" {
  name   = "${var.name}-p9-instance"
  vpc_id = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true

    security_groups = ["${aws_security_group.elb-kube-node.id}", "${var.kube_master_sg_id}"]
  }

  # kubelet?
  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = ["${var.kube_master_sg_id}"]
  }

  # flannel
  ingress {
    from_port = 8285
    to_port   = 8285
    protocol  = "udp"
    self      = true

    security_groups = ["${var.kube_master_sg_id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "https-kube-master" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.p9-instance.id}"
  security_group_id        = "${var.kube_master_sg_id}"
}

resource "aws_security_group_rule" "etcd-kube-master" {
  type      = "ingress"
  from_port = 4001
  to_port   = 4001
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.p9-instance.id}"
  security_group_id        = "${var.kube_master_sg_id}"
}

resource "aws_security_group_rule" "flannel-kube-master" {
  type      = "ingress"
  from_port = 8285
  to_port   = 8285
  protocol  = "udp"

  source_security_group_id = "${aws_security_group.p9-instance.id}"
  security_group_id        = "${var.kube_master_sg_id}"
}
