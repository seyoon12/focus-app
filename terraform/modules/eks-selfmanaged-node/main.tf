data "aws_eks_cluster" "selected" {
  name = var.eks_cluster_name
}

data "aws_ec2_instance_type" "selected" {
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "eks_self_managed_node_group" {
  name = "${var.eks_cluster_name}-${local.node_group_name}"

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.eks_self_managed_nodes.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        "Name" = "${var.eks_cluster_name}-${local.node_group_name}"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}


resource "aws_launch_template" "eks_self_managed_nodes" {
  name_prefix = "${var.eks_cluster_name}-${local.node_group_name}"
  description = "Amazon EKS self-managed nodes"

  instance_type          = var.instance_type
  image_id               = data.aws_ami.selected_eks_optimized_ami.id
  ebs_optimized          = data.aws_ec2_instance_type.selected.ebs_optimized_support == "default" ? true : false
  key_name               = var.key_name
  update_default_version = true

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_self_managed_node_group.arn
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = var.eks_cluster_name
    node_labels  = var.node_labels
  }))

  tags = var.tags
}

locals {
  ami_block_device_mappings = {
    for bdm in data.aws_ami.selected_eks_optimized_ami.block_device_mappings : bdm.device_name => bdm
  }
  root_block_device_mapping = local.ami_block_device_mappings[data.aws_ami.selected_eks_optimized_ami.root_device_name]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_self_managed_node_group.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])

    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::535597585675:root"
        username = "root"
        groups   = [
          "system:masters"
        ]
      }
    ])
  }
}