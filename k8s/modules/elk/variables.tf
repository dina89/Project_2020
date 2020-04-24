variable "region" {
  description = "AWS region for VMs"
  default = "us-east-1"
}

variable "key_name" {
  description = "name of ssh key to attach to hosts"
  default = "Dinas"
}

variable "ami" {
  description = "ami to use - based on region"
  default = {
    "us-east-1" = "ami-04b9e92b5572fa0d1"
    "us-east-2" = "ami-0d5d9d301c853a04a"
  }
}

variable "vpc_id" {
  description = "vpc_id for the servers"
  type = "string"
}

variable "subnet_id" {
  description = "subnet_id for the servers"
  type = "string"
}

variable "ingressCIDRblock" {
  type        = list(string)
}
