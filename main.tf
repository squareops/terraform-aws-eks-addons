data "aws_region" "current" {}

data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

module "service_monitor_crd" {
  count  = var.service_monitor_crd_enabled ? 1 : 0
  source = "./modules/service_monitor_crd"
}

resource "aws_iam_instance_profile" "karpenter_profile" {
  count       = var.karpenter_enabled ? 1 : 0
  role        = var.worker_iam_role_name
  name_prefix = var.eks_cluster_name
  tags = merge(
    { "Name"        = format("%s-%s-karpenter-profile", var.environment, var.name)
      "Environment" = var.environment
    }
  )
}

#-----------------AWS Managed EKS Add-ons----------------------

module "aws_vpc_cni" {
  source = "./modules/aws-vpc-cni"

  count = var.amazon_eks_vpc_cni_enabled ? 1 : 0

  enable_ipv6 = var.enable_ipv6
  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_vpc_cni_config,
  )

  addon_context = local.addon_context
}

module "aws_coredns" {
  source = "./modules/aws-coredns"

  count = var.enable_amazon_eks_coredns || var.enable_self_managed_coredns ? 1 : 0

  addon_context = local.addon_context

  # Amazon EKS CoreDNS addon
  enable_amazon_eks_coredns = var.enable_amazon_eks_coredns
  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_coredns_config,
  )

  # Self-managed CoreDNS addon via Helm chart
  enable_self_managed_coredns = var.enable_self_managed_coredns
  helm_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.self_managed_coredns_helm_config,
    {
      # Putting after because we don't want users to overwrite this - internal use only
      image_registry = local.amazon_container_image_registry_uris[data.aws_region.current.name]
    }
  )

  # CoreDNS cluster proportioanl autoscaler
  enable_cluster_proportional_autoscaler      = var.enable_coredns_cluster_proportional_autoscaler
  cluster_proportional_autoscaler_helm_config = var.coredns_cluster_proportional_autoscaler_helm_config

  remove_default_coredns_deployment      = var.remove_default_coredns_deployment
  eks_cluster_certificate_authority_data = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

module "aws_kube_proxy" {
  source = "./modules/aws-kube-proxy"

  count = var.enable_amazon_eks_kube_proxy ? 1 : 0

  addon_config = merge(
    {
      kubernetes_version = local.eks_cluster_version
    },
    var.amazon_eks_kube_proxy_config,
  )

  addon_context = local.addon_context
}

module "aws_ebs_csi_driver" {
  source = "./modules/aws-ebs-csi-driver"

  count = var.amazon_eks_aws_ebs_csi_driver_enabled || var.enable_self_managed_aws_ebs_csi_driver ? 1 : 0

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
# -----------------------------------------------------------------------------------------------------------------------------------------------------------

## AWS LOAD BALANCER 
module "aws_load_balancer_controller" {
  count             = var.aws_load_balancer_controller_enabled ? 1 : 0
  source= "./modules/aws-load-balancer-controller/tf_files"
  helm_config       = {
    version = var.aws_load_balancer_version
    values = [
      file("${path.module}/examples/complete/config/aws_alb.yaml")
    ]
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = merge(local.addon_context, { default_repository = local.amazon_container_image_registry_uris[data.aws_region.current.name] })
}

## NODE TERMIANTION HANDLER
module "aws_node_termination_handler" {
  count                   = var.aws_node_termination_handler_enabled ? 1 : 0
  source                  = "./modules/aws_node_termination_handler/tf_files"
  helm_config             =  {
    version = var.node_termination_handler_version
    values = [
      templatefile("${path.module}/examples/complete/config/aws_node_termination_handler.yaml", {
        enable_service_monitor = var.service_monitor_crd_enabled
      })
    ]
  }
  irsa_policies           = var.aws_node_termination_handler_irsa_policies
  autoscaling_group_names = var.auto_scaling_group_names
  addon_context           = local.addon_context
}


## CERT MANAGER
module "cert_manager" {
  count                             = var.cert_manager_enabled ? 1 : 0
  source                            = "./modules/cert_manager/tf_files/"
  helm_config                       = {
    values = [
      file("${path.module}/examples/complete/config/cert_manager.yaml")
    ]
  }
  manage_via_gitops                 = var.argocd_manage_add_ons
  irsa_policies                     = var.cert_manager_irsa_policies
  addon_context                     = local.addon_context
  domain_names                      = var.cert_manager_domain_names
  install_letsencrypt_issuers       = var.cert_manager_install_letsencrypt_r53_issuers
  letsencrypt_email                 = var.cert_manager_letsencrypt_email
  kubernetes_svc_image_pull_secrets = var.cert_manager_kubernetes_svc_image_pull_secrets
}

resource "helm_release" "cert_manager_le_http" {
  depends_on = [module.cert_manager]
  count      = var.cert_manager_install_letsencrypt_http_issuers ? 1 : 0
  name       = "cert-manager-le-http"
  chart      = "${path.module}/modules/cert-manager-le-http"
  version    = "0.1.0"
  set {
    name  = "email"
    value = var.cert_manager_letsencrypt_email
    type  = "string"
  }
}

## CLUSTER AUTOSCALER
module "cluster_autoscaler" {
  source = "./modules/cluster_autoscaler/tf_files"

  count = var.cluster_autoscaler_enabled ? 1 : 0

  eks_cluster_version = local.eks_cluster_version
  helm_config         = {
    version = var.cluster_autoscaler_chart_version
    values = [templatefile("${path.module}/examples/complete/config/cluster_autoscaler.yaml", {
      aws_region     = data.aws_region.current.name
      eks_cluster_id = var.eks_cluster_name
    })]
  }
  manage_via_gitops   = var.argocd_manage_add_ons
  addon_context       = local.addon_context
}

## CLUSTER PROPOTIONAL AUTOSCALLER
#It is COREDNS_AUTOSCALER
module "coredns_autoscaler" {
  count             = var.enable_amazon_eks_coredns && var.enable_coredns_autoscaler && length(var.coredns_autoscaler_helm_config) > 0 ? 1 : 0
  source            = "./modules/cluster_propotional_autoscaler/tf_files"
  helm_config       =  {
    values = [
      file("${path.module}/examples/complete/config/cluster_propotional_autoscaler.yaml")
    ]
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}


## EXTERNAL SECRET
module "external_secrets" {
  source = "./modules/external-secret/tf_files"
  count = var.external_secrets_enabled ? 1 : 0

  helm_config                           = {
    values = [file("${path.module}/examples/complete/config/external-secret.yaml")
    ]
  }
  manage_via_gitops                     = var.argocd_manage_add_ons
  addon_context                         = local.addon_context
  irsa_policies                         = var.external_secrets_irsa_policies
  external_secrets_ssm_parameter_arns   = var.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns = var.external_secrets_secrets_manager_arns
}


## RELOADER
module "reloader" {
  count             = var.reloader_enabled ? 1 : 0
  source            = "./modules/reloader/tf_files"
  helm_config       = {
    values = [
      templatefile("${path.module}/examples/complete/config/reloader.yaml", {
        enable_service_monitor = var.service_monitor_crd_enabled
      })
    ]
    namespace        = "kube-system"
    create_namespace = false
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}


## METRIC SERVER
module "metrics_server" {
  count             = var.metrics_server_enabled ? 1 : 0
  source            = "./modules/metrics_server/tf_files"
  helm_config       = {
    version = var.metrics_server_helm_version
    values  = [file("${path.module}/examples/complete/config/metrics_server.yaml")]
  }
  manage_via_gitops = var.argocd_manage_add_ons
  addon_context     = local.addon_context
}




module "k8s_addons" {
  depends_on     = [module.service_monitor_crd]
  source         = "./modules/kubernetes-addons"
  eks_cluster_id = var.eks_cluster_name

  #ebs csi driver
  enable_amazon_eks_aws_ebs_csi_driver = var.amazon_eks_aws_ebs_csi_driver_enabled
  amazon_eks_aws_ebs_csi_driver_config = {
    additional_iam_policies = [var.kms_policy_arn]
    values                  = [file("${path.module}/modules/ebs-csi/values.yaml")]
  }

  # #cluster-autoscaler
  # enable_cluster_autoscaler = var.cluster_autoscaler_enabled
  # cluster_autoscaler_helm_config = {
  #   version = var.cluster_autoscaler_chart_version
  #   values = [templatefile("${path.module}/modules/cluster_autoscaler/cluster_autoscaler.yaml", {
  #     aws_region     = data.aws_region.current.name
  #     eks_cluster_id = var.eks_cluster_name
  #   })]
  # }

  # #metrics server
  # enable_metrics_server = var.metrics_server_enabled
  # metrics_server_helm_config = {
  #   version = var.metrics_server_helm_version
  #   values  = [file("${path.module}/modules/metrics_server/metrics_server.yaml")]
  # }

  #keda
  enable_keda = var.keda_enabled
  keda_helm_config = {
    version = "2.10.2"
    values  = [file("${path.module}/modules/keda/keda.yaml")]
  }
  #Ingress Nginx Controller
  enable_ingress_nginx = var.ingress_nginx_enabled
  ingress_nginx_helm_config = {
    version = var.ingress_nginx_version
    values = [
      templatefile("${path.module}/modules/nginx_ingress/${data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family == "ipv4" ? "nginx_ingress.yaml" : "nginx_ingress_ipv6.yaml"}", {
        enable_service_monitor = var.service_monitor_crd_enabled

      })
    ]
  }

  # #Cert Manager
  # enable_cert_manager                      = var.cert_manager_enabled
  # cert_manager_letsencrypt_email           = var.cert_manager_letsencrypt_email
  # cert_manager_install_letsencrypt_issuers = var.cert_manager_install_letsencrypt_r53_issuers
  # cert_manager_helm_config = {
  #   values = [
  #     file("${path.module}/modules/cert_manager/cert_manager.yaml")
  #   ]
  # }

  #Aws Load balancer Controller
  # enable_aws_load_balancer_controller = var.aws_load_balancer_controller_enabled
  # aws_load_balancer_controller_helm_config = {
  #   version = var.aws_load_balancer_version
  #   values = [
  #     file("${path.module}/modules/aws_alb/aws_alb.yaml")
  #   ]
  # }

  # enable_coredns_autoscaler = var.cluster_propotional_autoscaler_enabled
  # coredns_autoscaler_helm_config = {
  #   values = [
  #     file("${path.module}/modules/cluster_propotional_autoscaler/cpa.yaml")
  #   ]
  # }

  enable_karpenter = var.karpenter_enabled
  karpenter_helm_config = {
    values = [
      templatefile("${path.module}/modules/karpenter/karpenter.yaml", {
        eks_cluster_id            = var.eks_cluster_name,
        node_iam_instance_profile = var.karpenter_enabled ? aws_iam_instance_profile.karpenter_profile[0].name : ""
        eks_cluster_endpoint      = data.aws_eks_cluster.eks.endpoint
      })
    ]
  }
  karpenter_node_iam_instance_profile = var.karpenter_enabled ? aws_iam_instance_profile.karpenter_profile[0].name : ""

  # enable_reloader = var.reloader_enabled
  # reloader_helm_config = {
  #   values = [
  #     templatefile("${path.module}/modules/reloader/reloader.yaml", {
  #       enable_service_monitor = var.service_monitor_crd_enabled
  #     })
  #   ]
  #   namespace        = "kube-system"
  #   create_namespace = false
  # }

  # enable_aws_node_termination_handler = var.aws_node_termination_handler_enabled
  # aws_node_termination_handler_helm_config = {
  #   version = var.node_termination_handler_version
  #   values = [
  #     templatefile("${path.module}/modules/aws_node_termination_handler/aws_nth.yaml", {
  #       enable_service_monitor = var.service_monitor_crd_enabled
  #     })
  #   ]
  # }

  # enable_amazon_eks_vpc_cni = var.amazon_eks_vpc_cni_enabled
  # amazon_eks_vpc_cni_config = {

  # }
  enable_aws_efs_csi_driver        = var.efs_storage_class_enabled
  aws_efs_csi_driver_irsa_policies = [var.kms_policy_arn]

  # External Secrets
  # enable_external_secrets = var.external_secrets_enabled
  # external_secrets_helm_config = {
  #   values = [file("${path.module}/modules/external-secret/external-secret.yaml")
  #   ]
  # }
}



# OPEN: Default label needs to be removed from gp2 storageclass in order to make gp3 as default choice for EBS volume provisioning.
module "single_az_sc" {
  for_each                             = { for sc in var.single_az_sc_config : sc.name => sc }
  source                               = "./modules/aws-ebs-storage-class"
  kms_key_id                           = var.kms_key_arn
  availability_zone                    = each.value.zone
  single_az_ebs_gp3_storage_class      = var.single_az_ebs_gp3_storage_class_enabled
  single_az_ebs_gp3_storage_class_name = each.value.name
}

# EFS
module "efs" {
  source      = "./modules/efs"
  count       = var.efs_storage_class_enabled ? 1 : 0
  name        = var.name
  vpc_id      = var.vpc_id
  environment = var.environment
  kms_key_arn = var.kms_key_arn
  subnets     = var.private_subnet_ids
}

data "kubernetes_service" "nginx-ingress" {
  count      = var.ingress_nginx_enabled ? 1 : 0
  depends_on = [module.k8s_addons]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

module "velero" {
  source        = "./modules/velero"
  name          = var.name
  count         = var.velero_enabled ? 1 : 0
  region        = data.aws_region.current.name
  cluster_id    = var.eks_cluster_name
  environment   = var.environment
  velero_config = var.velero_config
}

module "istio" {
  depends_on                     = [helm_release.cert_manager_le_http]
  source                         = "./modules/istio"
  count                          = var.istio_enabled ? 1 : 0
  ingress_gateway_enabled        = var.istio_config.ingress_gateway_enabled
  ingress_gateway_namespace      = var.istio_config.ingress_gateway_namespace
  egress_gateway_enabled         = var.istio_config.egress_gateway_enabled
  egress_gateway_namespace       = var.istio_config.egress_gateway_namespace
  envoy_access_logs_enabled      = var.istio_config.envoy_access_logs_enabled
  prometheus_monitoring_enabled  = var.istio_config.prometheus_monitoring_enabled
  cert_manager_letsencrypt_email = var.cert_manager_letsencrypt_email
  istio_values_yaml              = var.istio_config.istio_values_yaml
}

data "kubernetes_service" "istio-ingress" {
  count      = var.istio_enabled ? 1 : 0
  depends_on = [module.istio]
  metadata {
    name      = "istio-ingressgateway"
    namespace = var.istio_config.ingress_gateway_namespace
  }
}

module "karpenter_provisioner" {
  depends_on                           = [module.k8s_addons]
  source                               = "./modules/karpenter_provisioner"
  count                                = var.karpenter_provisioner_enabled ? 1 : 0
  ipv6_enabled                         = var.ipv6_enabled
  sg_selector_name                     = var.eks_cluster_name
  subnet_selector_name                 = var.karpenter_provisioner_config.private_subnet_name
  karpenter_ec2_capacity_type          = var.karpenter_provisioner_config.instance_capacity_type
  excluded_karpenter_ec2_instance_type = var.karpenter_provisioner_config.excluded_instance_type
  instance_hypervisor                  = var.karpenter_provisioner_config.instance_hypervisor
}

resource "kubernetes_namespace" "internal_nginx" {
  count = var.internal_ingress_nginx_enabled ? 1 : 0
  metadata {
    name = "internal-ingress-nginx"
  }
}

resource "helm_release" "internal_nginx" {
  depends_on = [kubernetes_namespace.internal_nginx]
  count      = var.internal_ingress_nginx_enabled ? 1 : 0
  name       = "internal-ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"
  namespace  = "internal-ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  values = [
    templatefile("${path.module}/modules/internal_nginx_ingress/${data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family == "ipv4" ? "ingress.yaml" : "ingress_ipv6.yaml"}", {
      enable_service_monitor = var.service_monitor_crd_enabled
    })
  ]
}

data "kubernetes_service" "internal-nginx-ingress" {
  depends_on = [helm_release.internal_nginx]
  count      = var.internal_ingress_nginx_enabled ? 1 : 0
  metadata {
    name      = "internal-ingress-nginx-controller"
    namespace = "internal-ingress-nginx"
  }
}

##KUBECLARITY
resource "kubernetes_namespace" "kube_clarity" {
  count = var.kubeclarity_enabled ? 1 : 0
  metadata {
    name = var.kubeclarity_namespace
  }
}

resource "random_password" "kube_clarity" {
  count   = var.kubeclarity_enabled ? 1 : 0
  length  = 20
  special = false
}

resource "kubernetes_secret" "kube_clarity" {
  count      = var.kubeclarity_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.kube_clarity]
  metadata {
    name      = "basic-auth"
    namespace = var.kubeclarity_namespace
  }

  data = {
    auth = "admin:${bcrypt(random_password.kube_clarity[0].result)}"
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
  depends_on             = [aws_eks_addon.kubecost, module.k8s_addons, kubernetes_secret.kubecost]
  wait_for_load_balancer = true
  metadata {
    name      = "kubecost"
    namespace = "kubecost"
    annotations = {
      "kubernetes.io/ingress.class"             = "nginx"
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

#HPA_CROEDNS
resource "helm_release" "coredns-hpa" {
  count     = var.coredns_hpa_enabled ? 1 : 0
  name      = "corednshpa"
  namespace = "kube-system"
  chart     = "${path.module}/modules/core_dns_hpa/"
  timeout   = 600
  values = [
    templatefile("${path.module}/modules/core_dns_hpa/values.yaml", {
      minReplicas                       = var.core_dns_hpa_config.minReplicas,
      maxReplicas                       = var.core_dns_hpa_config.maxReplicas,
      corednsdeploymentname             = var.core_dns_hpa_config.corednsdeploymentname,
      targetCPUUtilizationPercentage    = var.core_dns_hpa_config.targetCPUUtilizationPercentage,
      targetMemoryUtilizationPercentage = var.core_dns_hpa_config.targetMemoryUtilizationPercentage
    })
  ]
}
## VPA_CRDS
resource "helm_release" "vpa-crds" {
  count      = var.metrics_server_enabled ? 1 : 0
  name       = "vertical-pod-autoscaler"
  namespace  = "kube-system"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "vertical-pod-autoscaler"
  version    = "9.6.0"
  timeout    = 600
  values = [
    file("${path.module}/modules/vpa_crds/values.yaml")
  ]
}

resource "helm_release" "metrics-server-vpa" {
  count      = var.metrics_server_enabled ? 1 : 0
  depends_on = [helm_release.vpa-crds]
  name       = "metricsservervpa"
  namespace  = "kube-system"
  chart      = "${path.module}/modules/metrics_server_vpa/"
  timeout    = 600
  values = [
    templatefile("${path.module}/modules/metrics_server_vpa/values.yaml", {
      minCPU                      = var.metrics_server_vpa_config.minCPU,
      minMemory                   = var.metrics_server_vpa_config.minMemory,
      maxCPU                      = var.metrics_server_vpa_config.maxCPU,
      maxMemory                   = var.metrics_server_vpa_config.maxMemory,
      metricsServerDeploymentName = var.metrics_server_vpa_config.metricsServerDeploymentName
    })
  ]
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
      hostname         = var.defectdojo_hostname,
      storageClassName = var.storageClassName
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
    templatefile("${path.module}/modules/falco/values.yaml", {
      slack_webhook = var.slack_webhook
    })
  ]
}

resource "kubernetes_namespace" "k8s-dashboard" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0
  metadata {
    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "kubernetes-dashboard" {
  count      = var.kubernetes_dashboard_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.k8s-dashboard]
  name       = "kubernetes-dashboard"
  namespace  = "kubernetes-dashboard"
  chart      = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  timeout    = 600
  version    = "6.0.8"
}


resource "kubernetes_ingress_v1" "k8s-ingress" {
  count                  = var.kubernetes_dashboard_enabled ? 1 : 0
  depends_on             = [helm_release.kubernetes-dashboard]
  wait_for_load_balancer = true
  metadata {
    name      = "k8s-dashboard-ingress"
    namespace = "kubernetes-dashboard"
    annotations = var.k8s_dashboard_ingress_load_balancer == "alb" ? {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.alb_acm_certificate_arn,
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTPS"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      } : {
      "cert-manager.io/cluster-issuer"                    = "letsencrypt-prod"
      "kubernetes.io/ingress.class"                       = "nginx"
      "kubernetes.io/tls-acme"                            = "false"
      "nginx.ingress.kubernetes.io/backend-protocol"      = "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target"        = "/$2"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOF
        if ($uri = "/dashboard") {
          rewrite ^(/dashboard)$ $1/ redirect;
        }
      EOF
    }
  }
  spec {
    rule {
      host = var.k8s_dashboard_hostname
      http {
        path {
          path      = var.k8s_dashboard_ingress_load_balancer == "alb" ? "/" : "/dashboard(/|$)(.*)"
          path_type = var.k8s_dashboard_ingress_load_balancer == "alb" ? "Prefix" : "ImplementationSpecific"
          backend {
            service {
              name = "kubernetes-dashboard"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = var.k8s_dashboard_ingress_load_balancer == "alb" ? "" : "tls-k8s-dashboard"
      hosts       = var.k8s_dashboard_ingress_load_balancer == "alb" ? [] : [var.k8s_dashboard_hostname]
    }
  }
}

resource "kubernetes_service_account" "dashboard_admin_sa" {
  count      = var.kubernetes_dashboard_enabled ? 1 : 0
  depends_on = [helm_release.kubernetes-dashboard]
  metadata {
    name      = "kubernetes-dashboard-admin-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "admin-user" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0
  metadata {
    name      = "admin-user-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.dashboard_admin_sa[0].metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
  depends_on = [
    kubernetes_service_account.dashboard_admin_sa,
    kubernetes_cluster_role_binding_v1.admin-user
  ]
}

resource "kubernetes_cluster_role_binding_v1" "admin-user" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0
  metadata {
    name = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_admin_sa[0].metadata[0].name
    namespace = "kube-system"
  }
  depends_on = [
    kubernetes_service_account.dashboard_admin_sa
  ]
}

resource "kubernetes_cluster_role" "eks_read_only_role" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0

  metadata {
    name = "dashboard-viewonly"
  }

  rule {
    api_groups = [""]
    resources = [
      "configmaps",
      "endpoints",
      "persistentvolumeclaims",
      "pods",
      "replicationcontrollers",
      "replicationcontrollers/scale",
      "serviceaccounts",
      "services",
      "nodes",
      "persistentvolumes",
      "bindings",
      "events",
      "limitranges",
      "namespaces/status",
      "pods/log",
      "pods/status",
      "replicationcontrollers/status",
      "resourcequotas",
      "resourcequotas/status",
      "namespaces",
      "apps/daemonsets",
      "apps/deployments",
      "apps/deployments/scale",
      "apps/replicasets",
      "apps/replicasets/scale",
      "apps/statefulsets",
      "autoscaling/horizontalpodautoscalers",
      "batch/cronjobs",
      "batch/jobs",
      "extensions/daemonsets",
      "extensions/deployments",
      "extensions/deployments/scale",
      "extensions/ingresses",
      "extensions/networkpolicies",
      "extensions/replicasets",
      "extensions/replicasets/scale",
      "extensions/replicationcontrollers/scale",
      "policy/poddisruptionbudgets",
      "networking.k8s.io/networkpolicies",
      "storage.k8s.io/storageclasses",
      "storage.k8s.io/volumeattachments",
      "rbac.authorization.k8s.io/clusterrolebindings",
      "rbac.authorization.k8s.io/clusterroles",
      "rbac.authorization.k8s.io/roles",
      "rbac.authorization.k8s.io/rolebindings",
    ]
    verbs = ["get", "list", "watch"]
  }
}

# Add more rules as needed for read-only access to other Kubernetes resources

resource "kubernetes_service_account" "dashboard_read_only_sa" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0

  metadata {
    name      = "dashboard-read-only-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "eks_read_only_role_binding" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0

  metadata {
    name = "eks-read-only-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.eks_read_only_role[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_read_only_sa[0].metadata[0].name
    namespace = "kube-system"
  }

  depends_on = [
    kubernetes_cluster_role.eks_read_only_role,
    kubernetes_service_account.dashboard_read_only_sa
  ]
}

resource "kubernetes_secret_v1" "dashboard_read_only_sa_token" {
  count = var.kubernetes_dashboard_enabled ? 1 : 0

  metadata {
    name      = "dashboard-read-only-sa-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.dashboard_read_only_sa[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.dashboard_read_only_sa,
    kubernetes_cluster_role_binding.eks_read_only_role_binding
  ]
}
