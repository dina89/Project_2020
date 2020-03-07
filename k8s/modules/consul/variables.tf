variable "region" {
  description = "AWS region for VMs"
  default = "us-east-1"
}

variable "servers" {
  description = "The number of consul servers."
  default = 3
}

variable "clients" {
  description = "The number of consul client instances"
  default = 1
}

variable "consul_version" {
  description = "The version of Consul to install (server and client)."
  default     = "1.4.0"
}

variable "key_name" {
  description = "name of ssh key to attach to hosts"
  default = "radzi"
}

variable "ami" {
  description = "ami to use - based on region"
  default = {
    "us-east-1" = "ami-04b9e92b5572fa0d1"
    "us-east-2" = "ami-0d5d9d301c853a04a"
  }
}

variable "vpc_id" {
  default = "vpc-03736c23a1c90055a"
  description = "ID of vpc to create instances in in the format vpc-xxxxxxxx"
}
