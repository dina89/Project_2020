terraform {
  required_version = ">= 0.12.0"
}
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

# data "aws_availability_zones" "available" {
# }

locals {
  cluster_name = "opsSchool-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.vpcCIDRblock
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
# resource "aws_default_vpc" "default"{

# }

# resource "aws_default_subnet" "default_az1a" {
#   availability_zone = "us-east-1a"
# }

# resource "aws_default_subnet" "default_az1b" {
#   availability_zone = "us-east-1b"
# }

# resource "aws_default_subnet" "default_az1c" {
#   availability_zone = "us-east-1c"
# }

# resource "aws_default_subnet" "default_az1d" {
#   availability_zone = "us-east-1d"
# }

module "vpc" {
  source = "./modules/VPC"
  aws_region = var.region
  vpcCIDRblock = var.vpcCIDRblock
  instanceTenancy = var.instanceTenancy
  dnsSupport = var.dnsSupport
  dnsHostNames = var.dnsHostNames
  subnet_cidrs_public = var.subnet_cidrs_public
  subnet_cidrs_private = var.subnet_cidrs_private
  availability_zones = var.availability_zones
  destinationCIDRblock = var.destinationCIDRblock
  ingressCIDRblock = var.ingressCIDRblock
  mapPublicIP = var.mapPublicIP
}

#####################################
# security
####################################

module "security" {
  source = "./modules/aws-security"
  cluster_name_sg = "OpsSchool-sg"
  vpc_id = module.vpc.vpc_id
}


module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  local_exec_interpreter = var.local_exec_interpreter
  #TODO Ssbnet id
  subnets      = module.vpc.public_subnet_id

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  # TODO Worker group 1
  # One Subnet
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.micro"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id, module.security.aws_ssh_id]
    }

  ]

}