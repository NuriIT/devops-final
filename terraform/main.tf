provider "aws" {
  region = "us-east-1"
}

# Create a VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "proshop-vpc"
  cidr   = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# Create an EKS IAM Role
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create an EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "proshop-cluster"
  cluster_version = "1.27"
  cluster_role_arn = aws_iam_role.eks_role.arn
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}

# Output cluster details
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
}
