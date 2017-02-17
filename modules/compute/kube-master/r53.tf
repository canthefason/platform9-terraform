#resource "aws_route53_record" "p9" {
#zone_id = "${var.r53_zone_id}"
## TODO variable domain
#name = "dev-api.new.glidr.io"
#type = "A"
#alias {
#name                   = "${aws_elb.kube-master.dns_name}"
#zone_id                = "${aws_elb.kube-master.zone_id}"
#evaluate_target_health = true
#}
#}

