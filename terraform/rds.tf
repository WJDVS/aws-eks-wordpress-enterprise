resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
	name       = "aws-eks-wordpress-db-subnet-group"
	subnet_ids = module.vpc.private_subnets

	tags = {
		Name = "WordPress DB Subnet Group"
	}
}

resource "aws_db_instance" "wordpress_rds" {
	identifier             = "aws-eks-wordpress-db"
	engine                 = "mysql"
	engine_version         = "8.0"
	instance_class         = "db.t3.micro"
	allocated_storage      = 20
	max_allocated_storage  = 100
	multi_az               = true

	db_name              = "wordpress"
	username             = "admin"
	password             = "SecureWordPressAdminPassword2026!" # In production, use AWS Secrets Manager or variables
	db_subnet_group_name = aws_db_subnet_group.wordpress_db_subnet_group.name
	skip_final_snapshot  = true

	tags = {
		Project     = "aws-eks-wordpress-enterprise"
		Environment = var.environment
	}
}
