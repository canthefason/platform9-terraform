resource "aws_route53_zone" "p9" {
  name = "new.glidr.io"
}

output "zone_id" {
  value = "${aws_route53_zone.p9.id}"
}
