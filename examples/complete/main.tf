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
  cluster-name = "test-eks"
}
data "aws_eks_cluster" "eks" {
  name = "test-eks"  # Replace with your EKS cluster name
}

data "aws_eks_cluster_auth" "eks" {
  name = data.aws_eks_cluster.eks.name
}

module "eks-addons" {
  source                                  = "../.."
  name                                    = local.name
  tags                                    = local.additional_tags
  vpc_id                                  = "vpc-006a8b33465134b20"
  environment                             = local.environment
  ipv6_enabled                            = local.ipv6_enabled
  kms_key_arn                             = "arn:aws:kms:us-west-2:381491984451:key/mrk-2c97b496ebf9470ba8e93f8b08007ba9"
  keda_enabled                            = true #akanksha
  kms_policy_arn                          = "arn:aws:iam::381491984451:policy/test-eks-kubernetes-pvc-kms-policy" ## eks module will create kms_policy_arn
  eks_cluster_name                        = local.cluster-name
  ## Service Monitoring
  service_monitor_crd_enabled             = true #akanksha  
  # Config reloader
  reloader_enabled                        = true #divyanshu
  reloader_helm_config                    = [file("${path.module}/config/reloader.yaml")]
  kubernetes_dashboard_enabled            = false #akanksha (have to do)
  k8s_dashboard_ingress_load_balancer     = "" ##Choose your load balancer type (e.g., NLB or ALB). If using ALB, ensure you provide the ACM certificate ARN for SSL.
  alb_acm_certificate_arn                 = ""
  k8s_dashboard_hostname                  = "dashboard.prod.in"
  ## aws load balancer controller
  aws_load_balancer_controller_enabled    = true #divyanshu
  aws_load_balancer_controller_helm_config = {
    values = [file("${path.module}/config/aws-alb.yaml")]
  }
  ## karpenter 
  karpenter_enabled                       = true #akanksha
  karpenter_helm_config = {
    values = [file("${path.module}/config/karpenter.yaml")]
  }
  private_subnet_ids                      = ["subnet-015725e60c7f5b02e", "subnet-0c1b4027bdad304f5"]
  single_az_ebs_gp3_storage_class_enabled = true #akanksha
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  # coredns HPA
  coredns_hpa_enabled                     = false #divyanshu
  kubeclarity_enabled                     = false #phase2
  kubeclarity_hostname                    = "kubeclarity.prod.in"
  kubecost_enabled                        = false #phase2
  kubecost_hostname                       = "kubecost.prod.in"
  defectdojo_enabled                      = false #phase2
  defectdojo_hostname                     = "defectdojo.prod.in"
  ## Cert_Manager
  cert_manager_enabled                    = false #divyanshu
  cert_manager_helm_config                = {
    values = [file("${path.module}/config/cert-manager.yaml")]
  }
  cert_manager_install_letsencrypt_http_issuers = false #divyanshu
  cert_manager_letsencrypt_email                = "email@email.com"
  
  worker_iam_role_name                    = "test-eks-node-role"
  worker_iam_role_arn                     = "arn:aws:iam::381491984451:role/test-eks-node-role"
  ingress_nginx_enabled                   = true #akanksha
  enable_service_monitor                  = true # enable monitoring in nginx ingress
  ingress_nginx_helm_config = {
    values = [file("${path.module}/config/${data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family == "ipv4" ? "nginx-ingress.yaml" : "nginx-ingress_ipv6.yaml"}")]
  }
  ## Metric Server
  metrics_server_enabled                  = true #divyunshu
  metrics_server_helm_config              = [file("${path.module}/config/metrics-server.yaml")]
  vpa_config = {
    values = [file("${path.module}/config/vpa-crd.yaml")]
  }
  ## External Secrets
  external_secrets_enabled                = true #divyanshu
  external_secrets_helm_config            = {
    values = [file("${path.module}/config/external-secret.yaml")]
  }
  ## cluster autoscaler
  cluster_autoscaler_enabled              = true #divyanshu
  cluster_autoscaler_helm_config          = [file("${path.module}/config/cluster-autoscaler.yaml")]
  falco_enabled                           = false #phase2
  slack_webhook                           = "xoxb-379541400966-iibMHnnoaPzVl"
  # ISTIO
  istio_enabled                           = false #phase2
  istio_config = {
    ingress_gateway_enabled       = false
    egress_gateway_enabled        = false
    envoy_access_logs_enabled     = false
    prometheus_monitoring_enabled = false
    istio_values_yaml             = file("./config/istio.yaml")
  }
  # Kubernetes Provisioner
  karpenter_provisioner_enabled = true #akanksha
  karpenter_provisioner_config = {
    private_subnet_name    = "${local.environment}-${local.name}-private-subnet"
    instance_capacity_type = ["spot"]
    excluded_instance_type = ["nano", "micro", "small"]
    instance_hypervisor    = ["nitro"]
  }
  # Internal Ingress Nginx
  internal_ingress_nginx_enabled                = true #akanksha
  internal_nginx_config = {
    values = file("${path.module}/config/${data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family == "ipv4" ? "internal-ingress.yaml" : "internal-ingress-ipv6.yaml"}") 
  }
  efs_storage_class_enabled                     = true #akanksha
  #Node termination handler
  aws_node_termination_handler_enabled          = true #divyanshu
  aws_node_termination_handler_helm_config      = [file("${path.module}/config/aws-node-termination-handler.yaml")]
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
}
