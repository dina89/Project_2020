terraform {
  required_version = ">= 0.12.0"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

# variable vpc_id {
#   description = "AWS VPC id"
#   default     = "vpc-03736c23a1c90055a"
# }

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22]
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default = ["us-east-1a", "us-east-1c"]
  type = "list"
}


variable "instanceTenancy" {
 default = "default"
}
variable "dnsSupport" {
 default = true
}
variable "dnsHostNames" {
        default = true
}

variable "vpcCIDRblock" {
 default = "10.0.0.0/16"
}
variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default = ["10.0.10.0/24", "10.0.20.0/24"]
  type = "list"
}
variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = "list"
}
variable "destinationCIDRblock" {
        default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
        type =  list(string)
        default = [ "85.250.123.80/32" ]
}
variable "mapPublicIP" {
        default = true
}

 variable "local_exec_interpreter" {
   description = "Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice."
   type        = list(string)
   default     = ["sh.exe" , "-c"]
 }


variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::872527805894:user/terraform-jenkins"
      username = "terraform-jenkins"
      groups =  ["system:masters"]
    }

  ]
}

variable "helm_version" {
  default = "3.2.0-rc.1"
}

variable "consul_helm_version" {
  default = "0.19.0"
}

variable "eks_cluster_name" {
  default = "opsSchool-eks-dina"
}

variable "consul_secret" {
  default = "uDBV4e+LbFW3019YKPxIrg=="
}
