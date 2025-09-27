provider "aws" {
  region = var.aws_region
}

module "api_gateway" {
  source = "./modules/api_gateway"
  name   = var.project_name
  check_inventory_lambda_arn = module.lambda.check_inventory_lambda_arn
  save_inventory_lambda_arn  = module.lambda.save_inventory_lambda_arn
}

module "lambda_functions" {
  source = "./modules/lambda"
  name   = "${var.project_name}-functions"
  api_gateway_execution_arn = module.api_gateway.execution_arn
}

module "event_bus" {
  source = "./modules/event-bus"
  name   = "${var.project_name}-queue"
}

module "cache" {
  source = "./modules/cache"
  name   = "${var.project_name}-cache"
}
