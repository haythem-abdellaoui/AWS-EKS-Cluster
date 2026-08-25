# Rôle IAM pour le Cluster EKS
resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# Security Group pour EKS Control Plane / Workers
resource "aws_security_group" "eks_sg" {
  name        = "eks-sg-${var.environment}"
  description = "Security group for EKS cluster nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg-${var.environment}"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.cluster_name}-${var.environment}"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.eks_sg.id]
  }
}

# Rôle IAM pour les Node Groups
resource "aws_iam_role" "node_role" {
  name = "eks-node-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# EKS Managed Node Group
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main-nodes-${var.environment}"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.small"]
}