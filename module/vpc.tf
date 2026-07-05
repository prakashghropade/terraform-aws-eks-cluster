locals {
    cluster-name = var.cluster-name
}

resource "aws_vpc" "vpc" {

    cidr_block = var.cidr-block
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "${local.cluster-name}-vpc"
    }

}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = var.igw-name
        env = var.env
        "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    }

    depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "public" {
    count = var.pub-subnet-count
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.pub-subnet-cidr-block, count.index)
    availability_zone = element(var.pub-availability-zones, count.index)
    map_public_ip_on_launch = true

    tags = {
        Name = "${local.cluster-name}-public-subnet-${count.index + 1}"
        env = var.env
        "kubernetes.io/cluster/${local.cluster-name}" = "owned"
        "kubernetes.io/role/elb" = "1"
    }

    depends_on = [aws_vpc.vpc]

}

resource "aws_subnet" "private" {
    count = var.pri-subnet-count
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.pri-subnet-cidr-block, count.index)
    availability_zone = element(var.pri-availability-zones, count.index)
    map_public_ip_on_launch = false

    tags = {
        Name = "${local.cluster-name}-private-subnet-${count.index + 1}"
        env = var.env
        "kubernetes.io/cluster/${local.cluster-name}" = "owned"
        "kubernetes.io/role/internal-elb" = "1"
    }

    depends_on = [aws_vpc.vpc]
}

resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags ={ 
        Name = var.public-rt-name
        env = var.env
    }

    depends_on = [aws_vpc.vpc]

}

resource "aws_route_table_association" "public-rt-assoc" {
    count = var.pub-subnet-count
    route_table_id = aws_route_table.public-rt.id
    subnet_id = element(aws_subnet.public.*.id, count.index)

    depends_on = [aws_vpc.vpc, aws_subnet.public]
}

resource "aws_eip" "natw" {
    domain = "vpc"

    tags = {
        Name = var.natw-name
    }

    depends_on = [aws_vpc.vpc]
}

resource "aws_nat_gateway" "natw" {
    allocation_id = aws_eip.natw.id
    subnet_id = aws_subnet.public[0].id

    tags = {
        Name = var.natw-name
    }

    depends_on = [ aws_vpc.vpc, aws_subnet.public, aws_eip.natw]

}

resource "aws_route_table" "private-rt" {

    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natw.id
    }

    tags = {
        Name = var.private-rt-name
        env = var.env
    }

}


resource "aws_route_table_association" "private-rt-assoc" {
    count = var.pri-subnet-count
    route_table_id = aws_route_table.private-rt.id
    subnet_id = aws_subnet.private[count.index].id

    depends_on = [aws_vpc.vpc, aws_subnet.private]
}

resource "aws_security_group" "eks-cluster-sg" {
    name = var.eks-sg
    description = "Security group for Jump server only"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = var.eks-sg
    }

    depends_on = [aws_vpc.vpc]
}
