data "aws_region" "current" {}

data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

module "service-monitor-crd" {
  count  = var.service_monitor_crd_enabled ? 1 : 0
  source = "./modules/service-monitor-crd"
}

module "aws_vpc_cni" {
  source = "./modules/aws-vpc-cni"

  count = var.amazon_eks_vpc_cni_enabled ? 1 : 0

  enable_ipv6 = var.enable_ipv6
  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
      additional_iam_policies = [var.kms_policy_arn]
    },
    var.amazon_eks_vpc_cni_config,
  )

  addon_context = local.addon_context
}
module "aws_ebs_csi_driver" {
  source = "./modules/aws-ebs-csi-driver"

  count = var.enable_amazon_eks_aws_ebs_csi_driver || var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0

  # Amazon EKS aws-ebs-csi-driver addon
  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_aws_ebs_csi_driver_config,
  )

  addon_context = local.addon_context

  # Self-managed aws-ebs-csi-driver addon via Helm chart
  enable_self_managed_aws_ebs_csi_driver = var.enable_self_managed_aws_ebs_csi_driver
  helm_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.self_managed_aws_ebs_csi_driver_helm_config,
  )
}



module "karpenter" {
  count       = var.karpenter_enabled ? 1 : 0
  source = "./modules/karpenter"
  worker_iam_role_name = var.worker_iam_role_name
  eks_cluster_name = var.eks_cluster_name
  helm_config               = var.karpenter_helm_config
  irsa_policies             = var.karpenter_irsa_policies
  node_iam_instance_profile = var.karpenter_node_iam_instance_profile
  manage_via_gitops         = var.argocd_manage_add_ons
  addon_context             = local.addon_context
  eks_cluster_endpoint = data.aws_eks_cluster.eks.endpoint
  eks_cluster_id = var.eks_cluster_name
  environment = var.environment
  name = var.name
}

## AWS LOAD BALANCER 
module "aws-load-balancer-controller" {
  count             = var.aws_load_balancer_controller_enabled ? 1 : 0
  source= "./modules/aws-load-balancer-controller"
  helm_config       = {
    version = var.aws_load_balancer_version
    values = var.aws_load_balancer_controller_helm_config.values
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = merge(local.addon_context, { default_repository = local.amazon_container_image_registry_uris[data.aws_region.current.name] })
}

## NODE TERMIANTION HANDLER
module "aws-node-termination-handler" {
  count                   = var.aws_node_termination_handler_enabled ? 1 : 0
  source                  = "./modules/aws-node-termination-handler"
  helm_config             =  {
    version = var.node_termination_handler_version
    values = var.aws_node_termination_handler_helm_config
  }
  irsa_policies           = var.aws_node_termination_handler_irsa_policies
  autoscaling_group_names = var.auto_scaling_group_names
  addon_context           = local.addon_context
  enable_service_monitor = var.enable_service_monitor
}


## CERT MANAGER
module "cert-manager" {
  count                             = var.cert_manager_enabled ? 1 : 0
  source                            = "./modules/cert-manager"
  helm_config                       =  var.cert_manager_helm_config
  manage_via_gitops                 = var.argocd_manage_add_ons
  irsa_policies                     = var.cert_manager_irsa_policies
  addon_context                     = local.addon_context
  domain_names                      = var.cert_manager_domain_names
  install_letsencrypt_issuers       = var.cert_manager_install_letsencrypt_r53_issuers
  letsencrypt_email                 = var.cert_manager_letsencrypt_email
  kubernetes_svc_image_pull_secrets = var.cert_manager_kubernetes_svc_image_pull_secrets
}

## Cert Managwer le-http-issuer
module "cert-manager-le-http-issuer" {
  count      = var.cert_manager_install_letsencrypt_http_issuers ? 1 : 0
  source = "./modules/cert-manager-le-http-issuer"
  depends_on = [ module.cert-manager ]
  cert_manager_letsencrypt_email = var.cert_manager_letsencrypt_email
}

## CLUSTER AUTOSCALER
module "cluster-autoscaler" {
  source = "./modules/cluster-autoscaler"

  count = var.cluster_autoscaler_enabled ? 1 : 0

  eks_cluster_version = local.eks_cluster_version
  helm_config         = {
    version = var.cluster_autoscaler_chart_version
    values = var.cluster_autoscaler_helm_config
  }
  manage_via_gitops   = var.argocd_manage_add_ons
  addon_context       = local.addon_context
}


## EXTERNAL SECRET
module "external-secrets" {
  source = "./modules/external-secret"
  count = var.external_secrets_enabled ? 1 : 0

  helm_config                           = var.external_secrets_helm_config
  manage_via_gitops                     = var.argocd_manage_add_ons
  addon_context                         = local.addon_context
  irsa_policies                         = var.external_secrets_irsa_policies
  external_secrets_ssm_parameter_arns   = var.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns = var.external_secrets_secrets_manager_arns
}


## RELOADER
module "reloader" {
  count             = var.reloader_enabled ? 1 : 0
  source            = "./modules/reloader"
  helm_config       = {
    values = var.reloader_helm_config
    namespace        = "kube-system"
    create_namespace = false
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}


## METRIC SERVER
module "metrics-server" {
  count             = var.metrics_server_enabled ? 1 : 0
  source            = "./modules/metrics-server"
  helm_config       = {
    version = var.metrics_server_helm_version
    values  = var.metrics_server_helm_config
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}
module "vpa-crds" {
  count      = var.metrics_server_enabled ? 1 : 0
  source = "./modules/vpa-crds"
  helm-config = var.vpa_config.values[0]
}

## Coredns Hpa
module "coredns_hpa" {
  count     = var.coredns_hpa_enabled ? 1 : 0
  source = "./modules/core-dns-hpa"  # Replace with the actual path to your module
  helm_config = var.coredns_hpa_helm_config
}

## EFS CSI DRIVER
module "aws-efs-csi-driver" {
  count             = var.efs_storage_class_enabled ? 1 : 0
  source            = "./modules/aws-efs-csi-driver"
  helm_config       = var.aws_efs_csi_driver_helm_config
  irsa_policies     = var.aws_efs_csi_driver_irsa_policies
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}

## INTERNAL NGINX INGRESS
module "internal-nginx-ingress" {
  count = var.internal_ingress_nginx_enabled ? 1 : 0
  source            = "./modules/internal-nginx-ingress"
  ip_family = data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family
  internal_ingress_config = var.internal_nginx_config.values
  enable_service_monitor = var.enable_service_monitor
}

# NGINX INGRESS
module "ingress-nginx" {
  count             = var.enable_ingress_nginx ? 1 : 0
  source            = "./modules/nginx-ingress"
  helm_config       = var.ingress_nginx_helm_config.values
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
  enable_service_monitor = var.ingress_nginx_helm_config.enable_service_monitor
}

## EFS Storage class
module "aws-efs-storage-class" {
  source      = "./modules/aws-efs-storage-class"
  count       = var.efs_storage_class_enabled ? 1 : 0
  name        = var.name
  vpc_id      = var.vpc_id
  environment = var.environment 
  kms_key_arn = var.kms_key_arn
  subnets     = var.private_subnet_ids
}

## Karpenter-provisioner
module "karpenter-provisioner" {
  depends_on = [ module.karpenter ]
  source                               = "./modules/karpenter-provisioner"
  count                                = var.karpenter_provisioner_enabled ? 1 : 0
  ipv6_enabled                         = var.ipv6_enabled
  sg_selector_name                     = var.eks_cluster_name
  subnet_selector_name                 = var.karpenter_provisioner_config.private_subnet_name
  karpenter_ec2_capacity_type          = var.karpenter_provisioner_config.instance_capacity_type
  excluded_karpenter_ec2_instance_type = var.karpenter_provisioner_config.excluded_instance_type
  instance_hypervisor                  = var.karpenter_provisioner_config.instance_hypervisor
}

#OPEN: Default label needs to be removed from gp2 storageclass in order to make gp3 as default choice for EBS volume provisioning.
module "single-az-sc" {
  for_each                             = { for sc in var.single_az_sc_config : sc.name => sc }
  source                               = "./modules/aws-ebs-storage-class"
  kms_key_id                           = var.kms_key_arn
  availability_zone                    = each.value.zone
  single_az_ebs_gp3_storage_class      = var.single_az_ebs_gp3_storage_class_enabled
  single_az_ebs_gp3_storage_class_name = each.value.name
}

# module "velero" {
#   source        = "./modules/velero"
#   name          = var.name
#   count         = var.velero_enabled ? 1 : 0
#   region        = data.aws_region.current.name
#   cluster_id    = var.eks_cluster_name
#   environment   = var.environment
#   velero_config = var.velero_config
# }

# module "istio" {
#   depends_on                     = [module.cert-manager-le-http-issuer]
#   source                         = "./modules/istio"
#   count                          = var.istio_enabled ? 1 : 0
#   ingress_gateway_enabled        = var.istio_config.ingress_gateway_enabled
#   ingress_gateway_namespace      = var.istio_config.ingress_gateway_namespace
#   egress_gateway_enabled         = var.istio_config.egress_gateway_enabled
#   egress_gateway_namespace       = var.istio_config.egress_gateway_namespace
#   envoy_access_logs_enabled      = var.istio_config.envoy_access_logs_enabled
#   prometheus_monitoring_enabled  = var.istio_config.prometheus_monitoring_enabled
#   cert_manager_letsencrypt_email = var.cert_manager_letsencrypt_email
#   istio_values_yaml              = var.istio_config.istio_values_yaml
# }

# data "kubernetes_service" "istio-ingress" {
#   count      = var.istio_enabled ? 1 : 0
#   depends_on = [module.istio]
#   metadata {
#     name      = "istio-ingressgateway"
#     namespace = var.istio_config.ingress_gateway_namespace
#   }
# }




# ##KUBECLARITY
# resource "kubernetes_namespace" "kube_clarity" {
#   count = var.kubeclarity_enabled ? 1 : 0
#   metadata {
#     name = var.kubeclarity_namespace
#   }
# }

# resource "random_password" "kube_clarity" {
#   count   = var.kubeclarity_enabled ? 1 : 0
#   length  = 20
#   special = false
# }

# resource "kubernetes_secret" "kube_clarity" {
#   count      = var.kubeclarity_enabled ? 1 : 0
#   depends_on = [kubernetes_namespace.kube_clarity]
#   metadata {
#     name      = "basic-auth"
#     namespace = var.kubeclarity_namespace
#   }

#   data = {
#     auth = "admin:${bcrypt(random_password.kube_clarity[0].result)}"
#   }

#   type = "Opaque"
# }

# resource "helm_release" "kubeclarity" {
#   count      = var.kubeclarity_enabled ? 1 : 0
#   name       = "kubeclarity"
#   chart      = "kubeclarity"
#   version    = "2.23.0"
#   namespace  = var.kubeclarity_namespace
#   repository = "https://openclarity.github.io/kubeclarity"
#   values = [
#     templatefile("${path.module}/modules/kubeclarity/values.yaml", {
#       hostname  = var.kubeclarity_hostname
#       namespace = var.kubeclarity_namespace
#     })
#   ]
# }

# #Kubecost

# data "aws_eks_addon_version" "kubecost" {
#   count              = var.kubecost_enabled ? 1 : 0
#   addon_name         = "kubecost_kubecost"
#   kubernetes_version = data.aws_eks_cluster.eks.version
#   most_recent        = true
# }

# resource "aws_eks_addon" "kubecost" {
#   count                    = var.kubecost_enabled ? 1 : 0
#   cluster_name             = var.eks_cluster_name
#   addon_name               = "kubecost_kubecost"
#   addon_version            = data.aws_eks_addon_version.kubecost[0].version
#   service_account_role_arn = var.worker_iam_role_arn
#   preserve                 = true
# }

# resource "random_password" "kubecost" {
#   count   = var.kubecost_enabled ? 1 : 0
#   length  = 20
#   special = false
# }

# resource "kubernetes_secret" "kubecost" {
#   count      = var.kubecost_enabled ? 1 : 0
#   depends_on = [aws_eks_addon.kubecost]
#   metadata {
#     name      = "basic-auth"
#     namespace = "kubecost"
#   }

#   data = {
#     auth = "admin:${bcrypt(random_password.kubecost[0].result)}"
#   }

#   type = "Opaque"
# }

# resource "kubernetes_ingress_v1" "kubecost" {
#   count                  = var.kubecost_enabled ? 1 : 0
#   depends_on             = [aws_eks_addon.kubecost, module.k8s_addons, kubernetes_secret.kubecost]
#   wait_for_load_balancer = true
#   metadata {
#     name      = "kubecost"
#     namespace = "kubecost"
#     annotations = {
#       "kubernetes.io/ingress.class"             = "nginx"
#       "cert-manager.io/cluster-issuer"          = var.cluster_issuer
#       "nginx.ingress.kubernetes.io/auth-type"   = "basic"
#       "nginx.ingress.kubernetes.io/auth-secret" = "basic-auth"
#       "nginx.ingress.kubernetes.io/auth-realm"  = "Authentication Required - kubecost"
#     }
#   }
#   spec {
#     rule {
#       host = var.kubecost_hostname
#       http {
#         path {
#           path = "/"
#           backend {
#             service {
#               name = "cost-analyzer-cost-analyzer"
#               port {
#                 number = 9090
#               }
#             }
#           }
#         }
#       }
#     }
#     tls {
#       secret_name = "tls-kubecost"
#       hosts       = [var.kubecost_hostname]
#     }
#   }
# }


# resource "helm_release" "metrics-server-vpa" {
#   count      = var.metrics_server_enabled ? 1 : 0
#   depends_on = [helm_release.vpa-crds]
#   name       = "metricsservervpa"
#   namespace  = "kube-system"
#   chart      = "${path.module}/modules/metrics_server_vpa/"
#   timeout    = 600
#   values = [
#     templatefile("${path.module}/modules/metrics_server_vpa/values.yaml", {
#       minCPU                      = var.metrics_server_vpa_config.minCPU,
#       minMemory                   = var.metrics_server_vpa_config.minMemory,
#       maxCPU                      = var.metrics_server_vpa_config.maxCPU,
#       maxMemory                   = var.metrics_server_vpa_config.maxMemory,
#       metricsServerDeploymentName = var.metrics_server_vpa_config.metricsServerDeploymentName
#     })
#   ]
# }

# #defectdojo
# resource "kubernetes_namespace" "defectdojo" {
#   count = var.defectdojo_enabled ? 1 : 0
#   metadata {
#     name = "defectdojo"
#   }
# }

# resource "helm_release" "defectdojo" {
#   count      = var.defectdojo_enabled ? 1 : 0
#   depends_on = [kubernetes_namespace.defectdojo]
#   name       = "defectdojo"
#   namespace  = "defectdojo"
#   chart      = "${path.module}/modules/defectdojo/"
#   timeout    = 600
#   values = [
#     templatefile("${path.module}/modules/defectdojo/values.yaml", {
#       hostname         = var.defectdojo_hostname,
#       storageClassName = var.storageClassName
#     })
#   ]
# }

# data "kubernetes_secret" "defectdojo" {
#   count      = var.defectdojo_enabled ? 1 : 0
#   depends_on = [helm_release.defectdojo]
#   metadata {
#     name      = "defectdojo"
#     namespace = "defectdojo"
#   }
# }

# #falco
# resource "kubernetes_namespace" "falco" {
#   count = var.falco_enabled ? 1 : 0
#   metadata {
#     name = "falco"
#   }
# }

# resource "helm_release" "falco" {
#   count      = var.falco_enabled ? 1 : 0
#   depends_on = [kubernetes_namespace.falco]
#   name       = "falco"
#   namespace  = "falco"
#   chart      = "falco"
#   repository = "https://falcosecurity.github.io/charts"
#   timeout    = 600
#   version    = "4.0.0"
#   values = [
#     templatefile("${path.module}/modules/falco/values.yaml", {
#       slack_webhook = var.slack_webhook
#     })
#   ]
# }

## kubernetes dashboard

module "kubernetes-dashboard" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0
  source = "./modules/kubernetes-dashboard" 
  k8s_dashboard_hostname = var.k8s_dashboard_hostname
  alb_acm_certificate_arn = var.alb_acm_certificate_arn
  k8s_dashboard_ingress_load_balancer = var.k8s_dashboard_ingress_load_balancer
  kubernetes_dashboard_enabled = var.kubernetes_dashboard_enabled
}
