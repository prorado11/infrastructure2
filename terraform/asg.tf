locals {

  eks_asg_tag_list_nodegroup1 = {
    "k8s.io/cluster-autoscaler/enabled" : true
    "k8s.io/cluster-autoscaler/${local.name}" : "owned"
    "k8s.io/cluster-autoscaler/node-template/label/role" : local.nodegroup1_label
    # "k8s.io/cluster-autoscaler/node-template/taint/dedicated" : "${local.nodegroup1_label}:NoSchedule"
  }

#   eks_asg_tag_list_nodegroup2 = {
#     "k8s.io/cluster-autoscaler/enabled" : true
#     "k8s.io/cluster-autoscaler/${local.name}" : "owned"
#     "k8s.io/cluster-autoscaler/node-template/label/role" : local.nodegroup2_label
#     "k8s.io/cluster-autoscaler/node-template/taint/dedicated" : "${local.nodegroup2_label}:NoSchedule"
#   }
  name =  "312-asg"
  region = "us-east-1"
  nodegroup1_label = "cpu-micro"
  
}

resource "aws_autoscaling_group_tag" "nodegroup1" {
  for_each               = local.eks_asg_tag_list_nodegroup1
  autoscaling_group_name = "eks-managed-nodes-42c6d2e2-3ea7-4544-29df-c97735c39f49" // need to fix this to variables

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}

# resource "aws_autoscaling_group_tag" "nodegroup2" {
#   for_each               = local.eks_asg_tag_list_nodegroup2
#   autoscaling_group_name = element(module.eks.eks_managed_node_groups_autoscaling_group_names, 1)

#   tag {
#     key                 = each.key
#     value               = each.value
#     propagate_at_launch = true
#   }
# }

locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "demo-autoscaler"
}

resource "helm_release" "cluster-autoscaler" {
  name             = "cluster-autoscaler"
  namespace        = local.k8s_service_account_namespace
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.35.0"
  create_namespace = false

  set {
    name  = "awsRegion"
    value = local.region
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = local.name
  }
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
}

