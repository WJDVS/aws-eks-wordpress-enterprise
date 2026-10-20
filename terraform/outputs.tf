output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to attach to the ALB via the Ingress"
  value       = aws_wafv2_web_acl.wordpress.arn
}

output "cloudfront_domain_name" {
  description = "HTTPS address of the CloudFront distribution"
  value       = aws_cloudfront_distribution.wordpress.domain_name
}