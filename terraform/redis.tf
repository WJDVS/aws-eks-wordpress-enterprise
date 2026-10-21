
# ElastiCache Redis: object cache for WordPress

resource "aws_elasticache_subnet_group" "redis" {
  name       = "aws-eks-wordpress-redis-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "redis_sg" {
  name        = "aws-eks-wordpress-redis-sg"
  description = "Redis access from EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Redis from EKS worker nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "aws-eks-wordpress-redis"
  description          = "Redis object cache for WordPress"

  engine               = "redis"
  engine_version       = "7.1"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t3.micro"
  port                 = 6379

  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis_sg.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  snapshot_retention_limit = 0
  apply_immediately        = true
}
