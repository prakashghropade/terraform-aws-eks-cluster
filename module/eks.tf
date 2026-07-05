resource "aws_eks_cluster" "eks" {

    count = var.is_eks_enabled ? 1 : 0
    name = var.cluster-name
    role_arn = aws_iam_role.eks-cluster-role[count.index].arn
    version = var.cluster_version

    vpc_config {
        subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
        endpoint_private_access = var.endpoint_private_access
        endpoint_public_access = var.endpoint_public_access
        security_group_ids = [aws_security_group.eks-cluster-sg.id]
    }

    access_config {
        authentication_mode = "CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = true
    }

    tags = {
        Name = var.cluster-name
        env = var.env
    }

}

data "tls_certificate" "eks" {
    count = var.is_eks_enabled ? 1 : 0
    url = aws_eks_cluster.eks[count.index].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-oidc" {
    count = var.is_eks_enabled ? 1 : 0

    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks[count.index].certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.eks[count.index].identity[0].oidc[0].issuer
}

resource "aws_eks_addons" "eks-addons" {
    for_each = { for idx, addon in var.addons : idx => addon }
    cluster_name = aws_eks_cluster.eks[0].name
    addon_name = each.value.name
    addon_version = each.value.version

    depends_on = [
        aws_eks_node_group.ondemand-nodes,
        aws_eks_node_group.spot-nodes
    ]
}

resource  "aws_eks_node_group" "ondemand-nodes" {
    count = var.is_eks_enabled ? 1 : 0
    cluster_name = aws_eks_cluster.eks[0].name
    node_group_name = "${var.cluster-name}-ondemand-nodes"
    node_role_arn = aws_iam_role.eks-nodegroup-role[count.index].arn
    subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]

    scaling_config {
        desired_size = var.ondemand_desired_capacity
        max_size = var.ondemand_max_size
        min_size = var.ondemand_min_size
    }

    update_config {
        max_unavailable = 1
    }

    instance_types = var.ondemand_instance_types
    capacity_type = "ON_DEMAND"

    labels = {
        type = "ondemand"
    }

    tags = {
        Name = "${var.cluster-name}-ondemand-nodes"
        env = var.env 
    }

    depends_on = [
        aws_eks_cluster.eks]
}

resource  "aws_eks_node_group" "spot-nodes" {
    count = var.is_eks_enabled ? 1 : 0
    cluster_name = aws_eks_cluster.eks[0].name
    node_group_name = "${var.cluster-name}-spot-nodes"
    
    node_role_arn = aws_iam_role.eks-nodegroup-role[count.index].arn
    subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]

    scaling_config {
        desired_size = var.spot_desired_capacity
        max_size = var.spot_max_size
        min_size = var.spot_min_size
    }

    update_config {
        max_unavailable = 1
    }

    instance_types = var.spot_instance_types
    capacity_type = "SPOT"

    labels = {
        type = "spot"
    }

    tags = {
        Name = "${var.cluster-name}-spot-nodes"
        env = var.env
    }

    disk_size = 50

      depends_on = [
        aws_eks_cluster.eks]
}
