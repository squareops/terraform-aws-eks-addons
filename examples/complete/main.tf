locals {
  region      = "" # Enter region of EKS cluster
  environment = ""
  name        = ""
  additional_tags = {
    Owner      = "Organization_Name"
    Expires    = "Never"
    Department = "Engineering"
    Product    = ""
    Environment = local.environment
  }
  kms_key_arn  = "arn:aws:kms:us-west-1:xxxxxxx:key/mrk-xxxxxxx" # pass ARN of EKS created KMS key
  ipv6_enabled = false
}

module "eks-addons" {
  source               = "../.."
  name                 = local.name
  tags                 = local.additional_tags
  vpc_id               = "vpc-xxxxxx"                     # pass VPC ID
  private_subnet_ids   = ["subnet-xxxxx", "subnet-xxxxx"] # pass Subnet IDs
  environment          = local.environment
  ipv6_enabled         = local.ipv6_enabled
  kms_key_arn          = local.kms_key_arn
  kms_policy_arn       = "arn:aws:iam::xxx:policy/eks-kms-policy" # eks module will create kms_policy_arn
  worker_iam_role_name = "update-eks-node-role"                   # enter role name created by eks module
  worker_iam_role_arn  = "arn:aws:iam::xxx:role/eks-node-role"    # enter roll ARN
  eks_cluster_name     = data.aws_eks_cluster.cluster.name

  #VPC-CNI-DRIVER
  amazon_eks_vpc_cni_enabled = false # enable VPC-CNI

  #EBS-CSI-DRIVER
  enable_amazon_eks_aws_ebs_csi_driver = false # enable EBS CSI Driver
  amazon_eks_aws_ebs_csi_driver_config = {
    values = [file("${path.module}/config/ebs-csi.yaml")]
  }

  ## EBS-STORAGE-CLASS
  single_az_ebs_gp3_storage_class_enabled = false # to enable ebs gp3 storage class
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]
  tag_product                             = local.additional_tags.Product
  tag_environment                         = local.environment

  ## EfS-STORAGE-CLASS
  efs_storage_class_enabled = false # to enable EBS storage class

  ## SERVICE-MONITORING-CRDs
  service_monitor_crd_enabled = false # enable service monitor along with K8S-dashboard (required CRD) or when require service monitor in reloader and cert-manager

  ## METRIC-SERVER
  metrics_server_enabled     = false # to enable metrics server
  metrics_server_helm_config = [file("${path.module}/config/metrics-server.yaml")]
  vpa_config = {
    values = [file("${path.module}/config/vpa-crd.yaml")]
  }

  ## CLUSTER-AUTOSCALER
  cluster_autoscaler_enabled     = false # to enable cluster autoscaller
  cluster_autoscaler_helm_config = [file("${path.module}/config/cluster-autoscaler.yaml")]

  ## NODE-TERMINATION-HANDLER
  aws_node_termination_handler_enabled = false # to enable node termination handler
  aws_node_termination_handler_helm_config = {
    values                 = [file("${path.module}/config/aws-node-termination-handler.yaml")]
    enable_service_monitor = false # to enable monitoring for node termination handler
  }

  ## KEDA
  keda_enabled = false # to enable Keda in the EKS cluster
  keda_helm_config = {
    values = [file("${path.module}/config/keda.yaml")]
  }

  ## KARPENTER
  karpenter_enabled = false # to enable Karpenter (installs required CRDs )
  karpenter_helm_config = {
    values = [file("${path.module}/config/karpenter.yaml")]
  }

  ## KARPENTER-PROVISIONER
 karpenter_provisioner_enabled = false # to enable provisioning nodes with Karpenter in the EKS cluster
  karpenter_provisioner_config = {
    provisioner_name              = format("karpenter-provisioner-%s", local.name)
    karpenter_label               = ["Mgt-Services", "Monitor-Services", "ECK-Services"]
    provisioner_values            = file("./config/karpenter-management.yaml")
    instance_capacity_type        = ["spot"]
    excluded_instance_type        = ["nano", "micro", "small"]
    ec2_instance_family           = ["t3"]
    ec2_instance_type             = ["t3.medium"]
    private_subnet_selector_key   = "Environment"
    private_subnet_selector_value = local.environment
    security_group_selector_key   = "aws:eks:cluster-name"
    security_group_selector_value = "${local.environment}-${local.name}"
    instance_hypervisor           = ["nitro"]
    kms_key_arn                   = local.kms_key_arn
  }
  ## coreDNS-HPA (cluster-proportional-autoscaler)
  coredns_hpa_enabled = false # to enable core-dns HPA
  coredns_hpa_helm_config = {
    values = [file("${path.module}/config/coredns-hpa.yaml")]
  }

  ## EXTERNAL-SECRETS
  external_secrets_enabled = false # to enable external secrets
  external_secrets_helm_config = {
    values = [file("${path.module}/config/external-secret.yaml")]
  }

  ## CERT-MANAGER
  cert_manager_enabled = false # to enable Cert-manager
  cert_manager_helm_config = {
    values                         = [file("${path.module}/config/cert-manager.yaml")]
    enable_service_monitor         = false # to enable monitoring for Cert Manager
    cert_manager_letsencrypt_email = "mona@squareops.com"
  }

  ## CONFIG-RELOADER
  reloader_enabled = false # to enable config reloader in the EKS cluster
  reloader_helm_config = {
    values                 = [file("${path.module}/config/reloader.yaml")]
    enable_service_monitor = false # to enable monitoring for reloader
  }

  ## INGRESS-NGINX
  ingress_nginx_enabled = false # to enable ingress nginx
  private_nlb_enabled   = false # to enable Internal (Private) Ingress , set this and ingress_nginx_enable "false" together
  ingress_nginx_config = {
    values                 = [file("${path.module}/config/ingress-nginx.yaml")]
    enable_service_monitor = false   # enable monitoring in nginx ingress
    ingress_class_name     = "nginx" # enter ingress class name according to your requirement (example: "nginx", "internal-ingress")
    namespace              = "nginx" # enter namespace according to the requirement (example: "nginx", "internal-ingress")
  }

  ## AWS-APPLICATION-LOAD-BALANCER-CONTROLLER
  aws_load_balancer_controller_enabled = false # to enable load balancer controller
  aws_load_balancer_controller_helm_config = {
    values                        = [file("${path.module}/config/aws-alb.yaml")]
    namespace                     = "alb"       # enter namespace according to the requirement (example: "alb")
    load_balancer_controller_name = "alb" # enter ingress class name according to your requirement (example: "aws-load-balancer-controller")
  }

  ## KUBERNETES-DASHBOARD
  kubernetes_dashboard_enabled = false
  kubernetes_dashboard_config = {
    k8s_dashboard_ingress_load_balancer = "nlb"                                                                                 ##Choose your load balancer type (e.g., NLB or ALB). Enable load balancer controller, if you require ALB, Enable Ingress Nginx if NLB.
    private_alb_enabled                 = false                                                                                 # to enable Internal (Private) ALB , set this and aws_load_balancer_controller_enabled "true" together
    alb_acm_certificate_arn             = "arn:aws:acm:us-east-1:381491984451:certificate/b7fe797d-cefd-4272-94b3-1ef668eb79a3" # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
    k8s_dashboard_hostname              = "k8s-dashboard.rnd.squareops.in"                                                      # Enter Hostname
  }

  # VELERO
  velero_enabled              = false # to enable velero
  velero_notification_enabled = false # To enable slack notification for Velero
  velero_config = {
    namespaces                      = "" ## If you want full cluster backup, leave it blank else provide namespace.
    slack_botToken                  = "xoxb-379541400966-iibMHnnoaPzVl"
    slack_appToken                  = "xoxb-sgsehger-ddfnrndfnf"
    slack_notification_channel_name = "slack-notification-channel"
    retention_period_in_days        = 45
    schedule_backup_cron_time       = "* 6 * * *"
    velero_backup_name              = "application-backup"
    backup_bucket_name              = "velero-test-eks-1.30" # Enter the S3 bucket name for velero
    velero_values_yaml              = [file("${path.module}/config/velero.yaml")]
  }

  ## KUBECLARITY
  kubeclarity_enabled  = false # to enable kube clarity
  kubeclarity_hostname = "kubeclarity.prod.in"

  ## KUBECOST
  kubecost_enabled  = false # to enable kube cost
  kubecost_hostname = "kubecost.prod.in"

  ## DEFECT-DOJO
  defectdojo_enabled  = false # to enable defectdojo
  defectdojo_hostname = "defectdojo.prod.in"

  ## FALCO
  falco_enabled = false # to enable falco
  slack_webhook = "xoxb-379541400966-iibMHnnoaPzVl"
}
