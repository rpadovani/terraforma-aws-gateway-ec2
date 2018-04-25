# KEY for rpadovani
resource "aws_api_gateway_api_key" "rpadovani" {
  name = "rpadovani"
}

resource "aws_api_gateway_usage_plan_key" "rpadovani_unlimited" {
  key_id        = "${aws_api_gateway_api_key.rpadovani.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.unlimited_usage_plane.id}"
}