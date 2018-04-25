# Our gateway
resource "aws_api_gateway_rest_api" "our_api" {
  name = "OurAPI"
  binary_media_types = ["audio/mpeg", "multipart/form-data"]
}

# Attach the gateway to the internal ARN
# https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started-with-private-integration.html
resource "aws_api_gateway_vpc_link" "our_resource_link_to_our_ec2" {
  name = "link"
  target_arns = ["${aws_lb.our_nlb.arn}"]
}

# We have just one stage (production) at the moment, but they can become more (like staging, test)
resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = "${aws_api_gateway_rest_api.our_api.id}"
  stage_name = "prod"
}

# We have one resources ATM
resource "aws_api_gateway_resource" "our_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.our_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.our_api.root_resource_id}"
  path_part   = "resource"
}

# The resource has a POST method
resource "aws_api_gateway_method" "POST_our_resource" {
  rest_api_id   = "${aws_api_gateway_rest_api.our_api.id}"
  resource_id   = "${aws_api_gateway_resource.our_resource.id}"
  http_method   = "POST"
  authorization = "NONE"    # You should implement proper authorization, here or on the server.
  # DO NOT trust only the API key https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-control-access-to-api.html
  api_key_required = true   # Require a key
}

# The resources are only a Proxy to our ec2 instance
resource "aws_api_gateway_integration" "our_resource_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.our_api.id}"
  resource_id             = "${aws_api_gateway_resource.our_resource.id}"
  http_method             = "${aws_api_gateway_method.POST_our_resource.http_method}"
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "${format("http://%s/our_resource", aws_instance.aws_instance.private_ip)}"

  connection_type         = "VPC_LINK"
  connection_id           = "${aws_api_gateway_vpc_link.our_resource_link_to_our_ec2.id}"
}

# CORS related options
resource "aws_api_gateway_method" "options_method_our_resource" {
    rest_api_id   = "${aws_api_gateway_rest_api.our_api.id}"
    resource_id   = "${aws_api_gateway_resource.our_resource.id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200_our_resource" {
    rest_api_id   = "${aws_api_gateway_rest_api.our_api.id}"
    resource_id   = "${aws_api_gateway_resource.our_resource.id}"
    http_method   = "${aws_api_gateway_method.options_method_our_resource.http_method}"
    status_code   = 200
    response_models {
        "application/json" = "Empty"
    }
    response_parameters {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration" "options_integration_our_resource" {
    rest_api_id   = "${aws_api_gateway_rest_api.our_api.id}"
    resource_id   = "${aws_api_gateway_resource.our_resource.id}"
    http_method   = "${aws_api_gateway_method.options_method_our_resource.http_method}"
    type          = "MOCK"

    request_templates {
        "application/json" = "{\"statusCode\": 200}"
    }
}

resource "aws_api_gateway_integration_response" "options_integration_response_our_resource" {
    rest_api_id   = "${aws_api_gateway_rest_api.our_api.id}"
    resource_id   = "${aws_api_gateway_resource.our_resource.id}"
    http_method   = "${aws_api_gateway_method.options_method_our_resource.http_method}"
    status_code   = "${aws_api_gateway_method_response.options_200_our_resource.status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Api-Key'",
        "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'", # Add others method here
        "method.response.header.Access-Control-Allow-Origin" = "'*'" # You can restrict this more
    }
}