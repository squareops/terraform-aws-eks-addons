locals {
  namespace       = "kube-system"
  name            = "aws-node-termination-handler"
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  # https://github.com/aws/eks-charts/blob/master/stable/aws-node-termination-handler/Chart.yaml
  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://aws.github.io/eks-charts"
    version     = var.chart_version
    namespace   = local.namespace
    description = "AWS Node Termination Handler Helm Chart"
    values      = local.default_helm_values
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    {
      values = [
        templatefile("${path.module}/config/aws_nth.yaml", {
          enable_service_monitor = var.enable_service_monitor # This line applies configurations only when ADDONS "service_monitor_crd_enabled" is set to false.
        })
      ]
    },
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/config/values.yaml", {
    autoscaling_group_names = var.autoscaling_group_names
  })]

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    { name  = "queueURL"
      value = var.enable_notifications ? aws_sqs_queue.aws_node_termination_handler_queue[0].url : ""
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.aws_node_termination_handler_irsa.arn], var.irsa_policies)
  }

  event_rules = var.enable_notifications ? flatten([
    length(var.autoscaling_group_names) > 0 ?
    [{
      name          = substr("NTHASGTermRule-${var.addon_context.eks_cluster_id}", 0, 63),
      event_pattern = <<EOF
{"source":["aws.autoscaling"],"detail-type":["EC2 Instance-terminate Lifecycle Action"]}
EOF
    }] : [],
    {
      name          = substr("NTHSpotTermRule-${var.addon_context.eks_cluster_id}", 0, 63),
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Spot Instance Interruption Warning"]}
EOF
    },
    {
      name          = substr("NTHRebalanceRule-${var.addon_context.eks_cluster_id}", 0, 63),
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Instance Rebalance Recommendation"]}
EOF
    },
    {
      name          = substr("NTHInstanceStateChangeRule-${var.addon_context.eks_cluster_id}", 0, 63),
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Instance State-change Notification"]}
EOF
    },
    {
      name          = substr("NTHScheduledChangeRule-${var.addon_context.eks_cluster_id}", 0, 63),
      event_pattern = <<EOF
{"source": ["aws.health"],"detail-type": ["AWS Health Event"]}
EOF
    }
  ]) : []
}
