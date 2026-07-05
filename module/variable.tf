# vpc

variable "cluster-name" {
  description = "The name of the cluster"
  type        = string
}

variable "cidr-block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc-name" {
  description = "The name of the VPC"
  type        = string
}

variable "env" {
  description = "The environment name"
  type        = string
}

variable "igw-name" {
  description = "The name of the Internet Gateway"
  type        = string
}

variable "natw-name" {
  description = "The name of the NAT Gateway"
  type        = string
}

variable "pub-subnet-count" {
  description = "The number of public subnets"
  type        = number
}

variable "pub-subnet-cidr-block" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "pub-availability-zones" {
  description = "The availability zones for the public subnets"
  type        = list(string)
}   

variable "pri-subnet-name" {
  description = "The name of the private subnets"
  type        = list(string)
}

variable "pri-subnet-count" {
  description = "The number of private subnets"
  type        = number
}

variable "pri-subnet-cidr-block" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "pri-availability-zones" {
  description = "The availability zones for the private subnets"
  type        = list(string)
}

variable "public-rt-name" {
  description = "The name of the public route table"
  type        = string
}

variable "private-rt-name" {
  description = "The name of the private route table"
  type        = string
}

variable "eks-sg" {
  description = "The name of the EKS security group"
  type        = string
}


# IAM Role
variable "is_eks_role_enabled" {
  description = "Flag to enable or disable the creation of the EKS cluster IAM role"
  type        = bool
}

variable "is_eks_nodegroup_role_enabled" {
  description = "Flag to enable or disable the creation of the EKS node group IAM role"
  type        = bool
}

# eks

variable "is_eks_enabled" {
  description = "Flag to enable or disable the creation of the EKS cluster"
  type        = bool
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

variable "endpoint_private_access" {
  description = "Flag to enable or disable private access to the EKS cluster endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Flag to enable or disable public access to the EKS cluster endpoint"
  type        = bool
}

variable "addons" {
  description = "List of EKS addons to be installed"
  type        = list(object({
    name    = string
    version = string
  }))
}


variable "ondemand_instance_types" {
  description = "List of instance types for the on-demand node group"
  type        = list(string)
}

variable "ondemand_desired_capacity" {
  description = "Desired capacity for the on-demand node group"
  type        = number
}

variable "ondemand_max_size" {
  description = "Maximum size for the on-demand node group"
  type        = number
}

variable "ondemand_min_size" {
  description = "Minimum size for the on-demand node group"
  type        = number
}

variable "spot_instance_types" {
  description = "List of instance types for the spot node group"
  type        = list(string)
}

variable "spot_desired_capacity" {
  description = "Desired capacity for the spot node group"
  type        = number
}

variable "spot_max_size" {
  description = "Maximum size for the spot node group"
  type        = number
}

variable "spot_min_size" {
  description = "Minimum size for the spot node group"
  type        = number
}

