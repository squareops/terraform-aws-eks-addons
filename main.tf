data "aws_region" "current" {}

data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

## EBS CSI DRIVER
module "aws-ebs-csi-driver" {
  source                               = "./modules/aws-ebs-csi-driver"
  count                                = var.enable_amazon_eks_aws_ebs_csi_driver || var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0
  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  addon_config = merge(
    {
      kubernetes_version      = local.eks_cluster_version
      additional_iam_policies = [var.kms_policy_arn]
    },
    var.amazon_eks_aws_ebs_csi_driver_config,
  )
  addon_context                          = local.addon_context
  enable_self_managed_aws_ebs_csi_driver = var.enable_self_managed_aws_ebs_csi_driver
  helm_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.self_managed_aws_ebs_csi_driver_helm_config,
  )
  addon_version = var.ebs_csi_driver_version
}

## EFS CSI DRIVER
module "aws-efs-csi-driver" {
  source            = "./modules/aws-efs-csi-driver"
  count             = var.efs_storage_class_enabled ? 1 : 0
  helm_config       = var.aws_efs_csi_driver_helm_config
  irsa_policies     = [var.kms_policy_arn]
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

## EFS FILESYSTEM WITH Storage class
module "aws-efs-filesystem-with-storage-class" {
  source      = "./modules/aws-efs-filesystem-with-storage-class"
  count       = var.efs_storage_class_enabled ? 1 : 0
  name        = var.name
  vpc_id      = var.vpc_id
  environment = var.environment
  kms_key_arn = var.kms_key_arn
  subnets     = var.private_subnet_ids
}

## LOAD BALANCER CONTROLLER
module "aws-load-balancer-controller" {
  source                        = "./modules/aws-load-balancer-controller"
  count                         = (var.aws_load_balancer_controller_enabled || var.k8s_dashboard_ingress_load_balancer == "alb") ? 1 : 0
  helm_config                   = var.aws_load_balancer_controller_helm_config.values
  manage_via_gitops             = var.argocd_manage_add_ons
  addon_context                 = merge(local.addon_context, { default_repository = local.amazon_container_image_registry_uris[data.aws_region.current.name] })
  namespace                     = var.aws_load_balancer_controller_helm_config.namespace
  load_balancer_controller_name = var.aws_load_balancer_controller_helm_config.load_balancer_controller_name
  addon_version                 = var.aws_load_balancer_controller_version
}

## NODE TERMINATION HANDLER
module "aws-node-termination-handler" {
  source     = "./modules/aws-node-termination-handler"
  count      = var.aws_node_termination_handler_enabled ? 1 : 0
  depends_on = [module.service-monitor-crd]
  helm_config = {
    version = var.node_termination_handler_version
    values  = var.aws_node_termination_handler_helm_config.values
  }
  irsa_policies           = var.aws_node_termination_handler_irsa_policies
  autoscaling_group_names = var.auto_scaling_group_names
  addon_context           = local.addon_context
  enable_service_monitor  = var.aws_node_termination_handler_helm_config.enable_service_monitor
  enable_notifications    = var.aws_node_termination_handler_helm_config.enable_notifications
  chart_version           = var.aws_node_termination_handler_version
}

## VPC-CNI
module "aws_vpc_cni" {
  source      = "./modules/aws-vpc-cni"
  count       = var.amazon_eks_vpc_cni_enabled ? 1 : 0
  enable_ipv6 = var.enable_ipv6
  addon_config = merge(
    {
      kubernetes_version      = local.eks_cluster_version
      additional_iam_policies = [var.kms_policy_arn]
      version                 = var.vpc_cni_version
    }
  )
  addon_context = local.addon_context
}

## CERT MANAGER
module "cert-manager" {
  source                            = "./modules/cert-manager"
  count                             = var.cert_manager_enabled ? 1 : 0
  depends_on                        = [module.aws_vpc_cni, module.service-monitor-crd]
  helm_config                       = var.cert_manager_helm_config
  manage_via_gitops                 = var.argocd_manage_add_ons
  irsa_policies                     = var.cert_manager_irsa_policies
  addon_context                     = local.addon_context
  domain_names                      = var.cert_manager_domain_names
  install_letsencrypt_issuers       = var.cert_manager_install_letsencrypt_r53_issuers
  letsencrypt_email                 = var.cert_manager_helm_config.cert_manager_letsencrypt_email
  kubernetes_svc_image_pull_secrets = var.cert_manager_kubernetes_svc_image_pull_secrets
  addon_version                     = var.cert_manager_version
}

## CERT MANAGER LETSENCRYPT
module "cert-manager-le-http-issuer" {
  source                         = "./modules/cert-manager-le-http-issuer"
  count                          = var.cert_manager_enabled ? 1 : 0
  depends_on                     = [module.cert-manager]
  cert_manager_letsencrypt_email = var.cert_manager_helm_config.cert_manager_letsencrypt_email
  ingress_class_name             = var.ingress_nginx_config.ingress_class_name
}

## CLUSTER AUTOSCALER
module "cluster-autoscaler" {
  source              = "./modules/cluster-autoscaler"
  count               = var.cluster_autoscaler_enabled ? 1 : 0
  eks_cluster_version = local.eks_cluster_version
  helm_config = {
    version = var.cluster_autoscaler_chart_version
    values  = var.cluster_autoscaler_helm_config
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  addon_version     = var.cluster_autoscaler_version
}

## COREDNS HPA
module "coredns_hpa" {
  source      = "./modules/core-dns-hpa"
  count       = var.coredns_hpa_enabled ? 1 : 0
  helm_config = var.coredns_hpa_helm_config
}

## CLUSTER PROPORTIONAL AUTOSCALER
module "cluster-proportional-autoscaler" {
  source = "./modules/cluster-proportional-autoscaler"
  count  = var.cluster_proportional_autoscaler_enabled ? 1 : 0
  helm_config = {
    values = var.cluster_proportional_autoscaler_helm_config
  }
  chart_version     = var.cluster_proportional_autoscaler_chart_version
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

## EXTERNAL SECRETS
module "external-secrets" {
  source                                = "./modules/external-secret"
  count                                 = var.external_secrets_enabled ? 1 : 0
  helm_config                           = var.external_secrets_helm_config
  manage_via_gitops                     = var.argocd_manage_add_ons
  addon_context                         = local.addon_context
  irsa_policies                         = var.external_secrets_irsa_policies
  external_secrets_ssm_parameter_arns   = var.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns = var.external_secrets_secrets_manager_arns
  addon_version                         = var.external_secrets_version
}

## NGINX INGRESS
module "ingress-nginx" {
  source                 = "./modules/ingress-nginx"
  count                  = var.ingress_nginx_enabled ? 1 : 0
  depends_on             = [module.aws_vpc_cni, module.service-monitor-crd]
  helm_config            = var.ingress_nginx_config
  manage_via_gitops      = var.argocd_manage_add_ons
  addon_context          = local.addon_context
  ip_family              = data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family
  namespace              = var.ingress_nginx_config.namespace
  private_nlb_enabled    = false
  ingress_class_name     = var.ingress_nginx_config.ingress_class_name
  enable_service_monitor = var.ingress_nginx_config.enable_service_monitor
  subnet_ids             = var.public_subnet_ids
  addon_version          = var.ingress_nginx_version
}

# INGRESS-NGINX DATA SOURCE
data "kubernetes_service" "ingress-nginx" {
  count      = var.ingress_nginx_enabled ? 1 : 0
  depends_on = [module.ingress-nginx]
  metadata {
    name      = "${var.ingress_nginx_config.ingress_class_name}-ingress-nginx-controller"
    namespace = var.ingress_nginx_config.namespace
  }
}

## NGINX INGRESS
module "private-ingress-nginx" {
  source                 = "./modules/ingress-nginx"
  count                  = var.private_ingress_nginx_enabled ? 1 : 0
  depends_on             = [module.aws_vpc_cni, module.service-monitor-crd]
  helm_config            = var.private_ingress_nginx_config
  manage_via_gitops      = var.argocd_manage_add_ons
  addon_context          = local.addon_context
  ip_family              = data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family
  namespace              = var.private_ingress_nginx_config.namespace
  private_nlb_enabled    = true
  ingress_class_name     = var.private_ingress_nginx_config.ingress_class_name
  enable_service_monitor = var.private_ingress_nginx_config.enable_service_monitor
  subnet_ids             = var.private_subnet_ids
  addon_version          = var.private_ingress_nginx_version
}

# INGRESS-NGINX DATA SOURCE
data "kubernetes_service" "private-ingress-nginx" {
  count      = var.private_ingress_nginx_enabled ? 1 : 0
  depends_on = [module.private-ingress-nginx]
  metadata {
    name      = "${var.private_ingress_nginx_config.ingress_class_name}-ingress-nginx-controller"
    namespace = var.private_ingress_nginx_config.namespace
  }
}

## KARPENTER
module "karpenter" {
  source                    = "./modules/karpenter"
  count                     = var.karpenter_enabled ? 1 : 0
  depends_on                = [module.aws_vpc_cni, module.service-monitor-crd]
  worker_iam_role_name      = var.worker_iam_role_name
  eks_cluster_name          = var.eks_cluster_name
  helm_config               = var.karpenter_helm_config
  irsa_policies             = var.karpenter_irsa_policies
  node_iam_instance_profile = var.karpenter_node_iam_instance_profile
  manage_via_gitops         = var.argocd_manage_add_ons
  addon_context             = local.addon_context
  kms_key_arn               = var.karpenter_enabled ? var.kms_key_arn : ""
  enable_service_monitor    = var.karpenter_helm_config.enable_service_monitor
}

## KUBERNETES DASHBOARD
module "kubernetes-dashboard" {
  source                              = "./modules/kubernetes-dashboard"
  count                               = var.kubernetes_dashboard_enabled ? 1 : 0
  depends_on                          = [module.cert-manager-le-http-issuer, module.ingress-nginx, module.private-ingress-nginx, module.aws-load-balancer-controller]
  k8s_dashboard_hostname              = var.kubernetes_dashboard_config.k8s_dashboard_hostname
  alb_acm_certificate_arn             = var.kubernetes_dashboard_config.alb_acm_certificate_arn
  k8s_dashboard_ingress_load_balancer = var.kubernetes_dashboard_config.k8s_dashboard_ingress_load_balancer
  private_alb_enabled                 = var.kubernetes_dashboard_config.private_alb_enabled
  ingress_class_name                  = var.kubernetes_dashboard_config.ingress_class_name
  subnet_ids                          = var.kubernetes_dashboard_config.private_alb_enabled == true ? var.private_subnet_ids : var.public_subnet_ids
  addon_version                       = var.kubernetes_dashboard_version
}

## KEDA

module "keda" {
  source            = "./modules/keda"
  count             = var.keda_enabled ? 1 : 0
  helm_config       = var.keda_helm_config
  irsa_policies     = var.keda_irsa_policies
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

## METRIC SERVER
module "metrics-server" {
  source = "./modules/metrics-server"
  count  = var.metrics_server_enabled ? 1 : 0
  helm_config = {
    version = var.metrics_server_version
    values  = var.metrics_server_helm_config
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

## RELOADER
module "reloader" {
  source     = "./modules/reloader"
  count      = var.reloader_enabled ? 1 : 0
  depends_on = [module.aws_vpc_cni, module.service-monitor-crd]
  helm_config = {
    values                 = var.reloader_helm_config.values
    namespace              = "kube-system"
    create_namespace       = false
    enable_service_monitor = var.reloader_helm_config.enable_service_monitor
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  addon_version     = var.reloader_version
}

## SINGLE AZ SC
module "single-az-sc" {
  for_each                             = { for sc in var.single_az_sc_config : sc.name => sc }
  source                               = "./modules/aws-ebs-storage-class"
  kms_key_id                           = var.kms_key_arn
  availability_zone                    = each.value.zone
  single_az_ebs_gp3_storage_class      = var.single_az_ebs_gp3_storage_class_enabled
  single_az_ebs_gp3_storage_class_name = each.value.name
  tags_all                             = var.tags
}

## SERVICE MONITOR CRD
module "service-monitor-crd" {
  source = "./modules/service-monitor-crd"
  count  = var.service_monitor_crd_enabled ? 1 : 0
}

## VPA-CRDS
module "vpa-crds" {
  source      = "./modules/vpa-crds"
  count       = var.metrics_server_enabled ? 1 : 0
  helm-config = var.vpa_config.values[0]
}

## argocd
resource "kubernetes_namespace" "argocd" {
  count = var.argoworkflow_enabled || var.argocd_enabled || var.argorollout_enabled ? 1 : 0
  metadata {
    name = var.argocd_enabled ? var.argocd_config.namespace : var.argoworkflow_enabled ? var.argoworkflow_config.namespace : var.argorollout_config.namespace
  }
}
module "argocd" {
  source     = "./modules/argocd"
  depends_on = [module.aws_vpc_cni, module.service-monitor-crd, kubernetes_namespace.argocd, module.ingress-nginx, module.private-ingress-nginx, module.aws-load-balancer-controller]
  count      = var.argocd_enabled ? 1 : 0
  argocd_config = {
    hostname                     = var.argocd_config.hostname
    values_yaml                  = var.argocd_config.values_yaml
    redis_ha_enabled             = var.argocd_config.redis_ha_enabled
    autoscaling_enabled          = var.argocd_config.autoscaling_enabled
    slack_notification_token     = var.argocd_config.slack_notification_token
    argocd_notifications_enabled = var.argocd_config.argocd_notifications_enabled
    ingress_class_name           = var.argocd_config.ingress_class_name
    argocd_ingress_load_balancer = var.argocd_config.argocd_ingress_load_balancer
    private_alb_enabled          = var.argocd_config.private_alb_enabled
    alb_acm_certificate_arn      = var.argocd_config.alb_acm_certificate_arn
    subnet_ids                   = var.argocd_config.private_alb_enabled == true ? var.private_subnet_ids : var.public_subnet_ids
    chart_version                = var.argocd_version
  }
  namespace = var.argocd_config.namespace
}

# argo-workflow
module "argocd-workflow" {
  source     = "./modules/argocd-workflow"
  depends_on = [module.aws_vpc_cni, module.service-monitor-crd, kubernetes_namespace.argocd, module.ingress-nginx, module.private-ingress-nginx, module.aws-load-balancer-controller]
  count      = var.argoworkflow_enabled ? 1 : 0
  argoworkflow_config = {
    values                             = var.argoworkflow_config.values
    hostname                           = var.argoworkflow_config.hostname
    ingress_class_name                 = var.argoworkflow_config.ingress_class_name
    autoscaling_enabled                = var.argoworkflow_config.autoscaling_enabled
    argoworkflow_ingress_load_balancer = var.argoworkflow_config.argoworkflow_ingress_load_balancer
    private_alb_enabled                = var.argoworkflow_config.private_alb_enabled
    alb_acm_certificate_arn            = var.argoworkflow_config.alb_acm_certificate_arn
    autoscaling_enabled                = var.argoworkflow_config.autoscaling_enabled
    subnet_ids                         = var.argoworkflow_config.private_alb_enabled == true ? var.private_subnet_ids : var.public_subnet_ids
    chart_version                      = var.argoworkflow_version
  }
  namespace = var.argoworkflow_config.namespace
}

# argo-project
module "argo-project" {
  source     = "./modules/argocd-projects"
  count      = var.argocd_enabled ? 1 : 0
  depends_on = [module.argocd, kubernetes_namespace.argocd]
  name       = var.argoproject_config.name
  namespace  = var.argocd_config.namespace
}

# Argo-Rollout
module "argo-rollout" {
  source     = "./modules/argo-rollout"
  depends_on = [module.aws_vpc_cni, module.service-monitor-crd, kubernetes_namespace.argocd, module.ingress-nginx, module.private-ingress-nginx, module.aws-load-balancer-controller]
  count      = var.argorollout_enabled ? 1 : 0
  argorollout_config = {
    values                            = var.argorollout_config.values
    hostname                          = var.argorollout_config.hostname
    ingress_class_name                = var.argorollout_config.ingress_class_name
    enable_dashboard                  = var.argorollout_config.enable_dashboard
    argorollout_ingress_load_balancer = var.argorollout_config.argorollout_ingress_load_balancer
    private_alb_enabled               = var.argorollout_config.private_alb_enabled
    alb_acm_certificate_arn           = var.argorollout_config.alb_acm_certificate_arn
    subnet_ids                        = var.argorollout_config.private_alb_enabled == true ? var.private_subnet_ids : var.public_subnet_ids
    chart_version                     = var.argorollout_config.chart_version
  }
  namespace = var.argorollout_config.namespace
}

module "velero" {
  source                      = "./modules/velero"
  count                       = var.velero_enabled ? 1 : 0
  name                        = var.name
  region                      = data.aws_region.current.name
  environment                 = var.environment
  velero_config               = var.velero_config
  eks_cluster_id              = var.eks_cluster_name
  velero_notification_enabled = var.velero_notification_enabled
}

##KUBECLARITY
resource "kubernetes_namespace" "kube-clarity" {
  count = var.kubeclarity_enabled ? 1 : 0
  metadata {
    name = var.kubeclarity_namespace
  }
}

resource "random_password" "kube-clarity" {
  count   = var.kubeclarity_enabled ? 1 : 0
  length  = 20
  special = false
}

resource "kubernetes_secret" "kube-clarity" {
  count      = var.kubeclarity_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.kube-clarity]
  metadata {
    name      = "basic-auth"
    namespace = var.kubeclarity_namespace
  }

  data = {
    auth = "admin:${bcrypt(random_password.kube-clarity[0].result)}"
  }

  type = "Opaque"
}

resource "helm_release" "kubeclarity" {
  count      = var.kubeclarity_enabled ? 1 : 0
  name       = "kubeclarity"
  chart      = "kubeclarity"
  version    = var.kubeclarity_version
  namespace  = var.kubeclarity_namespace
  repository = "https://openclarity.github.io/kubeclarity"
  values = [
    templatefile("${path.module}/modules/kubeclarity/values.yaml", {
      hostname  = var.kubeclarity_hostname
      namespace = var.kubeclarity_namespace
    })
  ]
}

#Kubecost

data "aws_eks_addon_version" "kubecost" {
  count              = var.kubecost_enabled ? 1 : 0
  addon_name         = "kubecost_kubecost"
  kubernetes_version = data.aws_eks_cluster.eks.version
  most_recent        = true
}

resource "aws_eks_addon" "kubecost" {
  count                    = var.kubecost_enabled ? 1 : 0
  cluster_name             = var.eks_cluster_name
  addon_name               = "kubecost_kubecost"
  addon_version            = var.kubecost_version
  service_account_role_arn = var.worker_iam_role_arn
  preserve                 = true
}

resource "random_password" "kubecost" {
  count   = var.kubecost_enabled ? 1 : 0
  length  = 20
  special = false
}

resource "kubernetes_secret" "kubecost" {
  count      = var.kubecost_enabled ? 1 : 0
  depends_on = [aws_eks_addon.kubecost]
  metadata {
    name      = "basic-auth"
    namespace = "kubecost"
  }

  data = {
    auth = "admin:${bcrypt(random_password.kubecost[0].result)}"
  }

  type = "Opaque"
}

resource "kubernetes_ingress_v1" "kubecost" {
  count                  = var.kubecost_enabled ? 1 : 0
  depends_on             = [aws_eks_addon.kubecost, kubernetes_secret.kubecost, module.ingress-nginx]
  wait_for_load_balancer = true
  metadata {
    name      = "kubecost"
    namespace = "kubecost"
    annotations = {
      "kubernetes.io/ingress.class"             = var.private_ingress_nginx_enabled ? "private-${var.ingress_nginx_config.ingress_class_name}" : var.ingress_nginx_config.ingress_class_name
      "cert-manager.io/cluster-issuer"          = var.cluster_issuer
      "nginx.ingress.kubernetes.io/auth-type"   = "basic"
      "nginx.ingress.kubernetes.io/auth-secret" = "basic-auth"
      "nginx.ingress.kubernetes.io/auth-realm"  = "Authentication Required - kubecost"
    }
  }
  spec {
    rule {
      host = var.kubecost_hostname
      http {
        path {
          path = "/"
          backend {
            service {
              name = "cost-analyzer-cost-analyzer"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "tls-kubecost"
      hosts       = [var.kubecost_hostname]
    }
  }
}

module "metrics-server-vpa" {
  source     = "./modules/metrics-server-vpa"
  count      = var.metrics_server_enabled ? 1 : 0
  depends_on = [module.vpa-crds]
}

#defectdojo
resource "kubernetes_namespace" "defectdojo" {
  count = var.defectdojo_enabled ? 1 : 0
  metadata {
    name = "defectdojo"
  }
}

resource "helm_release" "defectdojo" {
  count      = var.defectdojo_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.defectdojo]
  name       = "defectdojo"
  namespace  = "defectdojo"
  chart      = "${path.module}/modules/defectdojo/"
  timeout    = 600
  values = [
    templatefile("${path.module}/modules/defectdojo/values.yaml", {
      hostname           = var.defectdojo_hostname,
      storage_class_name = var.storage_class_name
    })
  ]
}

data "kubernetes_secret" "defectdojo" {
  count      = var.defectdojo_enabled ? 1 : 0
  depends_on = [helm_release.defectdojo]
  metadata {
    name      = "defectdojo"
    namespace = "defectdojo"
  }
}

#falco
resource "kubernetes_namespace" "falco" {
  count = var.falco_enabled ? 1 : 0
  metadata {
    name = "falco"
  }
}

resource "helm_release" "falco" {
  count      = var.falco_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.falco]
  name       = "falco"
  namespace  = "falco"
  chart      = "falco"
  repository = "https://falcosecurity.github.io/charts"
  timeout    = 600
  version    = var.falco_version
  values = [
    templatefile("${path.module}/modules/falco/config/values.yaml", {
      slack_webhook = var.slack_webhook
    })
  ]
}
