locals {
  region      = "us-west-2"
  environment = "test-aj"
  name        = "addons"
  additional_tags = {
    Owner      = "atmosly"
    Expires    = "Never"
    Department = "Engineering"
  }
  ipv6_enabled = false
}

module "eks-addons" {
  source                                  = "../.."
  name                                    = local.name
  vpc_id                                  = "vpc-0c05bf2f75f743d98"
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:us-west-2:767398031518:key/mrk-7cde5b3ba8204e4d9f4914c023cb9476"
  keda_enabled                            = true
  kms_policy_arn                          = "arn:aws:iam::767398031518:policy/test-aj-eks-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  eks_cluster_name                        = "non-prod-Feb265"
  reloader_enabled                        = false
  kubernetes_dashboard_enabled            = true
  k8s-dashboard-hostname                  = "k8-dashboard.atmosly.in"
  karpenter_enabled                       = true
  private_subnet_ids                      = ["subnet-0490cafece5c4f182", "subnet-062f3bde491fef1ec"]
  single_az_ebs_gp3_storage_class_enabled = true
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  coredns_hpa_enabled                     = true
  kubeclarity_enabled                     = false
  kubeclarity_hostname                    = "kubeclarity.prod.in"
  kubecost_enabled                        = false
  kubecost_hostname                       = "kubecost.prod.in"
  defectdojo_enabled                      = false
  defectdojo_hostname                     = "defectdojo.prod.in"
  cert_manager_enabled                    = true
  worker_iam_role_name                    = "test-aj-eks-node-role"
  worker_iam_role_arn                     = "arn:aws:iam::767398031518:role/test-aj-eks-node-role"
  ingress_nginx_enabled                   = true
  metrics_server_enabled                  = false
  external_secrets_enabled                = false
  amazon_eks_vpc_cni_enabled              = false
  cluster_autoscaler_enabled              = true
  service_monitor_crd_enabled             = true
  aws_load_balancer_controller_enabled    = true
  falco_enabled                           = false
  slack_webhook                           = "xoxb-379541400966-iibMHnnoaPzVl"
  istio_enabled                           = false
  istio_config = {
    ingress_gateway_enabled       = true
    egress_gateway_enabled        = true
    envoy_access_logs_enabled     = true
    prometheus_monitoring_enabled = true
    istio_values_yaml             = file("./config/istio.yaml")
  }
  karpenter_provisioner_enabled = false
  karpenter_provisioner_config = {
    private_subnet_name    = "${local.environment}-${local.name}-private-subnet"
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }
  cert_manager_letsencrypt_email                = "ajay@squareops.com"
  internal_ingress_nginx_enabled                = false
  efs_storage_class_enabled                     = true
  aws_node_termination_handler_enabled          = true
  amazon_eks_aws_ebs_csi_driver_enabled         = true
  cluster_propotional_autoscaler_enabled        = true
  cert_manager_install_letsencrypt_http_issuers = true
  velero_enabled                                = false
  velero_config = {
    namespaces                      = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_notification_token        = "xoxb-379541400966-iibMHnnoaPzVl"
    slack_notification_channel_name = "slack-notification-channel"
    retention_period_in_days        = 45
    schedule_backup_cron_time       = "* 6 * * *"
    velero_backup_name              = "application-backup"
    backup_bucket_name              = "velero-bucket"
  }
}