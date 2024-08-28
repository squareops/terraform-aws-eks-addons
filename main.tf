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
  count                         = var.aws_load_balancer_controller_enabled || var.k8s_dashboard_ingress_load_balancer == "alb" ? 1 : 0
  helm_config                   = var.aws_load_balancer_controller_helm_config.values
  manage_via_gitops             = var.argocd_manage_add_ons
  addon_context                 = merge(local.addon_context, { default_repository = local.amazon_container_image_registry_uris[data.aws_region.current.name] })
  namespace                     = var.aws_load_balancer_controller_helm_config.namespace
  load_balancer_controller_name = var.aws_load_balancer_controller_helm_config.load_balancer_controller_name
}

## NODE TERMINATION HANDLER
module "aws-node-termination-handler" {
  source = "./modules/aws-node-termination-handler"
  count  = var.aws_node_termination_handler_enabled ? 1 : 0
  helm_config = {
    version = var.node_termination_handler_version
    values  = var.aws_node_termination_handler_helm_config.values
  }
  irsa_policies           = var.aws_node_termination_handler_irsa_policies
  autoscaling_group_names = var.auto_scaling_group_names
  addon_context           = local.addon_context
  enable_service_monitor  = var.aws_node_termination_handler_helm_config.enable_service_monitor
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
    }
  )
  addon_context = local.addon_context
}

## CERT MANAGER
module "cert-manager" {
  source                            = "./modules/cert-manager"
  count                             = var.cert_manager_enabled ? 1 : 0
  helm_config                       = var.cert_manager_helm_config
  manage_via_gitops                 = var.argocd_manage_add_ons
  irsa_policies                     = var.cert_manager_irsa_policies
  addon_context                     = local.addon_context
  domain_names                      = var.cert_manager_domain_names
  install_letsencrypt_issuers       = var.cert_manager_install_letsencrypt_r53_issuers
  letsencrypt_email                 = var.cert_manager_helm_config.cert_manager_letsencrypt_email
  kubernetes_svc_image_pull_secrets = var.cert_manager_kubernetes_svc_image_pull_secrets
}

## CERT MANAGER LETSENCRYPT
module "cert-manager-le-http-issuer" {
  source                         = "./modules/cert-manager-le-http-issuer"
  count                          = var.cert_manager_enabled ? 1 : 0
  depends_on                     = [module.cert-manager]
  cert_manager_letsencrypt_email = var.cert_manager_helm_config.cert_manager_letsencrypt_email
  ingress_class_name             = var.private_nlb_enabled ? "internal-${var.ingress_nginx_config.ingress_class_name}" : var.ingress_nginx_config.ingress_class_name
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
}

## COREDNS HPA
module "coredns_hpa" {
  source      = "./modules/core-dns-hpa"
  count       = var.coredns_hpa_enabled ? 1 : 0
  helm_config = var.coredns_hpa_helm_config
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
}

## NGINX INGRESS
module "ingress-nginx" {
  source            = "./modules/ingress-nginx"
  count             = var.ingress_nginx_enabled ? 1 : 0
  depends_on        = [module.aws_vpc_cni, module.service-monitor-crd]
  helm_config       = var.ingress_nginx_config
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  ip_family         = data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family

  # Template values for ingress-nginx and private-internal-nginx
  namespace              = var.ingress_nginx_config.namespace
  private_nlb_enabled    = var.private_nlb_enabled
  ingress_class_name     = var.private_nlb_enabled ? "internal-${var.ingress_nginx_config.ingress_class_name}" : var.ingress_nginx_config.ingress_class_name
  enable_service_monitor = var.ingress_nginx_config.enable_service_monitor
  tag_product                = var.tag_product
  tag_environment            = var.tag_environment
}

# INGRESS-NGINX DATA SOURCE
data "kubernetes_service" "ingress-nginx" {
  count      = var.ingress_nginx_enabled ? 1 : 0
  depends_on = [module.ingress-nginx]
  metadata {
    name      = var.private_nlb_enabled ? "internal-${var.ingress_nginx_config.ingress_class_name}-ingress-nginx-controller" : "${var.ingress_nginx_config.ingress_class_name}-ingress-nginx-controller"
    namespace = var.ingress_nginx_config.namespace
  }
}

## KARPENTER
module "karpenter" {
  source                    = "./modules/karpenter"
  count                     = var.karpenter_enabled ? 1 : 0
  worker_iam_role_name      = var.worker_iam_role_name
  eks_cluster_name          = var.eks_cluster_name
  helm_config               = var.karpenter_helm_config
  irsa_policies             = var.karpenter_irsa_policies
  node_iam_instance_profile = var.karpenter_node_iam_instance_profile
  manage_via_gitops         = var.argocd_manage_add_ons
  addon_context             = local.addon_context
  kms_key_arn               = var.karpenter_enabled ? var.kms_key_arn : ""
}

## Karpenter-provisioner
module "karpenter-provisioner" {
  source           = "./modules/karpenter-provisioner"
  count            = var.karpenter_provisioner_enabled ? 1 : 0
  depends_on       = [module.karpenter]
  ipv6_enabled     = var.ipv6_enabled
  karpenter_config = var.karpenter_provisioner_config
  tag_product                = var.tag_product
  tag_environment            = var.tag_environment
}

## KUBERNETES DASHBOARD
module "kubernetes-dashboard" {
  source                              = "./modules/kubernetes-dashboard"
  count                               = var.kubernetes_dashboard_enabled ? 1 : 0
  depends_on                          = [module.cert-manager-le-http-issuer, module.ingress-nginx, module.service-monitor-crd]
  k8s_dashboard_hostname              = var.kubernetes_dashboard_config.k8s_dashboard_hostname
  alb_acm_certificate_arn             = var.kubernetes_dashboard_config.alb_acm_certificate_arn
  k8s_dashboard_ingress_load_balancer = var.kubernetes_dashboard_config.k8s_dashboard_ingress_load_balancer
  private_alb_enabled                 = var.kubernetes_dashboard_config.private_alb_enabled
  ingress_class_name                  = var.private_nlb_enabled ? "internal-${var.ingress_nginx_config.ingress_class_name}" : var.ingress_nginx_config.ingress_class_name
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
    version = var.metrics_server_helm_version
    values  = var.metrics_server_helm_config
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

## RELOADER
module "reloader" {
  source = "./modules/reloader"
  count  = var.reloader_enabled ? 1 : 0
  helm_config = {
    values                 = var.reloader_helm_config.values
    namespace              = "kube-system"
    create_namespace       = false
    enable_service_monitor = var.reloader_helm_config.enable_service_monitor
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

## SINGLE AZ SC
module "single-az-sc" {
  for_each                             = { for sc in var.single_az_sc_config : sc.name => sc }
  source                               = "./modules/aws-ebs-storage-class"
  kms_key_id                           = var.kms_key_arn
  availability_zone                    = each.value.zone
  single_az_ebs_gp3_storage_class      = var.single_az_ebs_gp3_storage_class_enabled
  single_az_ebs_gp3_storage_class_name = each.value.name
  tag_product                = var.tag_product
  tag_environment            = var.tag_environment
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
  version    = "2.23.0"
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
  addon_version            = data.aws_eks_addon_version.kubecost[0].version
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
      "kubernetes.io/ingress.class"             = var.private_nlb_enabled ? "internal-${var.ingress_nginx_config.ingress_class_name}" : var.ingress_nginx_config.ingress_class_name
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
  version    = "4.0.0"
  values = [
    templatefile("${path.module}/modules/falco/config/values.yaml", {
      slack_webhook = var.slack_webhook
    })
  ]
}
