module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "aws-eks-wordpress-cluster"
  cluster_version = "1.33"

  cluster_endpoint_public_access = true
  authentication_mode            = "API_AND_CONFIG_MAP"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Let the module manage admin permissions via our custom entry only, avoiding duplicate creator conflicts
  enable_cluster_creator_admin_permissions = false

  access_entries = {
    admin_user = {
      principal_arn = "arn:aws:iam::891612560987:user/aws-eks-wordpress-admin"
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # EKS managed add-ons: AWS keeps these compatible with the cluster version
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

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