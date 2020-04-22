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

 resource "aws_iam_role" "eks_role" {
   name = "eks-cluster-eks_role"

   assume_role_policy = <<POLICY
{
   "Version": "2012-10-17",
   "Statement": [
    {
       "Effect": "Allow",
       "Principal":{
         "Service": "ec2.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     }
   ]
 }
 POLICY
 }

 resource "aws_iam_role_policy_attachment" "eks_role-AmazonEKSClusterPolicy" {
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
   role       = aws_iam_role.eks_role.name
 }

  resource "aws_iam_role_policy_attachment" "eks_role-AmazonEKSDescribePolicy" {
   policy_arn = "arn:aws:iam::872527805894:policy/AmazonEKSDescribePolicy"
   role       = aws_iam_role.eks_role.name
 }

 resource "aws_iam_role_policy_attachment" "eks_role-AmazonEKSServicePolicy" {
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
   role       = aws_iam_role.eks_role.name
 }


 resource "aws_iam_instance_profile" "eks_profile" {
  name = "test_profile"
  role = "${aws_iam_role.eks_role.name}"
}


# # Create the helm user-data for the bastion server
# data "template_file" "bastion_server" {
#   template = file("${path.module}/templates/bastion.sh.tpl")

#   vars = {
#     helm_version = var.helm_version
#     consul_helm_version = var.consul_helm_version
#     eks_cluster_name = var.eks_cluster_name
#     consul_secret = var.consul_secret
#   }
# }

 resource "aws_instance" "bastion-host" {
  count = 1
  ami = "ami-024582e76075564db"
  instance_type = "t2.micro"
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids =  module.security.aws_ssh_id
  subnet_id = element(module.vpc.public_subnet_id, count.index)
  iam_instance_profile = aws_iam_instance_profile.eks_profile.name
  associate_public_ip_address = true

    provisioner "file" {
    source      = "values.yaml"
    destination = "/tmp/values.yaml"
    }

    tags = {
    Name = "bastion"
    }

    provisioner "remote-exec"{

      inline = [
          "sudo apt-get install unzip",
          "curl 'https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
          "unzip awscliv2.zip",
          "sudo ./aws/install",
          "curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl",
          "chmod +x ./kubectl",
          "sudo mv ./kubectl /usr/local/bin/kubectl",
          "aws eks --region us-east-1 update-kubeconfig --name opsSchool-eks-dina",
          "curl -Ssl https://get.helm.sh/helm-v3.2.0-rc.1-linux-amd64.tar.gz -o helm-v3.2.0-rc.1-linux-amd64.tar.gz",
          "tar -zxvf helm-v3.2.0-rc.1-linux-amd64.tar.gz",
          "sudo mv linux-amd64/helm /usr/local/bin/helm",
          "git clone --single-branch --branch v0.19.0 https://github.com/hashicorp/consul-helm.git",
          "kubectl create secret generic consul-gossip-encryption-key --from-literal=key=\"uDBV4e+LbFW3019YKPxIrg==\"",
          "sudo cp /tmp/values.yaml ./consul-helm/values.yaml",
          "helm install hashicorp ./consul-helm",
          "git clone https://github.com/helm/charts.git",
          "helm install opsschool-nodeexporter ./charts/stable/prometheus-node-exporter"
      ]
  }

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ubuntu"
      private_key = tls_private_key.bastion_key.private_key_pem
  }

  depends_on = [module.eks]

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


locals {
  cluster_name = "opsSchool-eks-dina"
}


# CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [var.vpcCIDRblock]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

    ingress {
    from_port   = 8502
    to_port     = 8502
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow consul access from the vpc"
  }

    ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow prometheus access from the vpc"
  }
  
    ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.vpcCIDRblock]
    description = "Allow prometheus access from the vpc"
  }

}

#####################################
# vpc
####################################

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
  eks_cluster_name = local.cluster_name
}

#####################################
# security
####################################

module "security" {
  source = "./modules/aws-security"
  cluster_name_sg = "OpsSchool-sg"
  vpc_id = module.vpc.vpc_id
  ingressCIDRblock = var.ingressCIDRblock
}

#####################################
# consul & promcol
####################################

module "consul" {
   source = "./modules/consul"
   region = var.region
   vpc_id = module.vpc.vpc_id
   key_name = aws_key_pair.consul_key.key_name
   ingressCIDRblock = "${concat(var.ingressCIDRblock, [join("", [var.vpcCIDRblock])], [join("",[element(module.grafana.grafana, 0), "/32"])])}"
   subnet_id = element(module.vpc.public_subnet_id, 0)
 }

#####################################
# grafana
####################################

module "grafana" {
   source = "./modules/grafana"
   region = var.region
   vpc_id = module.vpc.vpc_id
   key_name = aws_key_pair.grafana_key.key_name
   ingressCIDRblock = "${concat(var.ingressCIDRblock, [join("", [var.vpcCIDRblock])])}"
   subnet_id = element(module.vpc.public_subnet_id, 0)
   prometheus_ip = element(module.consul.promcol, 0)
 }

provider "grafana" {
  url  = "http://${element(module.grafana.grafana, 0)}:3000"
  auth = "admin:admin"
}

resource "grafana_data_source" "prometheus" {
  type          = "Prometheus"
  name          = "opsschool_prometheus"
  url           = "http://${element(module.consul.promcol, 0)}:9090"
}

#####################################
# eks
####################################

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  local_exec_interpreter = var.local_exec_interpreter
  map_users              = "${concat(var.map_users, 
                                      [{
                                        userarn  = aws_iam_role.eks_role.arn
                                        username = aws_iam_role.eks_role.name
                                        groups =  ["system:masters"]
                                      }]
                                      )}"


  #TODO Ssbnet id
  subnets      = module.vpc.private_subnet_id

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
      instance_type                 = "t3.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }

  ]

}