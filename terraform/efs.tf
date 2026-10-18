resource "aws_efs_file_system" "wordpress_efs" {
	creation_token   = "aws-eks-wordpress-efs"
	performance_mode = "generalPurpose"
	throughput_mode  = "bursting"
	encrypted        = true

	tags = {
		Name        = "aws-eks-wordpress-efs"
		Project     = "aws-eks-wordpress-enterprise"
		Environment = var.environment
	}
}

resource "aws_security_group" "efs_sg" {
	name        = "aws-eks-wordpress-efs-sg"
	description = "Allow inbound NFS traffic from VPC for EFS"
	vpc_id      = module.vpc.vpc_id

	ingress {
		description = "NFS from VPC subnets"
		from_port   = 2049
		to_port     = 2049
		protocol    = "tcp"
		cidr_blocks = [module.vpc.vpc_cidr_block]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "aws-eks-wordpress-efs-sg"
	}
}

resource "aws_efs_mount_target" "efs_mount_target" {
	count           = length(module.vpc.private_subnets)
	file_system_id  = aws_efs_file_system.wordpress_efs.id
	subnet_id       = module.vpc.private_subnets[count.index]
	security_groups = [aws_security_group.efs_sg.id]
}
