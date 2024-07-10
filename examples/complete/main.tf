locals {
  region      = "us-west-2"
  environment = "test"
  name        = "eks"
  additional_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  ipv6_enabled = false
  
}

module "eks-addons" {
  source                                  = "../.."
  name                                    = local.name
  tags                                    = local.additional_tags
  vpc_id                                  = "vpc-0c6d04346ffa3d4f1"
  private_subnet_ids                      = ["subnet-09f41e9122d091d57", "subnet-05b9a4afd03c029d5"]
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:us-west-2:381491984451:key/mrk-9cc312cd9e4a4aba9681740e5faaf16c"
  kms_policy_arn                          = "arn:aws:iam::381491984451:policy/test-eks-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  worker_iam_role_name                    = "test-eks-node-role"
  worker_iam_role_arn                     = "arn:aws:iam::381491984451:role/test-eks-node-role"
  eks_cluster_name                        = data.aws_eks_cluster.cluster.name
  ## default addons
  amazon_eks_vpc_cni_enabled              = true
  amazon_eks_vpc_cni_config  = {
    addon_version = "v1.18.2-eksbuild.1"
  }

  #EBS-CSI-DRIVER
  enable_amazon_eks_aws_ebs_csi_driver         = false
  amazon_eks_aws_ebs_csi_driver_config          = {
    values                  = [file("${path.module}/config/ebs-csi.yaml")]
    addon_version           = ""
  }
  ## Service Monitoring
  service_monitor_crd_enabled             = true   
  ## Keda
  keda_enabled                            = false 
  ## Config reloader
  reloader_enabled                        = false 
  reloader_helm_config                    = {
    values = [file("${path.module}/config/reloader.yaml")]
    enable_service_monitor = false
  }

  kubernetes_dashboard_enabled            = false 
  k8s_dashboard_ingress_load_balancer     = "" ##Choose your load balancer type (e.g., NLB or ALB). If using ALB, ensure you provide the ACM certificate ARN for SSL.
  alb_acm_certificate_arn                 = ""
  k8s_dashboard_hostname                  = "dashboard-test.rnd.squareops.in"

  ## aws load balancer controller
  aws_load_balancer_controller_enabled    = false
  aws_load_balancer_controller_helm_config = {
    values = [file("${path.module}/config/aws-alb.yaml")]
  }

  ## karpenter 
  karpenter_enabled                       = false
  karpenter_helm_config = {
    values = [file("${path.module}/config/karpenter.yaml")]
  }
  ## GP3
  single_az_ebs_gp3_storage_class_enabled = false 
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]

  ## coredns HPA (cluster-proportional-autoscaler)
  coredns_hpa_enabled                     = false 
  coredns_hpa_helm_config                = {
   values = [file("${path.module}/config/coredns_hpa.yaml")] 
  }

  ## Cert_Manager
  cert_manager_enabled                    = false 
  cert_manager_helm_config                = {
    values = [file("${path.module}/config/cert-manager.yaml")]
    enable_service_monitor = false
    cert_manager_letsencrypt_email                = "email@email.com"
  }
 
  ## Ingress nginx

  enable_public_nlb                       = true
  ingress_nginx_config = {
    values = [file("${path.module}/config/${data.aws_eks_cluster.cluster.kubernetes_network_config[0].ip_family == "ipv4" ? "nginx-ingress.yaml" : "nginx-ingress_ipv6.yaml"}")]
    enable_service_monitor                  = true # enable monitoring in nginx ingress
  }

  ingress_nginx_private_config = {
    values = file("${path.module}/config/${data.aws_eks_cluster.cluster.kubernetes_network_config[0].ip_family == "ipv4" ? "internal-ingress.yaml" : "internal-ingress-ipv6.yaml"}") 
  }

  ## Metric Server
  metrics_server_enabled                  = false 
  metrics_server_helm_config              = [file("${path.module}/config/metrics-server.yaml")]
  vpa_config = {
    values = [file("${path.module}/config/vpa-crd.yaml")]
  }

  ## External Secrets
  external_secrets_enabled                = false 
  external_secrets_helm_config            = {
    values = [file("${path.module}/config/external-secret.yaml")]
  }

  ## cluster autoscaler
  cluster_autoscaler_enabled              = false 
  cluster_autoscaler_helm_config          = [file("${path.module}/config/cluster-autoscaler.yaml")]

  ## Kubernetes Provisioner
  karpenter_provisioner_enabled = false 
  karpenter_provisioner_config = {
    private_subnet_name    = "${local.environment}-${local.name}-private-subnet"
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }
  ## Efs storage class
  efs_storage_class_enabled                     = false 
  ## Node termination handler
  aws_node_termination_handler_enabled          = false 
  aws_node_termination_handler_helm_config      = {
    values = [file("${path.module}/config/aws-node-termination-handler.yaml")]
    enable_service_monitor = false
  }
  # Velero
  velero_enabled                                = false #aman
  velero_config = {
    namespaces                      = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_botToken                  = "xoxb-379541400966-iibMHnnoaPzVl"
    slack_appToken                  = "xoxb-sgsehger-ddfnrndfnf"
    slack_notification_channel_name = "slack-notification-channel"
    retention_period_in_days        = 45
    schedule_backup_cron_time       = "* 6 * * *"
    velero_backup_name              = "application-backup"
    backup_bucket_name              = "velero-bucket"
  }

  kubeclarity_enabled                     = false 
  kubeclarity_hostname                    = "kubeclarity.prod.in"

  kubecost_enabled                        = false 
  kubecost_hostname                       = "kubecost.prod.in"

  defectdojo_enabled                      = false 
  defectdojo_hostname                     = "defectdojo.prod.in"

  falco_enabled                           = false 
  slack_webhook                           = "xoxb-379541400966-iibMHnnoaPzVl"

  # ISTIO
  istio_enabled                           = false 
  istio_config = {
    ingress_gateway_enabled       = false
    egress_gateway_enabled        = false
    envoy_access_logs_enabled     = false
    prometheus_monitoring_enabled = false
    istio_values_yaml             = file("./config/istio.yaml")
  }
}
