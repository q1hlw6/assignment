terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.29.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.2"
    }
  }
}

provider "aws" {
  region = var.region
}

# NOTE the rest of the code (incorrectly) assumes there are always exactly 3
data "aws_availability_zones" "all" {}

locals {
  vpc_name = var.project_name

  # TODO use cidrsubnet etc.
  vpc_cidr            = "172.16.0.0/16"
  vpc_private_subnets = ["172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24"]
  vpc_public_subnets  = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]

  cluster_name    = var.project_name
  cluster_version = "1.19"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = data.aws_availability_zones.all.names
  private_subnets = local.vpc_private_subnets
  public_subnets  = local.vpc_public_subnets
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "14.0.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  write_kubeconfig = false
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
