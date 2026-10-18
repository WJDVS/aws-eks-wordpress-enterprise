variable "aws_region" {
	type        = string
	description = "Target AWS region for enterprise deployment"
	default     = "us-east-1"
}

variable "environment" {
	type        = string
	description = "Deployment environment tag"
	default     = "production"
}
