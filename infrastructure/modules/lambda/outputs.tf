output "check_inventory_lambda_arn" {
  value = aws_lambda_function.check_inventory.arn
}

output "save_inventory_lambda_arn" {
  value = aws_lambda_function.save_inventory.arn
}
