variable "public_subnet_ids" {}

resource "aws_elb" "kube-master" {
  name = "${var.name}-kube-master"

  #availability_zones = ["${split(",", var.availability_zones)}"]
  subnets         = ["${split(",", var.public_subnet_ids)}"]
  security_groups = ["${aws_security_group.elb-kube-master.id}"]

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 4001
    instance_protocol = "tcp"
    lb_port           = 4001
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:4001"
    interval            = 30
  }
}
