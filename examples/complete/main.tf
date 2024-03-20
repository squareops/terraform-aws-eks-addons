locals {
  region      = "us-west-2"
  environment = "prod"
  name        = "addons"
  velero_s3_bucket_lifecycle_rules = {
    rule1 = {
      id              = "rule1"
      expiration_days = 120
      filter_prefix   = "log/"
      status          = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "DEEP_ARCHIVE"
        }
      ]
    }
  }
  additional_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
  }
  ipv6_enabled = false
}

module "eks-addons" {
  source                                  = "squareops/eks-addons/aws"
  name                                    = local.name
  vpc_id                                  = "vpc-0727eb64ef19add68"
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:us-west-2:654654551614:key/86ec1819-8531-442b-88ba-0e80a96a0d1d"
  keda_enabled                            = true
  kms_policy_arn                          = "arn:aws:iam::654654551614:policy/proddd-eks-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  eks_cluster_name                        = "proddd-eks"
  reloader_enabled                        = true
  kubernetes_dashboard_enabled            = true
  k8s_dashboard_hostname                  = "dashboard.prod.in"
  karpenter_enabled                       = true
  private_subnet_ids                      = ["subnet-0f579bfe647370932", "subnet-07da41a7e8387d8bd"]
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
  worker_iam_role_name                    = "proddd-eks-node-role"
  worker_iam_role_arn                     = "arn:aws:iam::654654551614:role/proddd-eks-node-role"
  ingress_nginx_enabled                   = true
  metrics_server_enabled                  = true
  external_secrets_enabled                = true
  amazon_eks_vpc_cni_enabled              = true
  cluster_autoscaler_enabled              = true
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
  cluster_propotional_autoscaler_enabled        = true
  cert_manager_install_letsencrypt_http_issuers = true
  velero_enabled                                = true
  velero_config = {
    namespaces                          = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_notification_token            = "xoxb-379541400966-iibMHnnoaPzVl"
    slack_notification_channel_name     = "slack-notification-channel"
    retention_period_in_days            = 45
    schedule_backup_cron_time           = "* 6 * * *"
    velero_backup_name                  = "application-backup"
    backup_bucket_name                  = "test-velero-bucket-1"
    velero_s3_bucket_lifecycle_rules    = local.velero_s3_bucket_lifecycle_rules
    velero_s3_bucket_object_lock_mode   = "GOVERNANCE"
    velero_s3_bucket_object_lock_days   = "0"
    velero_s3_bucket_object_lock_years  = "2"
    velero_s3_bucket_enable_object_lock = true
  }
}
