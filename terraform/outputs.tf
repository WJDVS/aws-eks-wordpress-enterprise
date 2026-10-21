output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to attach to the ALB via the Ingress"
  value       = aws_wafv2_web_acl.wordpress.arn
}

output "cloudfront_domain_name" {
  description = "HTTPS address of the CloudFront distribution"
  value       = aws_cloudfront_distribution.wordpress.domain_name
}

output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "media_bucket_name" {
  value = aws_s3_bucket.media.id
}