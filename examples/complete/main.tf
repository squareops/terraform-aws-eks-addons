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
  ingress_type = "public" ## public is Ingress and private is internal-ingress-nginx
  domain_name  = "mgt.skaf.squareops.in"
}

data "aws_route53_zone" "selected" {
  name = "skaf.squareops.in"
}

data "aws_lb_hosted_zone_id" "main" {
  load_balancer_type = "network"
}

module "eks-addons" {
  source                              = "squareops/eks-addons/aws"
  name                                = local.name
  vpc_id                              = ""
  environment                         = local.environment
  ipv6_enabled                        = local.ipv6_enabled
  kms_key_arn                         = ""
  keda_enabled                        = true
  kms_policy_arn                      = "" ## eks module will create kms_policy_arn
  eks_cluster_name                    = ""
  reloader_enabled                    = true
  karpenter_enabled                   = true
  private_subnet_ids                  = [""]
  single_az_sc_config                 = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  ingress_type                        = local.ingress_type
  kubeclarity_enabled                 = true
  kubeclarity_hostname                = "kubeclarity.${local.domain_name}"
  kubecost_enabled                    = true
  kubecost_hostname                   = "kubecost.${local.domain_name}"
  cert_manager_enabled                = true
  worker_iam_role_name                = ""
  worker_iam_role_arn                 = ""
  ingress_nginx_enabled               = true
  metrics_server_enabled              = true
  external_secrets_enabled            = true
  amazon_eks_vpc_cni_enabled          = true
  cluster_autoscaler_enabled          = true
  service_monitor_crd_enabled         = true
  enable_aws_load_balancer_controller = true
  istio_enabled                       = true
  istio_config = {
    ingress_gateway_enabled       = true
    egress_gateway_enabled        = false
    envoy_access_logs_enabled     = true
    prometheus_monitoring_enabled = true
  }
  karpenter_provisioner_enabled = true
  karpenter_provisioner_config = {
    private_subnet_name    = "private-subnet-name"
    instance_capacity_type = ["on-demand"]
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

resource "aws_route53_record" "kubeclarity" {
  depends_on = [module.eks-addons]
  zone_id    = data.aws_route53_zone.selected.zone_id
  name       = join(".", ["kubeclarity", local.domain_name])
  type       = "A"

  alias {
    name                   = module.eks-addons.internal_nginx_ingress_controller_dns_hostname
    zone_id                = data.aws_lb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "kubecost" {
  depends_on = [module.eks-addons]
  zone_id    = data.aws_route53_zone.selected.zone_id
  name       = join(".", ["kubecost", local.domain_name])
  type       = "A"

  alias {
    name                   = module.eks-addons.internal_nginx_ingress_controller_dns_hostname
    zone_id                = data.aws_lb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}
