variable "name" {}
variable "check_inventory_lambda_arn" {}
variable "save_inventory_lambda_arn" {}

data "template_file" "swagger" {
  template = file("${path.root}/swagger.yaml")
  vars = {
    check_inventory_lambda_arn = var.check_inventory_lambda_arn
    save_inventory_lambda_arn = var.save_inventory_lambda_arn
  }
}

resource "aws_api_gateway_rest_api" "inventory_api" {
  name = "${var.name}-inventory-api"
  body = data.template_file.swagger.rendered
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.inventory_api.id
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id  = aws_api_gateway_rest_api.inventory_api.id
  stage_name   = "prod"
}

resource "aws_lambda_permission" "check_inventory_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.check_inventory_lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.inventory_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "save_inventory_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.save_inventory_lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.inventory_api.execution_arn}/*/*"
}

output "api_url" {
  value = aws_api_gateway_stage.api_stage.invoke_url
}


resource "aws_apigatewayv2_api" "main" {
  name          = var.name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id = aws_apigatewayv2_api.main.id
  name   = "$default"
  auto_deploy = true
}

output "execution_arn" {
  value = aws_apigatewayv2_api.main.execution_arn
}
