locals {
  region      = "us-east-2"
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
  source                                  = "squareops/eks-addons/aws"
  name                                    = local.name
  vpc_id                                  = "vpc-abcd5245c2331xyz"
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:us-east-2:xxxxxxxxxx:key/mrk-abd9394bda5947cc864adc657d90386f"
  keda_enabled                            = true
  kms_policy_arn                          = "arn:aws:iam::xxxxxxxxxxxx:policy/policy_name" ## eks module will create kms_policy_arn
  eks_cluster_name                        = "cluster_name"
  reloader_enabled                        = true
  kubernetes_dashboard_enabled            = true
  k8s_dashboard_ingress_load_balancer     = "" ##Choose your load balancer type (e.g., NLB or ALB). If using ALB, ensure you provide the ACM certificate ARN for SSL.
  alb_acm_certificate_arn                 = ""
  k8s_dashboard_hostname                  = "dashboard.prod.in"
  karpenter_enabled                       = true
  private_subnet_ids                      = ["subnet-xxxxxxxxxxxx", "subnet-xxxxxxxxxxxx"]
  single_az_ebs_gp3_storage_class_enabled = true
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  coredns_hpa_enabled                     = true
  kubeclarity_enabled                     = true
  kubeclarity_hostname                    = "kubeclarity.prod.in"
  kubecost_enabled                        = false
  kubecost_hostname                       = "kubecost.prod.in"
  defectdojo_enabled                      = true
  defectdojo_hostname                     = "defectdojo.prod.in"
  cert_manager_enabled                    = true
  worker_iam_role_name                    = "node-role"
  worker_iam_role_arn                     = "arn:aws:iam::xxxxxxxxxx:role/node-role"
  ingress_nginx_enabled                   = true
  metrics_server_enabled                  = true
  external_secrets_enabled                = true
  amazon_eks_vpc_cni_enabled              = true
  cluster_autoscaler_enabled              = true
  service_monitor_crd_enabled             = true
  aws_load_balancer_controller_enabled    = true
  falco_enabled                           = true
  slack_webhook                           = "xoxb-379541400966-iibMHnnoaPzVl"
  istio_enabled                           = true
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
  cert_manager_letsencrypt_email                = "email@email.com"
  internal_ingress_nginx_enabled                = true
  efs_storage_class_enabled                     = true
  aws_node_termination_handler_enabled          = true
  amazon_eks_aws_ebs_csi_driver_enabled         = true
  cluster_propotional_autoscaler_enabled        = true
  cert_manager_install_letsencrypt_http_issuers = true
  velero_enabled                                = true
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