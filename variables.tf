variable "single_az_ebs_gp3_storage_class_enabled" {
  description = "Whether to enable the Single AZ storage class or not."
  default     = false
  type        = bool
}

variable "single_az_sc_config" {
  description = "Name and regions for storage class in Key-Value pair."
  default     = []
  type        = list(any)
}

variable "cluster_autoscaler_enabled" {
  description = "Whether to enable the Cluster Autoscaler add-on or not."
  default     = false
  type        = bool
}

variable "cluster_autoscaler_chart_version" {
  description = "Version of the cluster autoscaler helm chart"
  default     = "9.29.0"
  type        = string
}

variable "cluster_autoscaler_helm_config" {
  description = "CoreDNS Autoscaler Helm Chart config"
  type        = any
  default     = {}
}

variable "metrics_server_enabled" {
  description = "Enable or disable the metrics server add-on for EKS cluster."
  default     = false
  type        = bool
}
variable "metrics_server_helm_config" {
  description = "Metrics Server Helm Chart config"
  type        = any
  default     = {}
}
variable "metrics_server_helm_version" {
  description = "Version of the metrics server helm chart"
  default     = "3.11.0"
  type        = string
}

variable "cert_manager_enabled" {
  description = "Enable or disable the cert manager add-on for EKS cluster."
  default     = false
  type        = bool
}

variable "cert_manager_install_letsencrypt_r53_issuers" {
  description = "Enable or disable the creation of Route53 issuer while installing cert manager."
  default     = false
  type        = bool
}

variable "cert_manager_helm_config" {
  description = "Cert Manager Helm Chart config"
  type        = any
  default     = {}
}
variable "cert_manager_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "cert_manager_domain_names" {
  description = "Domain names of the Route53 hosted zone to use with cert-manager"
  type        = list(string)
  default     = []
}
variable "cert_manager_kubernetes_svc_image_pull_secrets" {
  description = "list(string) of kubernetes imagePullSecrets"
  type        = list(string)
  default     = []
}

variable "eks_cluster_name" {
  description = "Fetch Cluster ID of the cluster"
  default     = ""
  type        = string
}

variable "efs_storage_class_enabled" {
  description = "Enable or disable the Amazon Elastic File System (EFS) add-on for EKS cluster."
  default     = false
  type        = bool
}

variable "private_subnet_ids" {
  description = "Private subnets of the VPC which can be used by EFS"
  default     = [""]
  type        = list(string)
}
variable "aws_efs_csi_driver_helm_config" {
  description = "AWS EFS CSI driver Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_efs_csi_driver_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "keda_enabled" {
  description = "Enable or disable Kubernetes Event-driven Autoscaling (KEDA) add-on for autoscaling workloads."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment identifier for the Amazon Elastic Kubernetes Service (EKS) cluster."
  default     = ""
  type        = string
}

variable "external_secrets_enabled" {
  description = "Enable or disable External Secrets operator add-on for managing external secrets."
  default     = false
  type        = bool
}
variable "ingress_nginx_helm_config" {
  description = "Configure ingress-nginx to setup addons"
  type = object({
    values = any
    enable_service_monitor = bool
  })
}

variable "vpa_config" {
  description = "Configure VPA CRD to setup addon"
  type = object({
    values = list(string)
  })
}
variable "internal_nginx_config" {
  description = "Configure internal-ingress-nginx addons"
  type = object({
    values = any
  })
}

variable "karpenter_helm_config" {
  description = "Karpenter autoscaler add-on config"
  type        = any
  default     = {}
}
variable "external_secrets_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "coredns_hpa_helm_config" {
  description = "CoreDNS Autoscaler Helm Chart config"
  type        = any
  default     = {}
}
variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = ["arn:aws:secretsmanager:*:*:secret:*"]
}
variable "external_secrets_helm_config" {
  type        = any
  default     = {}
  description = "External Secrets operator Helm Chart config"
}


variable "ingress_nginx_enabled" {
  description = "Enable or disable Nginx Ingress Controller add-on for routing external traffic to Kubernetes services."
  default     = false
  type        = bool
}

variable "aws_load_balancer_controller_enabled" {
  description = "Enable or disable AWS Load Balancer Controller add-on for managing and controlling load balancers in Kubernetes."
  default     = false
  type        = bool
}

variable "aws_load_balancer_controller_helm_config" {
  description = "Configuration for the AWS Load Balancer Controller Helm release"
  type = object({
    values  = list(string)
  })
}
variable "argocd_manage_add_ons" {
  description = "Enable managing add-on configuration via ArgoCD App of Apps"
  type        = bool
  default     = false
}


variable "aws_load_balancer_version" {
  description = "Specify the version of the AWS Load Balancer Controller for Ingress"
  default     = "1.4.4"
  type        = string
}


variable "ingress_nginx_version" {
  description = "Specify the version of the NGINX Ingress Controller"
  default     = "4.9.1"
  type        = string
}

variable "name" {
  description = "Specify the name prefix of the EKS cluster resources."
  default     = ""
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and its nodes will be provisioned"
  default     = ""
  type        = string
}

variable "cert_manager_letsencrypt_email" {
  description = "Specifies the email address to be used by cert-manager to request Let's Encrypt certificates"
  default     = ""
  type        = string
}

variable "cert_manager_install_letsencrypt_http_issuers" {
  description = "Enable or disable the HTTP issuer for cert-manager"
  default     = false
  type        = bool
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt AWS resources in the EKS cluster."
  default     = ""
  type        = string
}

variable "kms_policy_arn" {
  description = "Specify the ARN of KMS policy, for service accounts."
  default     = ""
  type        = string
}

variable "cluster_propotional_autoscaler_enabled" {
  description = "Enable or disable Cluster propotional autoscaler add-on"
  default     = false
  type        = bool
}

variable "karpenter_enabled" {
  description = "Enable or disable Karpenter, a Kubernetes-native, multi-tenant, and auto-scaling solution for containerized workloads on Kubernetes."
  default     = false
  type        = bool
}

variable "reloader_enabled" {
  description = "Enable or disable Reloader, a Kubernetes controller to watch changes in ConfigMap and Secret objects and trigger an application reload on their changes."
  default     = false
  type        = bool
}
variable "reloader_helm_config" {
  description = "Reloader Helm Chart config"
  type        = any
  default     = {}
}
variable "worker_iam_role_name" {
  description = "Specify the IAM role for the nodes that will be provisioned through karpenter"
  default     = ""
  type        = string
}

variable "worker_iam_role_arn" {
  description = "Specify the IAM role Arn for the nodes"
  default     = ""
  type        = string
}
variable "data_plane_wait_arn" {
  description = "Addon deployment will not proceed until this value is known. Set to node group/Fargate profile ARN to wait for data plane to be ready before provisioning addons"
  type        = string
  default     = ""
}

variable "aws_node_termination_handler_enabled" {
  description = "Enable or disable node termination handler"
  default     = false
  type        = bool
}
variable "aws_node_termination_handler_helm_config" {
  description = "AWS Node Termination Handler Helm Chart config"
  type        = any
  default     = {}
}
variable "aws_node_termination_handler_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "amazon_eks_vpc_cni_enabled" {
  description = "Enable or disable the installation of the Amazon EKS VPC CNI addon. "
  default     = false
  type        = bool
}

variable "service_monitor_crd_enabled" {
  description = "Enable or disable the installation of Custom Resource Definitions (CRDs) for Prometheus Service Monitor. "
  default     = false
  type        = bool
}

variable "istio_enabled" {
  description = "Enable istio for service mesh."
  default     = false
  type        = bool
}

variable "istio_config" {
  description = "Configuration to provide settings for Istio"
  type = object({
    ingress_gateway_enabled       = bool
    ingress_gateway_namespace     = optional(string, "istio-ingressgateway")
    egress_gateway_enabled        = bool
    egress_gateway_namespace      = optional(string, "istio-egressgateway")
    envoy_access_logs_enabled     = bool
    prometheus_monitoring_enabled = bool
    istio_values_yaml             = any
  })
  default = {
    ingress_gateway_enabled       = true
    egress_gateway_enabled        = false
    envoy_access_logs_enabled     = true
    prometheus_monitoring_enabled = true
    istio_values_yaml             = ""
  }
}


variable "velero_enabled" {
  description = "Enable or disable the installation of Velero, which is a backup and restore solution for Kubernetes clusters."
  default     = false
  type        = bool
}
variable "velero_config" {
  description = "Configuration to provide settings for Velero, including which namespaces to backup, retention period, backup schedule, and backup bucket name."
  default = {
    namespaces                      = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_botToken                  = ""
    slack_appToken                  = ""
    slack_notification_channel_name = ""
    retention_period_in_days        = 45
    schedule_backup_cron_time       = ""
    velero_backup_name              = ""
    backup_bucket_name              = ""
  }
  type = any
}

variable "karpenter_provisioner_enabled" {
  description = "Enable or disable the installation of Karpenter, which is a Kubernetes cluster autoscaler."
  default     = false
  type        = bool
}
variable "karpenter_provisioner_config" {
  description = "Configuration to provide settings for Karpenter, including which private subnet to use, instance capacity types, and excluded instance types."
  default = {
    private_subnet_name    = ""
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }
  type = any
}

variable "internal_ingress_nginx_enabled" {
  description = "Enable or disable the deployment of an internal ingress controller for Kubernetes."
  default     = false
  type        = bool
}

variable "node_termination_handler_version" {
  description = "Specify the version of node termination handler"
  default     = "0.21.0"
  type        = string
}
variable "auto_scaling_group_names" {
  description = "List of self-managed node groups autoscaling group names"
  type        = list(string)
  default     = []
}

variable "kubeclarity_hostname" {
  description = "Specify the hostname for the Kubeclarity. "
  default     = ""
  type        = string
}

variable "kubeclarity_enabled" {
  description = "Enable or disable the deployment of an kubeclarity for Kubernetes."
  default     = false
  type        = bool
}

variable "kubeclarity_namespace" {
  description = "Name of the Kubernetes namespace where the kubeclarity deployment will be deployed."
  default     = "kubeclarity"
  type        = string
}

variable "kubecost_enabled" {
  description = "Enable or disable the deployment of an Kubecost for Kubernetes."
  type        = bool
  default     = false
}

variable "kubecost_hostname" {
  description = "Specify the hostname for the kubecsot. "
  default     = ""
  type        = string
}

variable "cluster_issuer" {
  description = "Specify the letsecrypt cluster-issuer for ingress tls. "
  default     = "letsencrypt-prod"
  type        = string
}


variable "enable_amazon_eks_coredns" {
  description = "Enable Amazon EKS CoreDNS add-on"
  type        = bool
  default     = false
}
variable "enable_self_managed_coredns" {
  description = "Enable self-managed CoreDNS add-on"
  type        = bool
  default     = false
}
variable "enable_coredns_autoscaler" {
  description = "Enable CoreDNS autoscaler add-on"
  type        = bool
  default     = false
}

variable "coredns_autoscaler_helm_config" {
  description = "CoreDNS Autoscaler Helm Chart config"
  type        = any
  default     = {}
}
#-----------EKS MANAGED ADD-ONS------------
variable "enable_ipv6" {
  description = "Enable Ipv6 network. Attaches new VPC CNI policy to the IRSA role"
  type        = bool
  default     = false
}

variable "amazon_eks_vpc_cni_config" {
  description = "ConfigMap of Amazon EKS VPC CNI add-on"
  type        = any
  default     = {}
}

variable "amazon_eks_coredns_config" {
  description = "Configuration for Amazon CoreDNS EKS add-on"
  type        = any
  default     = {}
}

variable "self_managed_coredns_helm_config" {
  description = "Self-managed CoreDNS Helm chart config"
  type        = any
  default     = {}
}

variable "remove_default_coredns_deployment" {
  description = "Determines whether the default deployment of CoreDNS is removed and ownership of kube-dns passed to Helm"
  type        = bool
  default     = false
}

variable "enable_coredns_cluster_proportional_autoscaler" {
  description = "Enable cluster-proportional-autoscaler for CoreDNS"
  type        = bool
  default     = true
}

variable "coredns_cluster_proportional_autoscaler_helm_config" {
  description = "Helm provider config for the CoreDNS cluster-proportional-autoscaler"
  default     = {}
  type        = any
}


variable "amazon_eks_kube_proxy_config" {
  description = "ConfigMap for Amazon EKS Kube-Proxy add-on"
  type        = any
  default     = {}
}

variable "amazon_eks_aws_ebs_csi_driver_config" {
  description = "configMap for AWS EBS CSI Driver add-on"
  type        = any
  default     = {}
}

variable "enable_amazon_eks_vpc_cni" {
  description = "Enable VPC CNI add-on"
  type        = bool
  default     = false
}

variable "enable_amazon_eks_kube_proxy" {
  description = "Enable Kube Proxy add-on"
  type        = bool
  default     = false
}

variable "enable_amazon_eks_aws_ebs_csi_driver" {
  description = "Enable EKS Managed AWS EBS CSI Driver add-on; enable_amazon_eks_aws_ebs_csi_driver and enable_self_managed_aws_ebs_csi_driver are mutually exclusive"
  type        = bool
  default     = false
}

variable "enable_self_managed_aws_ebs_csi_driver" {
  description = "Enable self-managed aws-ebs-csi-driver add-on; enable_self_managed_aws_ebs_csi_driver and enable_amazon_eks_aws_ebs_csi_driver are mutually exclusive"
  type        = bool
  default     = false
}

variable "self_managed_aws_ebs_csi_driver_helm_config" {
  description = "Self-managed aws-ebs-csi-driver Helm chart config"
  type        = any
  default     = {}
}

variable "custom_image_registry_uri" {
  description = "Custom image registry URI map of `{region = dkr.endpoint }`"
  type        = map(string)
  default     = {}
}

variable "metrics_server_vpa_config" {
  description = "Configuration to provide settings of vpa over metrics server"
  default = {

    minCPU                      = "25m"
    maxCPU                      = "100m"
    minMemory                   = "150Mi"
    maxMemory                   = "500Mi"
    metricsServerDeploymentName = "metrics-server"
  }
  type = any
}

variable "ipv6_enabled" {
  description = "whether IPv6 enabled or not"
  type        = bool
  default     = false
}

variable "defectdojo_enabled" {
  description = "Enable istio for service mesh."
  default     = false
  type        = bool
}

variable "defectdojo_hostname" {
  description = "Specify the hostname for the kubecsot. "
  default     = ""
  type        = string
}

variable "storageClassName" {
  description = "Specify the hostname for the kubecsot. "
  default     = "infra-service-sc"
  type        = string
}

variable "falco_enabled" {
  description = "Determines whether Falco is enabled."
  default     = false
  type        = bool
}

variable "slack_webhook" {
  description = "The Slack webhook URL used for notifications."
  default     = ""
  type        = string
}

variable "coredns_hpa_enabled" {
  description = "Determines whether Horizontal Pod Autoscaling (HPA) for CoreDNS is enabled."
  default     = false
  type        = bool
}

variable "kubernetes_dashboard_enabled" {
  description = "Determines whether k8s-dashboard is enabled or not"
  default     = false
  type        = bool
}


variable "k8s_dashboard_hostname" {
  description = "Specify the hostname for the k8s dashboard. "
  default     = ""
  type        = string
}

variable "k8s_dashboard_ingress_load_balancer" {
  description = "Controls whether to enable ALB Ingress or not."
  type        = string
  default     = "nlb"
}

variable "alb_acm_certificate_arn" {
  description = "ARN of the ACM certificate to be used for ALB Ingress."
  type        = string
  default     = ""
}
variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}
variable "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  type        = string
  default     = null
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = null
}

variable "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  type        = string
  default     = null
}

variable "enable_karpenter" {
  description = "Enable Karpenter autoscaler add-on"
  type        = bool
  default     = false
}

variable "karpenter_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "karpenter_node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  type        = string
  default     = ""
}

variable "enable_service_monitor" {
  description = "Enable monitoring in nginx ingress add-on"
  type        = bool
  default     = false
}