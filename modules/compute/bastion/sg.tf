variable "vpc_id" {}

variable "vpc_cidr" {}

resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion security group"

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sg_id" {
  value = "${aws_security_group.bastion.id}"
}
