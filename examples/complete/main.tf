locals {
  region      = "" # Enter region of EKS cluster
  environment = ""
  name        = ""
  additional_tags = {
    Owner       = "Organization_Name"
    Expires     = "Never"
    Department  = "Engineering"
    Product     = ""
    Environment = local.environment
  }
  argocd_namespace        = "argo-cd"                                       # Give Namespace
  kms_key_arn             = "arn:aws:kms:us-west-1:xxxxxxx:key/mrk-xxxxxxx" # pass ARN of EKS created KMS key
  ipv6_enabled            = false
  alb_acm_certificate_arn = ""
}

module "eks-addons" {
  source               = "squareops/eks-addons/aws"
  version              = "3.1.2"
  name                 = local.name
  tags                 = local.additional_tags
  vpc_id               = "vpc-xxxxxx"                     # pass VPC ID
  private_subnet_ids   = ["subnet-xxxxx", "subnet-xxxxx"] # pass Subnet IDs
  environment          = local.environment
  ipv6_enabled         = local.ipv6_enabled
  kms_key_arn          = local.kms_key_arn
  kms_policy_arn       = "arn:aws:iam::xxx:policy/eks-kms-policy" # eks module will create kms_policy_arn
  worker_iam_role_name = "eks-node-role"                          # enter role name created by eks module
  worker_iam_role_arn  = "arn:aws:iam::xxx:role/eks-node-role"    # enter roll ARN
  eks_cluster_name     = data.aws_eks_cluster.cluster.name

  #VPC-CNI-DRIVER
  amazon_eks_vpc_cni_enabled = false # enable VPC-CNI
  vpc_cni_version = "v1.19.0-eksbuild.1"

  #EBS-CSI-DRIVER
  enable_amazon_eks_aws_ebs_csi_driver = false # enable EBS CSI Driver
  ebs_csi_driver_version = "v1.36.0-eksbuild.1"
  amazon_eks_aws_ebs_csi_driver_config = {
    values = [file("${path.module}/config/ebs-csi.yaml")]
  }

  ## EBS-STORAGE-CLASS
  single_az_ebs_gp3_storage_class_enabled = false # to enable ebs gp3 storage class
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  
  ## EfS-STORAGE-CLASS
  efs_storage_class_enabled = false # to enable EBS storage class

  ## SERVICE-MONITORING-CRDs
  service_monitor_crd_enabled = false # enable service monitor along with K8S-dashboard (required CRD) or when require service monitor in reloader and cert-manager
  
  ## METRIC-SERVER
  metrics_server_enabled     = false # to enable metrics server
  metrics_server_version     = "3.12.1"
  metrics_server_helm_config = [file("${path.module}/config/metrics-server.yaml")]
  vpa_config = {
    values = [file("${path.module}/config/vpa-crd.yaml")]
  }
  
  ## CLUSTER-AUTOSCALER
  cluster_autoscaler_enabled     = false # to enable cluster autoscaller
  cluster_autoscaler_helm_config = [file("${path.module}/config/cluster-autoscaler.yaml")]
  cluster_autoscaler_version     = "9.37.0"

  ## NODE-TERMINATION-HANDLER
  aws_node_termination_handler_enabled = false # to enable node termination handler
  aws_node_termination_handler_helm_config = {
    values                 = [file("${path.module}/config/aws-node-termination-handler.yaml")]
    enable_service_monitor = false # to enable monitoring for node termination handler
    enable_notifications   = true
  }
  aws_node_termination_handler_version = "0.21.0"

  ## KEDA
  keda_enabled = false # to enable Keda in the EKS cluster
  keda_helm_config = {
    values = [file("${path.module}/config/keda.yaml")]
  }
  keda_version = "2.14.2"

  ## KARPENTER
  karpenter_enabled = false # to enable Karpenter (installs required CRDs )
  karpenter_helm_config = {
    enable_service_monitor = false # to enable monitoring for kafalserpenter
    values                 = [file("${path.module}/config/karpenter.yaml")]
  }
  karpenter_version        = "1.0.6"

  ## coreDNS-HPA (cluster-proportional-autoscaler)
  coredns_hpa_enabled = false # to enable core-dns HPA
  coredns_hpa_helm_config = {
    values = [file("${path.module}/config/coredns-hpa.yaml")]
  }

  ## EXTERNAL-SECRETS
  external_secrets_enabled = false # to enable external secrets
  external_secrets_helm_config = {
    values = [file("${path.module}/config/external-secret.yaml")]
  }
  external_secrets_version = "0.9.19"

  ## CERT-MANAGER
  cert_manager_enabled = false # to enable Cert-manager
  cert_manager_helm_config = {
    values                         = [file("${path.module}/config/cert-manager.yaml")]
    enable_service_monitor         = false # to enable monitoring for Cert Manager
    cert_manager_letsencrypt_email = "email@email.com"
  }
  cert_manager_version = "v1.15.1"

  ## CONFIG-RELOADER
  reloader_enabled = false # to enable config reloader in the EKS cluster
  reloader_helm_config = {
    values                 = [file("${path.module}/config/reloader.yaml")]
    enable_service_monitor = false # to enable monitoring for reloader
  }
  reloader_version = "v1.0.115"

  ## INGRESS-NGINX
  ingress_nginx_enabled = false # to enable ingress nginx
  private_nlb_enabled   = false # to enable Internal (Private) Ingress , set this and ingress_nginx_enable "false" together
  ingress_nginx_config = {
    values                 = [file("${path.module}/config/ingress-nginx.yaml")]
    enable_service_monitor = false   # enable monitoring in nginx ingress
    ingress_class_name     = "nginx" # enter ingress class name according to your requirement (example: "nginx", "internal-ingress")
    namespace              = "nginx" # enter namespace according to the requirement (example: "nginx", "internal-ingress")
  }
  ingress_nginx_version = "4.11.0"

  ## AWS-APPLICATION-LOAD-BALANCER-CONTROLLER
  aws_load_balancer_controller_enabled = false # to enable load balancer controller
  aws_load_balancer_controller_helm_config = {
    values                        = [file("${path.module}/config/aws-alb.yaml")]
    namespace                     = "alb" # enter namespace according to the requirement (example: "alb")
    load_balancer_controller_name = "alb" # enter ingress class name according to your requirement (example: "aws-load-balancer-controller")
  }
  aws_load_balancer_controller_version = "1.8.1"

  ## KUBERNETES-DASHBOARD
  kubernetes_dashboard_enabled = false
  kubernetes_dashboard_config = {
    k8s_dashboard_ingress_load_balancer = "nlb"                            ##Choose your load balancer type (e.g., NLB or ALB). Enable load balancer controller, if you require ALB, Enable Ingress Nginx if NLB.
    private_alb_enabled                 = false                            # to enable Internal (Private) ALB , set this and aws_load_balancer_controller_enabled "true" together
    alb_acm_certificate_arn             = ""                               # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
    k8s_dashboard_hostname              = "k8s-dashboard.rnd.squareops.in" # Enter Hostname
  }
  kubernetes_dashboard_version = "6.0.8"

  ## ArgoCD
  argocd_enabled = false
  argocd_config = {
    hostname                     = "argocd.rnd.squareops.in"
    values_yaml                  = file("${path.module}/config/argocd.yaml")
    namespace                    = local.argocd_namespace
    redis_ha_enabled             = true
    autoscaling_enabled          = true
    slack_notification_token     = ""
    argocd_notifications_enabled = false
    ingress_class_name           = "nginx" # enter ingress class name according to your requirement (example: "ingress-nginx", "internal-ingress")
  }
  argocd_version = "7.3.11"
  argoproject_config = {
    name = "argo-project" # enter name for aro-project appProjects
  }

  ## ArgoCD-Workflow
  argoworkflow_enabled = false
  argoworkflow_config = {
    values              = file("${path.module}/config/argocd-workflow.yaml")
    namespace           = local.argocd_namespace
    autoscaling_enabled = true
    hostname            = "argocd-workflow.rnd.squareops.in"
    ingress_class_name  = "nginx" # enter ingress class name according to your requirement (example: "ingress-nginx", "internal-ingress")
  }
  argoworkflow_version = "0.29.2"

  # VELERO
  velero_enabled              = false # to enable velero
  velero_notification_enabled = false # To enable slack notification for Velero
  velero_config = {
    namespaces                      = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_botToken                  = "xoxb-379541400966-iibMHnnoaPzVl"
    slack_appToken                  = "xoxb-sgsehger-ddfnrndfnf"
    slack_notification_channel_name = "slack-notification-channel"
    retention_period_in_days        = 45
    schedule_backup_cron_time       = "* 6 * * *"
    velero_backup_name              = "application-backup"
    backup_bucket_name              = "velero-test-eks-1.30" # Enter the S3 bucket name for velero
    velero_values_yaml              = [file("${path.module}/config/velero.yaml")]
  }

  ## KUBECLARITY
  kubeclarity_enabled  = false # to enable kube clarity
  kubeclarity_hostname = "kubeclarity.prod.in"
  kubeclarity_version  = "2.23.0"

  ## KUBECOST
  kubecost_enabled  = false # to enable kube cost
  kubecost_hostname = "kubecost.prod.in"
  kubecost_version  = "v2.1.0-eksbuild.1"

  ## DEFECT-DOJO
  defectdojo_enabled  = false # to enable defectdojo
  defectdojo_hostname = "defectdojo.prod.in"

  ## FALCO
  falco_enabled = false # to enable falco
  slack_webhook = "xoxb-379541400966-iibMHnnoaPzVl"
  falco_version = "4.0.0"
}
