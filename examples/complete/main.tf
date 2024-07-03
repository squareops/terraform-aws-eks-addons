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
}

module "eks-addons" {
  source                                  = "../.."
  name                                    = local.name
  tags                                    = local.additional_tags
  vpc_id                                  = "vpc-02bfac6591f1996d6"
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:us-west-2:767398031518:key/mrk-3d418218b71b464a8f6ae5c3117d777b"
  keda_enabled                            = false
  kms_policy_arn                          = "arn:aws:iam::767398031518:policy/test-atmosly-task-ipv4-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  eks_cluster_name                        = "test-atmosly-task-ipv4"
  # Config reloader
  reloader_enabled                        = false
  kubernetes_dashboard_enabled            = false
  k8s_dashboard_ingress_load_balancer     = "" ##Choose your load balancer type (e.g., NLB or ALB). If using ALB, ensure you provide the ACM certificate ARN for SSL.
  alb_acm_certificate_arn                 = ""
  k8s_dashboard_hostname                  = "dashboard.prod.in"
  karpenter_enabled                       = false
  private_subnet_ids                      = ["subnet-05c042969aea94a74", "subnet-00f87508b7b1e507c"]
  single_az_ebs_gp3_storage_class_enabled = false
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  coredns_hpa_enabled                     = false
  kubeclarity_enabled                     = false
  kubeclarity_hostname                    = "kubeclarity.prod.in"
  kubecost_enabled                        = false
  kubecost_hostname                       = "kubecost.prod.in"
  defectdojo_enabled                      = false
  defectdojo_hostname                     = "defectdojo.prod.in"
  ## Cert_Manager
  cert_manager_enabled                    = true
  cert_manager_install_letsencrypt_http_issuers = true
  cert_manager_letsencrypt_email                = "email@email.com"
  
  worker_iam_role_name                    = "test-atmosly-task-ipv4-node-role"
  worker_iam_role_arn                     = "arn:aws:iam::767398031518:role/test-atmosly-task-ipv4-node-role"
  ingress_nginx_enabled                   = false
  ## Metric Server
  metrics_server_enabled                  = false
  ## External Secrets
  external_secrets_enabled                = false
  ## cluster autoscaler
  cluster_autoscaler_enabled              = false
  ## Service Mon
  service_monitor_crd_enabled             = false
  ## aws load balancer controller
  aws_load_balancer_controller_enabled    = false
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
  aws_node_termination_handler_enabled          = false


 
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
