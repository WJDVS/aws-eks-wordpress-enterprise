resource "aws_security_group" "rds_sg" {
  name        = "aws-eks-wordpress-rds-sg"
  description = "Allow MySQL from VPC for RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
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
    Name = "aws-eks-wordpress-rds-sg"
  }
}