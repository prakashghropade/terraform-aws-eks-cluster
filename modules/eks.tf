resource "aws_eks_cluster" "eks" {

    count = var.is_eks_enabled ? 1 : 0
    name = var.cluster_name
    role_arn = aws_iam_role.eks-cluster-role[count.index].arn
    version = var.eks_version

    vpc_config {
        subnet_ids = [aws_subnet.private[0].id, aws_subnet_private[1].id]
        endpoint_private_access = var.endpoint_private_access
        endpoint_public_access = var.endpoint_public_access
        security_group_ids = [aws_security_group.eks-cluster-sg.id]
    }

    access_config {
        authentication_mode = "CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = true
    }

    tags = {
        Name = var.cluster_name
        env = var.env
    }

}