locals {
    cluster_name = var.cluster-name
}

resource "random_integer" "random_suffix"{
    min = 1000
    max = 9999
}

resource "aws_iam_role" "eks-cluster-role"{

    count = var.is_eks_role_enabled ? 1 : 0
    name = "${local.cluster_name}-eks-cluster-role-${random_integer.random_suffix.result}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            }
        ]
    })

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    count = var.is_eks_role_enabled ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks-cluster-role[count.index].name
  
}

resource "aws_iam_role" "eks-nodegroup-role" {
    count = var.is_eks_nodegroup_role_enabled ? 1 : 0
    name = "${local.cluster_name}-eks-nodegroup-role-${random_integer.random_suffix.result}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    count = var.is_eks_nodegroup_role_enabled ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks-nodegroup-role[count.index].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
    count = var.is_eks_nodegroup_role_enabled ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks-nodegroup-role[count.index].name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    count = var.is_eks_nodegroup_role_enabled ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks-nodegroup-role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEBSCSIDriverPolicy" {
    count = var.is_eks_nodegroup_role_enabled ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy"
    role = aws_iam_role.eks-nodegroup-role[count.index].name
}

resource "aws_iam_role" "eks_oidc"{
    name = "eks-oidc"
    assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
}

