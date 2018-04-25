resource "aws_api_gateway_usage_plan" "unlimited_usage_plane" {
  name = "unlimited_usage_plane"
  description = "Unlimited usage of our APIs"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.our_api.id}"
    stage  = "${aws_api_gateway_deployment.prod.stage_name}"
  }
}
