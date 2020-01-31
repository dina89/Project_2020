

variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "availability_zones" {
  description = "AZs in this region to use"
  type        = list(string)
}
variable "instanceTenancy" {
 type        = string
}
variable "dnsSupport" {
 type        = bool
}
variable "dnsHostNames" {
  type        = bool
}
variable "vpcCIDRblock" {
 type        = string
}
variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  type        = list(string)
}
variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
  type        = list(string)
}
variable "destinationCIDRblock" {
  type        = string
}
variable "ingressCIDRblock" {
  type        = list(string)
}
variable "mapPublicIP" {
  type        = bool
}
