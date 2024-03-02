resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_elb_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ebscsi_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

  
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28"

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_cloudwatch_log_group.eks_cluster,
  ]

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster-name}/cluster"
  retention_in_days = 7
  tags = {
    Name = "${var.cluster-name}-logs"
  }
}

  resource "aws_eks_addon" "coredns" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    addon_name   = "coredns"
    depends_on = [aws_eks_node_group.eks_node_group]
  }

  resource "aws_eks_addon" "vpc_cni" {
    depends_on = [ aws_eks_cluster.eks_cluster ]
    cluster_name = aws_eks_cluster.eks_cluster.name
    addon_name   = "vpc-cni"
  }

  resource "aws_eks_addon" "kube_proxy" {
    depends_on = [ aws_eks_cluster.eks_cluster ]
    cluster_name = aws_eks_cluster.eks_cluster.name
    addon_name   = "kube-proxy"
  }

resource "aws_iam_role" "ebs_csi_driver" {
    name = "eks-ebs-csi-driver-role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = aws_iam_openid_connect_provider.eks_oidc.arn
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
              "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
            }
          }
        },
      ]
    })
  }

  resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
    role       = aws_iam_role.ebs_csi_driver.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  resource "aws_eks_addon" "ebs_csi_driver" {
    depends_on             = [aws_eks_cluster.eks_cluster, aws_iam_openid_connect_provider.eks_oidc]
    cluster_name           = aws_eks_cluster.eks_cluster.name
    service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
    addon_name             = "aws-ebs-csi-driver"
  }

  resource "aws_eks_node_group" "eks_node_group" {
    depends_on = [ aws_eks_cluster.eks_cluster ]
    node_group_name = "eks_node_group"
    cluster_name    = aws_eks_cluster.eks_cluster.name
    node_role_arn   = aws_iam_role.eks_worker_role.arn
    subnet_ids      = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

    scaling_config {
      desired_size = 1
      max_size     = 2
      min_size     = 1
    }

    ami_type       = "AL2023_ARM_64_STANDARD"
    instance_types = ["t4g.medium"]
    disk_size      = 20

    tags = {
      Name = "eks-node-group"
      "kubernetes.io/cluster/${var.cluster-name}" = "owned"
    }
  }

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  depends_on = [aws_eks_cluster.eks_cluster]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}