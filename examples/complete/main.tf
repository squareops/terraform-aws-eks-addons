locals {
  aws_region             = "ap-south-1"
  vpc_private_subnet_ids = ["subnet-085147f1679dbb531", "subnet-0214cfbbf6b970a55"]
  environment            = "stg"
  name                   = "addons"
  additional_aws_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  ipv6_enabled = false
}

module "eks-addons" {
  source                                  = "../../"
  aws_region                              = local.aws_region
  name                                    = local.name
  vpc_id                                  = "vpc-02a53a479ff0543af"
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:ap-south-1:654654551614:key/dfac77d0-063a-4e94-b10f-e33b1076db4a"
  keda_enabled                            = true
  kms_policy_arn                          = "arn:aws:iam::654654551614:policy/stg-rachit-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  eks_cluster_name                        = "stg-rachit"
  reloader_enabled                        = true
  kubernetes_dashboard_enabled            = true
  k8s_dashboard_hostname                  = "dashboard-stg.ldc.squareops.in"
  karpenter_enabled                       = true
  vpc_private_subnet_ids                  = local.vpc_private_subnet_ids
  single_az_ebs_gp3_storage_class_enabled = true
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.aws_region}a" }]
  coredns_hpa_enabled                     = true
  kubeclarity_enabled                     = true
  kubeclarity_hostname                    = "kubeclarity-stg.ldc.squareops.in"
  kubecost_enabled                        = false
  kubecost_hostname                       = "kubecost-stg.ldc.squareops.in"
  defectdojo_enabled                      = true
  defectdojo_hostname                     = "defectdojo-stg.ldc.squareops.in"
  cert_manager_enabled                    = true
  worker_iam_role_name                    = "stg-rachit-node-role"
  worker_iam_role_arn                     = "arn:aws:iam::654654551614:role/stg-rachit-node-role"
  ingress_nginx_enabled                   = true
  eks_cluster_metrics_server_enabled      = true
  external_secrets_enabled                = true
  amazon_eks_vpc_cni_enabled              = true
  eks_cluster_autoscaler_enabled          = true
  service_monitor_crd_enabled             = true
  aws_load_balancer_controller_enabled    = true
  falco_enabled                           = true
  slack_webhook                           = "xoxb-379541400966-iibMHnnoaPzVl"
  istio_enabled                           = false
  istio_config = {
    ingress_gateway_enabled       = true
    egress_gateway_enabled        = true
    envoy_access_logs_enabled     = true
    prometheus_monitoring_enabled = true
    istio_values_yaml             = file("./config/istio.yaml")
  }
  karpenter_provisioner_enabled = true
  karpenter_provisioner_config = {
    private_subnet_name    = "${local.environment}-${local.name}-private-subnet"
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }
  cert_manager_letsencrypt_email                = "rachit.maheshwari@squareops.com"
  internal_ingress_nginx_enabled                = true
  efs_storage_class_enabled                     = true
  aws_node_termination_handler_enabled          = true
  amazon_eks_aws_ebs_csi_driver_enabled         = true
  eks_cluster_propotional_autoscaler_enabled    = true
  cert_manager_install_letsencrypt_http_issuers = true
  velero_enabled                                = false
  velero_config = {
    namespaces                      = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_notification_token        = "xoxb-379541400966-iibMHnnoaPzVl"
    slack_notification_channel_name = "slack-notification-channel"
    retention_period_in_days        = 45
    schedule_backup_cron_time       = "* 6 * * *"
    velero_backup_name              = "application-backup"
    backup_bucket_name              = "velero-bucket-rachit"
  }
}
