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

variable "db_password" {
  description = "Master password for the WordPress RDS instance"
  type        = string
  sensitive   = true
}

variable "alb_dns_name" {
  description = "DNS name of the ALB created by the AWS Load Balancer Controller (CloudFront origin)"
  type        = string
  default     = "k8s-default-wordpres-d71c92801e-1273005238.us-east-1.elb.amazonaws.com"
}