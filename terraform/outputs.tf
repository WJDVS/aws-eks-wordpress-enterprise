output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to attach to the ALB via the Ingress"
  value       = aws_wafv2_web_acl.wordpress.arn
}
