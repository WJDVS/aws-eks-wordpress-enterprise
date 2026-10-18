module "vpc" {
	source  = "terraform-aws-modules/vpc/aws"
	version = "~> 5.0"

	name = "aws-eks-wordpress-vpc"
	cidr = "10.0.0.0/16"

	azs             = ["us-east-1a", "us-east-1b"]
	public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
	private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

	enable_nat_gateway   = true
	single_nat_gateway   = true
	enable_dns_hostnames = true
	enable_dns_support   = true

	# Required tags for Kubernetes (EKS) auto-discovery of subnets
	public_subnet_tags = {
		"kubernetes.io/role/elb" = "1"
		"Name"                   = "aws-eks-wordpress-public-subnet"
	}

	private_subnet_tags = {
		"kubernetes.io/role/internal-elb" = "1"
		"Name"                            = "aws-eks-wordpress-private-subnet"
	}

	tags = {
		Project     = "aws-eks-wordpress-enterprise"
		Environment = var.environment
	}
}
