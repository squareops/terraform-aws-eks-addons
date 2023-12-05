locals {
  region      = "us-east-2"
  environment = "prod"
  name        = "addons"
  additional_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  ipv6_enabled = true
}

module "eks-addons" {
  source                               = "squareops/eks-addons/aws"
  name                                 = local.name
  vpc_id                               = "vpc-aba8a102ccxyza"
  environment                          = local.environment
  ipv6_enabled                         = local.ipv6_enabled
  kms_key_arn                          = "arn:aws:kms:${local.region}:222222222222:key/e2b8a99d-b8b1"
  keda_enabled                         = true
  kms_policy_arn                       = "arn:aws:iam::222222222222:policy/eks-cluster-policy" ## eks module will create kms_policy_arn
  eks_cluster_name                     = "eks_cluster_name"
  reloader_enabled                     = true
  karpenter_enabled                    = true
  private_subnet_ids                   = ["subnet-b2c34cd9279xyza", "subnet-7ef8daf598fxyza"]
  single_az_sc_config                  = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  kubeclarity_enabled                  = true
  kubeclarity_hostname                 = "kubeclarity.prod.in"
  kubecost_enabled                     = true
  kubecost_hostname                    = "kubecost.prod.in"
  defectdojo_enabled                   = true
  defectdojo_hostname                  = "defectdojo.prod.in"
  cert_manager_enabled                 = true
  worker_iam_role_name                 = ""
  worker_iam_role_arn                  = ""
  ingress_nginx_enabled                = true
  metrics_server_enabled               = true
  external_secrets_enabled             = true
  amazon_eks_vpc_cni_enabled           = true
  cluster_autoscaler_enabled           = true
  service_monitor_crd_enabled          = true
  aws_load_balancer_controller_enabled = true
  istio_enabled                        = true
  istio_config = {
    ingress_gateway_enabled       = true
    egress_gateway_enabled        = true
    envoy_access_logs_enabled     = true
    prometheus_monitoring_enabled = true
    istio_values_yaml             = ""
  }
  karpenter_provisioner_enabled = true
  karpenter_provisioner_config = {
    private_subnet_name    = "${local.environment}-${local.name}-private-subnet"
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }
  cert_manager_letsencrypt_email                = "email@email.com"
  internal_ingress_nginx_enabled                = true
  efs_storage_class_enabled                     = true
  aws_node_termination_handler_enabled          = true
  amazon_eks_aws_ebs_csi_driver_enabled         = true
  cluster_propotional_autoscaler_enabled        = true
  single_az_ebs_gp3_storage_class_enabled       = true
  cert_manager_install_letsencrypt_http_issuers = true
  velero_enabled                                = true
  velero_config = {
    namespaces                      = "my-application" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_notification_token        = "xoxb-EuvmxrYxRatsM8R"
    slack_notification_channel_name = "slack-notifications-channel"
    retention_period_in_days        = 45
    schedule_backup_cron_time       = "* 6 * * *"
    velero_backup_name              = "my-application-backup"
    backup_bucket_name              = "velero-cluster-backup"
  }
}
