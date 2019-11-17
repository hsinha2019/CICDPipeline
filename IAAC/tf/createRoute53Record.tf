resource "aws_route53_zone" "main" {
  name = "justletsdoit.com."
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "justletsdoit.com."
  type    = "A"

  alias {
    name                   = "${aws_lb.demoAppLB.dns_name}"
    zone_id                = "${aws_lb.demoAppLB.zone_id}"
    evaluate_target_health = false
  }
}
