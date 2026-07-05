locals {
  org = "ap-medium"
  env = var.env
}

module "eks" {
  source = "../module"

  env                     = var.env
  cluster-name            = "${var.env}-${local.org}-${var.cluster-name}"
  cidr-block              = var.vpc-cidr-block
  vpc-name                = "${var.env}-${local.org}-${var.vpc-name}"
  igw-name                = "${var.env}-${local.org}-${var.igw-name}"
  pub-subnet-count        = var.pub-subnet-count
  pub-subnet-cidr-block  = var.pub-cidr-block
  pub-availability-zones = var.pub-availability-zone
  pri-subnet-count        = var.pri-subnet-count
  pri-subnet-cidr-block  = var.pri-cidr-block
  pri-availability-zones = var.pri-availability-zone
  pri-subnet-name        = ["${var.env}-${local.org}-${var.pri-sub-name}"]
  public-rt-name         = "${var.env}-${local.org}-${var.public-rt-name}"
  private-rt-name        = "${var.env}-${local.org}-${var.private-rt-name}"
  natw-name              = "${var.env}-${local.org}-${var.natw-name}"
  eks-sg                 = var.eks-sg

  is_eks_role_enabled           = true
  is_eks_nodegroup_role_enabled = true

  ondemand_instance_types = var.ondemand_instance_types
  spot_instance_types     = var.spot_instance_types

  ondemand_desired_capacity = var.desired_capacity_on_demand
  ondemand_min_size         = var.min_capacity_on_demand
  ondemand_max_size         = var.max_capacity_on_demand

  spot_desired_capacity = var.desired_capacity_spot
  spot_min_size         = var.min_capacity_spot
  spot_max_size         = var.max_capacity_spot

  is_eks_enabled          = var.is-eks-cluster-enabled
  cluster_version         = var.cluster-version
  endpoint_private_access = var.endpoint-private-access
  endpoint_public_access  = var.endpoint-public-access

  addons = var.addons
}