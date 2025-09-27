variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to be used as prefix for all resources"
  type        = string
  default     = "meli-inventory"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
