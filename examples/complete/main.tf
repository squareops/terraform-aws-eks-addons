locals {
  region      = "us-west-2"
  environment = "prod"
  name        = "addons"
  additional_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  ipv6_enabled = false
  cluster-name = "test-eks"
}

module "eks-addons" {
  source                                  = "../.."
  name                                    = local.name
  tags                                    = local.additional_tags
  vpc_id                                  = "vpc-05a2fb49cae771ab7"
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:us-west-2:381491984451:key/mrk-72283808c41843f9b8d524f5adb5cd4b"
  keda_enabled                            = false
  kms_policy_arn                          = "arn:aws:iam::381491984451:policy/test-eks-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  eks_cluster_name                        = local.cluster-name
  ## Service Monitoring
  service_monitor_crd_enabled             = true
  # Config reloader
  reloader_enabled                        = true
  reloader_helm_config                    = [
      templatefile("${path.module}/config/reloader.yaml", {
        enable_service_monitor = true # This line applies configurations only when ADDONS "service_monitor_crd_enabled" is set to true.

      })
    ]
  kubernetes_dashboard_enabled            = false
  k8s_dashboard_ingress_load_balancer     = "" ##Choose your load balancer type (e.g., NLB or ALB). If using ALB, ensure you provide the ACM certificate ARN for SSL.
  alb_acm_certificate_arn                 = ""
  k8s_dashboard_hostname                  = "dashboard.prod.in"
  ## aws load balancer controller
  aws_load_balancer_controller_enabled    = true
  aws_load_balancer_controller_helm_config = {
    values = [
      file("${path.module}/config/aws-alb.yaml")
    ]
  }
  karpenter_enabled                       = false
  private_subnet_ids                      = ["subnet-0992a34b322a4a402", "subnet-06ea4083fb49c338f"]
  single_az_ebs_gp3_storage_class_enabled = false
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  # coredns HPA
  coredns_hpa_enabled                     = true
  kubeclarity_enabled                     = false
  kubeclarity_hostname                    = "kubeclarity.prod.in"
  kubecost_enabled                        = false
  kubecost_hostname                       = "kubecost.prod.in"
  defectdojo_enabled                      = false
  defectdojo_hostname                     = "defectdojo.prod.in"
  ## Cert_Manager
  cert_manager_enabled                    = true
  cert_manager_helm_config                = {
    values = [
      file("${path.module}/config/cert-manager.yaml")
    ]
  }
  cert_manager_install_letsencrypt_http_issuers = true
  cert_manager_letsencrypt_email                = "email@email.com"
  
  worker_iam_role_name                    = "test-eks-node-role"
  worker_iam_role_arn                     = "arn:aws:iam::381491984451:role/test-eks-node-role"
  ingress_nginx_enabled                   = false
  ## Metric Server
  metrics_server_enabled                  = true
  metrics_server_helm_config              = [file("${path.module}/config/metrics-server.yaml")]
  ## External Secrets
  external_secrets_enabled                = false
  external_secrets_helm_config            = {
    values = [file("${path.module}/config/external-secret.yaml")
    ]
  }
  ## cluster autoscaler
  cluster_autoscaler_enabled              = true
  cluster_autoscaler_helm_config          = [
    templatefile("${path.module}/config/cluster-autoscaler.yaml", {
      aws_region     = local.region
      eks_cluster_id = local.cluster-name
    })]

  falco_enabled                           = false
  slack_webhook                           = "xoxb-379541400966-iibMHnnoaPzVl"
  istio_enabled                           = false
  istio_config = {
    ingress_gateway_enabled       = false
    egress_gateway_enabled        = false
    envoy_access_logs_enabled     = false
    prometheus_monitoring_enabled = false
    istio_values_yaml             = file("./config/istio.yaml")
  }
  karpenter_provisioner_enabled = false
  karpenter_provisioner_config = {
    private_subnet_name    = "${local.environment}-${local.name}-private-subnet"
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }

  internal_ingress_nginx_enabled                = false
  efs_storage_class_enabled                     = false
  #Node termination handler
  aws_node_termination_handler_enabled          = true
  aws_node_termination_handler_helm_config      = [
      templatefile("${path.module}/config/aws-node-termination-handler.yaml", {
        enable_service_monitor = true # This line applies configurations only when ADDONS "service_monitor_crd_enabled" is set to true.
      })
    ]


 
  velero_enabled                                = false
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
}
