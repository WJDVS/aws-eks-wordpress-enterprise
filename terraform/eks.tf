module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "aws-eks-wordpress-cluster"
  cluster_version = "1.31" # Updated to a supported version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    wordpress_nodes = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.medium"]
      subnet_ids     = module.vpc.private_subnets
    }
  }

  tags = {
    Project     = "aws-eks-wordpress-enterprise"
    Environment = var.environment
  }
}