# terraform-aws-eks-addons
![squareops_avatar]

[squareops_avatar]: https://squareops.com/wp-content/uploads/2022/12/squareops-logo.png

### [SquareOps Technologies](https://squareops.com/) Your DevOps Partner for Accelerating cloud journey.
<br>
This module provides a set of reusable, configurable, and scalable AWS EKS addons configurations. It enables users to easily deploy and manage a highly available EKS cluster using infrastructure as code. This module supports a wide range of features, including node termination handlers, VPC CNI add-ons, service monitors, Velero backups, and Karpenter provisioners. Users can configure these features using a set of customizable variables that allow for fine-grained control over the deployment. Additionally, this module is regularly updated to keep pace with the latest changes in the EKS ecosystem, ensuring that users always have access to the most up-to-date features and functionality.

## Usage Example
```hcl
module "eks-addons" {
  source               = "squareops/eks-addons/aws"
  version              = "4.0.2"
  name                 = local.name
  tags                 = local.additional_tags
  vpc_id               = local.vpc_id
  private_subnet_ids   = local.private_subnet_ids # pass the private subnet IDs
  public_subnet_ids    = local.public_subnet_ids  # pass the private subnet IDs
  environment          = local.environment
  ipv6_enabled         = local.ipv6_enabled
  kms_key_arn          = local.kms_key_arn
  kms_policy_arn       = local.kms_policy_arn
  worker_iam_role_arn  = local.worker_iam_role_arn
  worker_iam_role_name = local.worker_iam_role_name
  eks_cluster_name     = data.aws_eks_cluster.cluster.name

  #VPC-CNI-DRIVER
  amazon_eks_vpc_cni_enabled = true # enable VPC-CNI
  vpc_cni_version            = "v1.19.3-eksbuild.1"

  #EBS-CSI-DRIVER
  enable_amazon_eks_aws_ebs_csi_driver = false # enable EBS CSI Driver
  ebs_csi_driver_version               = "v1.41.0-eksbuild.1"
  amazon_eks_aws_ebs_csi_driver_config = {
    values = [file("${path.module}/config/ebs-csi.yaml")]
  }

  ## EBS-STORAGE-CLASS
  single_az_ebs_gp3_storage_class_enabled = false # to enable ebs gp3 storage class
  single_az_sc_config                     = [{ name = "infra-service-sc", zone = "${local.region}a" }]

  ## EfS-STORAGE-CLASS
  efs_storage_class_enabled = false # to enable EBS storage class
  efs_version               = "3.1.8"

  ## SERVICE-MONITORING-CRDs
  service_monitor_crd_enabled = false # enable service monitor along with K8S-dashboard (required CRD) or when require service monitor in reloader and cert-manager

  ## METRIC-SERVER
  metrics_server_enabled     = false # to enable metrics server
  metrics_server_version     = "3.12.2"
  metrics_server_helm_config = [file("${path.module}/config/metrics-server.yaml")]

  # VerticalPodAutoscaler
  vpa_enabled = false
  vpa_version = "10.0.0"
  vpa_config = {
    values = [file("${path.module}/config/vpa-crd.yaml")]
  }

  ## CLUSTER-AUTOSCALER
  cluster_autoscaler_enabled     = false # to enable cluster autoscaller
  cluster_autoscaler_version     = "9.46.6"
  cluster_autoscaler_helm_config = [file("${path.module}/config/cluster-autoscaler.yaml")]

  ## NODE-TERMINATION-HANDLER
  aws_node_termination_handler_enabled = false # to enable node termination handler
  aws_node_termination_handler_version = "0.21.0"
  aws_node_termination_handler_helm_config = {
    values                 = [file("${path.module}/config/aws-node-termination-handler.yaml")]
    enable_service_monitor = false # to enable monitoring for node termination handler
    enable_notifications   = false
  }

  ## KEDA
  keda_enabled = false # to enable Keda in the EKS cluster
  keda_version = "2.17.0"
  keda_helm_config = {
    values = [file("${path.module}/config/keda.yaml")]
  }

  ## KARPENTER
  karpenter_enabled = false # to enable Karpenter (installs required CRDs )
  karpenter_version = "1.3.3"
  karpenter_helm_config = {
    enable_service_monitor = false # to enable monitoring for kafalserpenter
    values                 = [file("${path.module}/config/karpenter.yaml")]
  }

  ## coreDNS-HPA (cluster-proportional-autoscaler)
  coredns_hpa_enabled = false # to enable core-dns HPA
  coredns_hpa_helm_config = {
    values = [file("${path.module}/config/coredns-hpa.yaml")]
  }

  ## ClusterProportionalAutoscaler (Configured for CoreDNS)
  cluster_proportional_autoscaler_enabled       = false # to enable cluster proportional autoscaler
  cluster_proportional_autoscaler_chart_version = "1.1.0"
  cluster_proportional_autoscaler_helm_config   = [file("${path.module}/config/cluster-proportional-autoscaler.yaml")]

  ## EXTERNAL-SECRETS
  external_secrets_enabled = false # to enable external secrets
  external_secrets_version = "0.15.1"
  external_secrets_helm_config = {
    values = [file("${path.module}/config/external-secret.yaml")]
  }

  ## CERT-MANAGER
  cert_manager_enabled = false # to enable Cert-manager
  cert_manager_version = "v1.15.1"
  cert_manager_helm_config = {
    values                         = [file("${path.module}/config/cert-manager.yaml")]
    enable_service_monitor         = false # to enable monitoring for Cert Manager
    cert_manager_letsencrypt_email = "email@email.com"
  }

  ## CONFIG-RELOADER
  reloader_enabled = false # to enable config reloader in the EKS cluster
  reloader_version = "v1.0.115"
  reloader_helm_config = {
    values                 = [file("${path.module}/config/reloader.yaml")]
    enable_service_monitor = false # to enable monitoring for reloader
  }

  ## INGRESS-NGINX
  ingress_nginx_enabled = false # to enable ingress nginx
  ingress_nginx_version = "4.11.0"
  ingress_nginx_config = {
    values                 = [file("${path.module}/config/ingress-nginx.yaml")]
    enable_service_monitor = false   # enable monitoring in nginx ingress
    ingress_class_name     = "nginx" # enter ingress class name according to your requirement
    namespace              = "nginx" # enter namespace according to the requirement
  }

  ## PRIVATE INGRESS-NGINX
  private_ingress_nginx_enabled = false # to enable Internal (Private) Ingress
  private_ingress_nginx_version = "4.11.0"
  private_ingress_nginx_config = {
    values                 = [file("${path.module}/config/ingress-nginx.yaml")]
    enable_service_monitor = false           # enable monitoring in nginx ingress
    ingress_class_name     = "private-nginx" # enter ingress class name according to your requirement (example: "nginx", "internal-ingress")
    namespace              = "private-nginx" # enter namespace according to the requirement (example: "nginx", "internal-ingress")
  }

  ## AWS-APPLICATION-LOAD-BALANCER-CONTROLLER
  aws_load_balancer_controller_enabled = false # to enable load balancer controller
  aws_load_balancer_controller_version = "1.8.1"
  aws_load_balancer_controller_helm_config = {
    values                        = [file("${path.module}/config/aws-alb.yaml")]
    namespace                     = "alb" # enter namespace according to the requirement (example: "alb")
    load_balancer_controller_name = "alb" # enter ingress class name according to your requirement (example: "aws-load-balancer-controller")
  }

  ## KUBERNETES-DASHBOARD
  kubernetes_dashboard_enabled = false
  kubernetes_dashboard_version = "6.0.8"
  kubernetes_dashboard_config = {
    k8s_dashboard_ingress_load_balancer = "nlb"                            # Pass either "nlb/alb" to choose load balancer controller as ingress-nginx controller or ALB controller
    private_alb_enabled                 = false                            # to enable Internal (Private) ALB , set this and aws_load_balancer_controller_enabled "true" together
    alb_acm_certificate_arn             = ""                               # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
    k8s_dashboard_hostname              = "k8s-dashboard.rnd.squareops.in" # Enter Hostname
    ingress_class_name                  = "nginx"                          # For public nlb use "nginx", for private NLB use "private-nginx", For ALB, use "alb"
  }

  ## ArgoCD
  argocd_enabled = false
  argocd_version = "7.3.11"
  argocd_config = {
    hostname                     = "argocd.rnd.squareops.in"
    values_yaml                  = file("${path.module}/config/argocd.yaml")
    namespace                    = local.argocd_namespace
    redis_ha_enabled             = true
    autoscaling_enabled          = true
    slack_notification_token     = ""
    argocd_notifications_enabled = false
    ingress_class_name           = "nginx" # For public nlb use "nginx", for private NLB use "private-nginx", For ALB, use "alb"
    argocd_ingress_load_balancer = "nlb"   # Pass either "nlb/alb" to choose load balancer controller as ingress-nginx controller or ALB controller
    private_alb_enabled          = "false" # to enable Internal (Private) ALB , set this and aws_load_balancer_controller_enabled "true" together
    alb_acm_certificate_arn      = ""      # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
  }
  argoproject_config = {
    name = "argo-project" # enter name for aro-project appProjects
  }

  ## ArgoCD-Workflow
  argoworkflow_enabled = false
  argoworkflow_version = "0.29.2"
  argoworkflow_config = {
    values                             = file("${path.module}/config/argocd-workflow.yaml")
    namespace                          = local.argocd_namespace
    autoscaling_enabled                = true
    hostname                           = "argoworkflow.rnd.squareops.in"
    ingress_class_name                 = "nginx" # For public nlb use "nginx", for private NLB use "private-nginx", For ALB, use "alb"
    argoworkflow_ingress_load_balancer = "nlb"   # Pass either "nlb/alb" to choose load balancer controller as ingress-nginx controller or ALB controller
    private_alb_enabled                = "false" # to enable Internal (Private) ALB , set this and aws_load_balancer_controller_enabled "true" together
    alb_acm_certificate_arn            = ""      # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
  }

  ## ArgoRollout
  argorollout_enabled = false
  argorollout_config = {
    values                            = file("${path.module}/config/argo-rollout.yaml")
    namespace                         = local.argocd_namespace
    hostname                          = "argo-rollout.rnd.squareops.in"
    enable_dashboard                  = false
    ingress_class_name                = "nginx" # For public nlb use "nginx", for private NLB use "private-nginx", For ALB, use "alb"
    argorollout_ingress_load_balancer = "nlb"   # Pass either "nlb/alb" to choose load balancer controller as ingress-nginx controller or ALB controller
    private_alb_enabled               = "false" # to enable Internal (Private) ALB , set this and aws_load_balancer_controller_enabled "true" together
    alb_acm_certificate_arn           = ""      # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
    chart_version                     = "2.38.0"
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
  kubeclarity_version  = "2.23.0"
  kubeclarity_hostname = "kubeclarity.prod.in"

  ## KUBECOST
  kubecost_enabled  = false # to enable kube cost
  kubecost_version  = "v2.1.0-eksbuild.1"
  kubecost_hostname = "kubecost.prod.in"

  ## DEFECT-DOJO
  defectdojo_enabled  = false # to enable defectdojo
  defectdojo_hostname = "defectdojo.prod.in"

  ## FALCO
  falco_enabled = false # to enable falco
  falco_version = "4.0.0"
  slack_webhook = "xoxb-379541400966-iibMHnnoaPzVl"
}



```

## Compatibility

| Release | Kubernetes 1.23 | Kubernetes 1.24  | Kubernetes 1.25 |  Kubernetes 1.26 |  Kubernetes 1.27 |  Kubernetes 1.28 | Kubernetes 1.29 | Kubernetes 1.30 |
|------------------|------------------|------------------|----------------------|----------------------|----------------------|----------------------|----------------------|----------------------|
| Release 1.0.0  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; |
| Release 1.1.0  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; |
| Release 1.1.1  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; |
| Release 1.1.2  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; |
| Release 1.1.3  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; |
| Release 1.1.4  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; |
| Release 1.1.5  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; |
| Release 1.1.6  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; |
| Release 1.1.7  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; |
| Release 1.1.8  | &#x2714;  | &#x2714;  | &#x2714; | &#x2714; | &#x2714; | &#x2714; |
| Release 3.0.0  | &#x274C;  | &#x274C;  | &#x274C; | &#x274C; | &#x274C; | &#x2714; | &#x2714; | &#x2714; |
| Release 3.1.0  | &#x274C;  | &#x274C;  | &#x274C; | &#x274C; | &#x274C; | &#x2714; | &#x2714; | &#x2714; |
| Release 3.1.3  | &#x274C;  | &#x274C;  | &#x274C; | &#x274C; | &#x274C; | &#x2714; | &#x2714; | &#x2714; |
| Release 4.0.0  | &#x274C;  | &#x274C;  | &#x274C; | &#x274C; | &#x274C; | &#x2714; | &#x2714; | &#x2714; |
| Release 4.0.1  | &#x274C;  | &#x274C;  | &#x274C; | &#x274C; | &#x274C; | &#x2714; | &#x2714; | &#x2714; |
| Release 4.0.2  | &#x274C;  | &#x274C;  | &#x274C; | &#x274C; | &#x274C; | &#x2714; | &#x2714; | &#x2714; |

Note: The latest release 4.0.0 support EKS version 1.28, 1.29 and 1.30. For EKS version <=1.27 refer the previous release.
## IAM Permissions
The required IAM permissions to create resources from this module can be found [here](https://github.com/squareops/terraform-aws-eks-addons.git/blob/main/IAM.md)

## Addons Details
Kubernetes addons are additional components that can be installed in a Kubernetes cluster to provide extra features and functionality. They are designed to work seamlessly with the Kubernetes API and can be managed just like any other Kubernetes resource. Some common examples of Kubernetes addons include:

<details>
  <summary> AWS ALB </summary>
Amazon Web Services (AWS) Application Load Balancer (ALB) is a highly available and scalable load balancing service that routes incoming application traffic to multiple Amazon EC2 instances, containers, and IP addresses. It automatically distributes incoming application traffic across multiple targets, ensuring that your applications are highly available and scalable.

With AWS ALB, you can handle increased traffic levels, automatically scale your applications, and improve the overall performance of your applications. ALB provides advanced routing capabilities, including content-based routing, host-based routing, and path-based routing, enabling you to route traffic to different target groups based on specific rules.
</details>
<details>
  <summary> Node Termination Handler </summary>
In AWS, the Node termination handler can be used in Lambda functions or EC2 instances to handle the termination of the underlying instance or container. When an instance or container is terminated, the termination handler can be used to perform any necessary cleanup operations, such as closing open resources, before the instance or container is terminated.
In an EC2 instance, the termination handler can be set by writing a script that runs on instance startup and sets the process.on('SIGTERM', callback) method. This script can be executed using a user data script or by adding it to the instance's startup script.
</details>
<details>
  <summary> EBS </summary>
Amazon Elastic Block Store (Amazon EBS) storage classes are different levels of performance and cost for Amazon EBS volumes. The storage classes determine the type of storage, performance characteristics, and cost of each Amazon EBS volume.

There are currently four Amazon EBS storage classes:

    Standard storage class: This is the default and most widely used storage class, offering a balance of low cost and high performance. It's suitable for a wide range of applications, including boot volumes, transactional databases, and big data workloads.

    Provisioned IOPS (input/output operations per second) storage class: This class provides high-performance I/O for mission-critical and I/O-intensive workloads, such as large databases and I/O-bound applications.

    Cold storage class: This class provides low-cost storage for infrequently accessed data, such as backups and archives. Cold storage is designed to deliver low cost and high durability.

    Throughput Optimized HDD (hard disk drive) storage class: This class provides low-cost storage optimized for large, sequential workloads, such as big data and data warehouses.
</details>
<details>
  <summary> Cert Manager </summary>
  Cert Manager is a Kubernetes add-on that automates the management and issuance of TLS certificates from various issuing sources. It helps to eliminate manual steps in the certificate management process, provides cert renewals and integrates with other parts of the system.
</details>
<details>
  <summary> Cluster Autoscalar </summary>
Cluster Autoscaler is a Kubernetes component that automatically adjusts the number of nodes in a cluster based on the demand for resources. This allows you to optimize the cost of running your workloads while ensuring that they have the resources they need to run effectively.
The Cluster Autoscaler works by monitoring the resource usage of your pods and comparing it to the available capacity on the nodes in the cluster. If there are pods that cannot be scheduled because of resource constraints, the Cluster Autoscaler will increase the number of nodes in the cluster until there is enough capacity to schedule the pending pods. Similarly, if there are nodes in the cluster that are underutilized, the Cluster Autoscaler can decrease the number of nodes to optimize resource utilization and reduce costs.
Cluster Autoscaler is supported by many cloud providers, including Amazon Web Services (AWS), Google Cloud Platform (GCP), and Microsoft Azure. It can be easily integrated into your existing Kubernetes deployment and can be configured to use different scaling policies to meet the needs of your specific workloads.
</details>
<details>
  <summary> EFS </summary>
Amazon Elastic File System (Amazon EFS) is a fully managed, scalable, and highly available file storage service for use with Amazon Elastic Compute Cloud (Amazon EC2) instances. It provides a simple and scalable file storage solution that can be used by multiple EC2 instances at the same time, making it ideal for use cases such as big data, content management, and media sharing.

Amazon EFS is easy to set up, manage, and scale, and it automatically replicates data across multiple Availability Zones for high durability and availability. The service is also highly performant, with low latency and high throughput, making it suitable for a wide range of workloads.
</details>
<details>
  <summary> External Secrets </summary>
Kubernetes External Secrets is a feature in Kubernetes that allows secrets to be stored and managed outside of the cluster. External secrets are useful in scenarios where sensitive information, such as passwords or API keys, should not be stored directly in the cluster, but still needs to be used by applications running in the cluster.
Kubernetes External Secrets can be stored in external systems such as Hashicorp Vault, AWS Secrets Manager, or GCP Secret Manager, and accessed by pods using a Kubernetes Secret object. The Secret object references the external secret and maps it to a Kubernetes Secret, which can then be used by pods in the same way as regular Kubernetes Secrets.
By using External Secrets, organizations can ensure that sensitive information is securely managed and stored outside of the cluster, while still being able to use that information in their applications running in the cluster.
</details>
<details>
  <summary> Karpenter </summary>
Karpenter is a flexible, high-performance Kubernetes cluster autoscaler that helps improve application availability and cluster efficiency. Karpenter launches right-sized compute resources, (for example, Amazon EC2 instances), in response to changing application load in under a minute. Through integrating Kubernetes with AWS, Karpenter can provision just-in-time compute resources that precisely meet the requirements of your workload. Karpenter automatically provisions new compute resources based on the specific requirements of cluster workloads. These include compute, storage, acceleration, and scheduling requirements. Amazon EKS supports clusters using Karpenter, although Karpenter works with any conformant Kubernetes cluster.
</details>
<details>
  <summary> Metrics Server </summary>
Metric Server is a Kubernetes add-on that collects resource usage data from the Kubernetes API server and makes it available to other components, such as the Horizontal Pod Autoscaler (HPA) and the Cluster Autoscaler.
The Metric Server collects data on the CPU and memory usage of pods and nodes in a cluster, and provides this data to other components in a format that they can use to make scaling decisions. The HPA, for example, can use the data provided by the Metric Server to automatically scale the number of replicas of a deployment based on the resource usage of the pods. The Cluster Autoscaler can also use this data to determine when to add or remove nodes from a cluster based on the resource utilization of the pods and nodes.
Metric Server provides a simple and effective way to collect resource usage data from a cluster and make it available to other components for scaling and resource optimization. It is an important component for ensuring that your Kubernetes applications run effectively and efficiently in the cloud.
</details>
<details>
  <summary> Nginx Ingress Controller </summary>
Nginx Ingress Controller is a Kubernetes controller that manages external access to services running in a Kubernetes cluster. It provides load balancing, SSL termination, and name-based virtual hosting, among other features.
The Nginx Ingress Controller works by using the Kubernetes API to dynamically configure an Nginx instance running outside of the cluster to route traffic to services within the cluster. This allows you to easily expose your services to external users and manage the routing of incoming traffic.
The Nginx Ingress Controller provides a flexible and powerful way to manage incoming traffic to your Kubernetes applications. It is widely used in production environments and is well-suited for both simple and complex routing scenarios. Additionally, the Nginx Ingress Controller integrates with other Kubernetes components, such as the Kubernetes Ingress resource and cert-manager, to provide a complete solution for managing external access to your services.
</details>
<details>
  <summary> Reloader </summary>
Reloader can watch changes in ConfigMap and Secret and do rolling upgrades on Pods with their associated DeploymentConfigs, Deployments, Daemonsets, Statefulsets and Rollouts.
</details>
<details>
  <summary> Velero </summary>
Velero (previously known as Heptio Ark) is an open-source backup and disaster recovery solution for Kubernetes. Velero provides the ability to back up and restore Kubernetes cluster resources and persistent volumes, making it easy to recover from data loss or cluster failures.
Some key features of Velero include:
Cluster Backup and Restore: Velero allows users to create backups of their Kubernetes clusters and restore them to the same or different cluster.
Persistent Volume Backup and Restore: Velero provides the ability to backup and restore persistent volumes, ensuring that data can be recovered even if the cluster fails.
Incremental Backups: Velero supports incremental backups, which can be performed more frequently than full backups and reduce the amount of data transferred.
Snapshot Integration: Velero integrates with cloud provider snapshot services, such as AWS EBS and GCE PD, to simplify the backup process and reduce the cost of storing backup data.
Easy to Use CLI: Velero provides a user-friendly CLI that makes it easy to create, manage, and restore backups.
Velero is designed to work with cloud native environments, making it a popular choice for organizations that run their applications in the cloud. By using Velero, organizations can improve the reliability and availability of their applications and ensure that they can recover from data loss or cluster failures.
</details>
<details>
  <summary> KubeClarity </summary>
  KubeClarity helps you to secure your cloud-native applications and infrastructure by offering features such as automated threat detection, policy enforcement, compliance reporting, and continuous monitoring. It allows you to enforce security policies across all your Kubernetes environments and provides automated remediation of security issues, ensuring that your deployments are always secure and compliant.
</details>
<details>
  <summary> Kubecost </summary>
  Kubecost provides real-time cost visibility and insights for teams using Kubernetes, helping you continuously reduce your cloud costs. Breakdown costs by any Kubernetes concepts, including deployment, service, namespace label, and more.
</details>
<details>
  <summary>DefectDojo</summary>
   DefectDojo is an open-source application vulnerability management tool. It is designed to automate and streamline the process of managing application security testing efforts, including dynamic testing, static analysis, and manual penetration testing.
</details>
<details>
  <summary> Falcon </summary>
  Falcon helps network administrators monitor malicious activities, apply mitigation techniques and block data tampering across multiple devices.
  Key feature:

  Endpoint Protection: Safeguards devices from malware, ransomware, and malicious activities.

  Cloud-Native Architecture: Built for easy scalability with real-time threat detection in the cloud.

  Behavioral Analysis: Identifies threats through behavioral analysis, not just known signatures.

  Threat Intelligence: Integrates real-time threat intelligence feeds for up-to-date risk mitigation.

  Incident Response: Enables swift investigation and remediation of security incidents.

</details>

## Notes

1. Before enabling the **Kubecost** addon for your Amazon EKS cluster, please make sure to subscribe to the **Kubecost - Amazon EKS cost monitoring** license.
2. For Destroying resources created by terraform-aws-eks-addons module, run script present in **examples/complete/terraform.destroy.sh**.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.23 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.13 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.23 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.6 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.13 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argo-project"></a> [argo-project](#module\_argo-project) | ./modules/argocd-projects | n/a |
| <a name="module_argo-rollout"></a> [argo-rollout](#module\_argo-rollout) | ./modules/argo-rollout | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./modules/argocd | n/a |
| <a name="module_argocd-workflow"></a> [argocd-workflow](#module\_argocd-workflow) | ./modules/argocd-workflow | n/a |
| <a name="module_aws-ebs-csi-driver"></a> [aws-ebs-csi-driver](#module\_aws-ebs-csi-driver) | ./modules/aws-ebs-csi-driver | n/a |
| <a name="module_aws-efs-csi-driver"></a> [aws-efs-csi-driver](#module\_aws-efs-csi-driver) | ./modules/aws-efs-csi-driver | n/a |
| <a name="module_aws-efs-filesystem-with-storage-class"></a> [aws-efs-filesystem-with-storage-class](#module\_aws-efs-filesystem-with-storage-class) | ./modules/aws-efs-filesystem-with-storage-class | n/a |
| <a name="module_aws-load-balancer-controller"></a> [aws-load-balancer-controller](#module\_aws-load-balancer-controller) | ./modules/aws-load-balancer-controller | n/a |
| <a name="module_aws-node-termination-handler"></a> [aws-node-termination-handler](#module\_aws-node-termination-handler) | ./modules/aws-node-termination-handler | n/a |
| <a name="module_aws_vpc_cni"></a> [aws\_vpc\_cni](#module\_aws\_vpc\_cni) | ./modules/aws-vpc-cni | n/a |
| <a name="module_cert-manager"></a> [cert-manager](#module\_cert-manager) | ./modules/cert-manager | n/a |
| <a name="module_cert-manager-le-http-issuer"></a> [cert-manager-le-http-issuer](#module\_cert-manager-le-http-issuer) | ./modules/cert-manager-le-http-issuer | n/a |
| <a name="module_cluster-autoscaler"></a> [cluster-autoscaler](#module\_cluster-autoscaler) | ./modules/cluster-autoscaler | n/a |
| <a name="module_cluster-proportional-autoscaler"></a> [cluster-proportional-autoscaler](#module\_cluster-proportional-autoscaler) | ./modules/cluster-proportional-autoscaler | n/a |
| <a name="module_coredns_hpa"></a> [coredns\_hpa](#module\_coredns\_hpa) | ./modules/core-dns-hpa | n/a |
| <a name="module_external-secrets"></a> [external-secrets](#module\_external-secrets) | ./modules/external-secret | n/a |
| <a name="module_ingress-nginx"></a> [ingress-nginx](#module\_ingress-nginx) | ./modules/ingress-nginx | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | ./modules/karpenter | n/a |
| <a name="module_keda"></a> [keda](#module\_keda) | ./modules/keda | n/a |
| <a name="module_kubernetes-dashboard"></a> [kubernetes-dashboard](#module\_kubernetes-dashboard) | ./modules/kubernetes-dashboard | n/a |
| <a name="module_metrics-server"></a> [metrics-server](#module\_metrics-server) | ./modules/metrics-server | n/a |
| <a name="module_metrics-server-vpa"></a> [metrics-server-vpa](#module\_metrics-server-vpa) | ./modules/metrics-server-vpa | n/a |
| <a name="module_private-ingress-nginx"></a> [private-ingress-nginx](#module\_private-ingress-nginx) | ./modules/ingress-nginx | n/a |
| <a name="module_reloader"></a> [reloader](#module\_reloader) | ./modules/reloader | n/a |
| <a name="module_service-monitor-crd"></a> [service-monitor-crd](#module\_service-monitor-crd) | ./modules/service-monitor-crd | n/a |
| <a name="module_single-az-sc"></a> [single-az-sc](#module\_single-az-sc) | ./modules/aws-ebs-storage-class | n/a |
| <a name="module_velero"></a> [velero](#module\_velero) | ./modules/velero | n/a |
| <a name="module_vpa-crds"></a> [vpa-crds](#module\_vpa-crds) | ./modules/vpa-crds | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.kubecost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [helm_release.defectdojo](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.falco](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kubeclarity](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_ingress_v1.kubecost](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.defectdojo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.falco](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.kube-clarity](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.kube-clarity](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.kubecost](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.kube-clarity](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.kubecost](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_sleep.dataplane](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_addon_version.kubecost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubernetes_secret.defectdojo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |
| [kubernetes_service.ingress-nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |
| [kubernetes_service.private-ingress-nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_acm_certificate_arn"></a> [alb\_acm\_certificate\_arn](#input\_alb\_acm\_certificate\_arn) | ARN of the ACM certificate to be used for ALB Ingress. | `string` | `""` | no |
| <a name="input_amazon_eks_aws_ebs_csi_driver_config"></a> [amazon\_eks\_aws\_ebs\_csi\_driver\_config](#input\_amazon\_eks\_aws\_ebs\_csi\_driver\_config) | configMap for AWS EBS CSI Driver add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_vpc_cni_enabled"></a> [amazon\_eks\_vpc\_cni\_enabled](#input\_amazon\_eks\_vpc\_cni\_enabled) | Enable or disable the installation of the Amazon EKS VPC CNI addon. | `bool` | `false` | no |
| <a name="input_argocd_config"></a> [argocd\_config](#input\_argocd\_config) | n/a | <pre>object({<br/>    hostname                     = string<br/>    values_yaml                  = any<br/>    redis_ha_enabled             = bool<br/>    autoscaling_enabled          = bool<br/>    slack_notification_token     = string<br/>    argocd_notifications_enabled = bool<br/>    expose_dashboard             = bool<br/>    ingress_class_name           = string<br/>    namespace                    = string<br/>    argocd_ingress_load_balancer = string<br/>    private_alb_enabled          = bool<br/>    alb_acm_certificate_arn      = string<br/>  })</pre> | <pre>{<br/>  "alb_acm_certificate_arn": "",<br/>  "argocd_ingress_load_balancer": "nlb",<br/>  "argocd_notifications_enabled": false,<br/>  "autoscaling_enabled": false,<br/>  "expose_dashboard": true,<br/>  "hostname": "",<br/>  "ingress_class_name": "",<br/>  "namespace": "argocd",<br/>  "private_alb_enabled": false,<br/>  "redis_ha_enabled": false,<br/>  "slack_notification_token": "",<br/>  "values_yaml": {}<br/>}</pre> | no |
| <a name="input_argocd_enabled"></a> [argocd\_enabled](#input\_argocd\_enabled) | Determine whether argocd is enabled or not | `bool` | `false` | no |
| <a name="input_argocd_manage_add_ons"></a> [argocd\_manage\_add\_ons](#input\_argocd\_manage\_add\_ons) | Enable managing add-on configuration via ArgoCD App of Apps | `bool` | `false` | no |
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of the argocd addon | `string` | `"7.3.11"` | no |
| <a name="input_argoproject_config"></a> [argoproject\_config](#input\_argoproject\_config) | n/a | <pre>object({<br/>    name = string<br/>  })</pre> | <pre>{<br/>  "name": ""<br/>}</pre> | no |
| <a name="input_argorollout_config"></a> [argorollout\_config](#input\_argorollout\_config) | n/a | <pre>object({<br/>    values                            = any<br/>    namespace                         = string<br/>    hostname                          = string<br/>    ingress_class_name                = string<br/>    enable_dashboard                  = bool<br/>    argorollout_ingress_load_balancer = string<br/>    private_alb_enabled               = bool<br/>    alb_acm_certificate_arn           = string<br/>    chart_version                     = string<br/>  })</pre> | <pre>{<br/>  "alb_acm_certificate_arn": "",<br/>  "argorollout_ingress_load_balancer": "nlb",<br/>  "chart_version": "2.38.0",<br/>  "enable_dashboard": false,<br/>  "hostname": "",<br/>  "ingress_class_name": "",<br/>  "namespace": "argocd",<br/>  "private_alb_enabled": false,<br/>  "values": {}<br/>}</pre> | no |
| <a name="input_argorollout_enabled"></a> [argorollout\_enabled](#input\_argorollout\_enabled) | Determine whether argo-rollout is enabled or not | `bool` | `false` | no |
| <a name="input_argoworkflow_config"></a> [argoworkflow\_config](#input\_argoworkflow\_config) | n/a | <pre>object({<br/>    values                             = any<br/>    namespace                          = string<br/>    hostname                           = string<br/>    expose_dashboard                   = bool<br/>    ingress_class_name                 = string<br/>    autoscaling_enabled                = bool<br/>    argoworkflow_ingress_load_balancer = string<br/>    private_alb_enabled                = bool<br/>    alb_acm_certificate_arn            = string<br/>  })</pre> | <pre>{<br/>  "alb_acm_certificate_arn": "",<br/>  "argoworkflow_ingress_load_balancer": "nlb",<br/>  "autoscaling_enabled": true,<br/>  "expose_dashboard": true,<br/>  "hostname": "",<br/>  "ingress_class_name": "",<br/>  "namespace": "argocd",<br/>  "private_alb_enabled": false,<br/>  "values": {}<br/>}</pre> | no |
| <a name="input_argoworkflow_enabled"></a> [argoworkflow\_enabled](#input\_argoworkflow\_enabled) | Determine whether argocd-workflow is enabled or not | `bool` | `false` | no |
| <a name="input_argoworkflow_version"></a> [argoworkflow\_version](#input\_argoworkflow\_version) | Version of the argoworkflow addon | `string` | `"0.29.2"` | no |
| <a name="input_auto_scaling_group_names"></a> [auto\_scaling\_group\_names](#input\_auto\_scaling\_group\_names) | List of self-managed node groups autoscaling group names | `list(string)` | `[]` | no |
| <a name="input_aws_efs_csi_driver_helm_config"></a> [aws\_efs\_csi\_driver\_helm\_config](#input\_aws\_efs\_csi\_driver\_helm\_config) | AWS EFS CSI driver Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_load_balancer_controller_enabled"></a> [aws\_load\_balancer\_controller\_enabled](#input\_aws\_load\_balancer\_controller\_enabled) | Enable or disable AWS Load Balancer Controller add-on for managing and controlling load balancers in Kubernetes. | `bool` | `false` | no |
| <a name="input_aws_load_balancer_controller_helm_config"></a> [aws\_load\_balancer\_controller\_helm\_config](#input\_aws\_load\_balancer\_controller\_helm\_config) | Configuration for the AWS Load Balancer Controller Helm release | <pre>object({<br/>    values                        = any<br/>    namespace                     = string<br/>    load_balancer_controller_name = string<br/>  })</pre> | <pre>{<br/>  "load_balancer_controller_name": "",<br/>  "namespace": "",<br/>  "values": []<br/>}</pre> | no |
| <a name="input_aws_load_balancer_controller_version"></a> [aws\_load\_balancer\_controller\_version](#input\_aws\_load\_balancer\_controller\_version) | Version of the aws load balancer controller addon | `string` | `"1.8.1"` | no |
| <a name="input_aws_node_termination_handler_enabled"></a> [aws\_node\_termination\_handler\_enabled](#input\_aws\_node\_termination\_handler\_enabled) | Enable or disable node termination handler | `bool` | `false` | no |
| <a name="input_aws_node_termination_handler_helm_config"></a> [aws\_node\_termination\_handler\_helm\_config](#input\_aws\_node\_termination\_handler\_helm\_config) | AWS Node Termination Handler Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_node_termination_handler_irsa_policies"></a> [aws\_node\_termination\_handler\_irsa\_policies](#input\_aws\_node\_termination\_handler\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_aws_node_termination_handler_version"></a> [aws\_node\_termination\_handler\_version](#input\_aws\_node\_termination\_handler\_version) | Version of the aws node termination handler addon | `string` | `"0.21.0"` | no |
| <a name="input_cert_manager_domain_names"></a> [cert\_manager\_domain\_names](#input\_cert\_manager\_domain\_names) | Domain names of the Route53 hosted zone to use with cert-manager | `list(string)` | `[]` | no |
| <a name="input_cert_manager_enabled"></a> [cert\_manager\_enabled](#input\_cert\_manager\_enabled) | Enable or disable the cert manager add-on for EKS cluster. | `bool` | `false` | no |
| <a name="input_cert_manager_helm_config"></a> [cert\_manager\_helm\_config](#input\_cert\_manager\_helm\_config) | Cert Manager Helm Chart config | `any` | `{}` | no |
| <a name="input_cert_manager_install_letsencrypt_r53_issuers"></a> [cert\_manager\_install\_letsencrypt\_r53\_issuers](#input\_cert\_manager\_install\_letsencrypt\_r53\_issuers) | Enable or disable the creation of Route53 issuer while installing cert manager. | `bool` | `false` | no |
| <a name="input_cert_manager_irsa_policies"></a> [cert\_manager\_irsa\_policies](#input\_cert\_manager\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_cert_manager_kubernetes_svc_image_pull_secrets"></a> [cert\_manager\_kubernetes\_svc\_image\_pull\_secrets](#input\_cert\_manager\_kubernetes\_svc\_image\_pull\_secrets) | list(string) of kubernetes imagePullSecrets | `list(string)` | `[]` | no |
| <a name="input_cert_manager_letsencrypt_email"></a> [cert\_manager\_letsencrypt\_email](#input\_cert\_manager\_letsencrypt\_email) | Specifies the email address to be used by cert-manager to request Let's Encrypt certificates | `string` | `""` | no |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Version of the cert manager addon | `string` | `"v1.15.1"` | no |
| <a name="input_cluster_autoscaler_enabled"></a> [cluster\_autoscaler\_enabled](#input\_cluster\_autoscaler\_enabled) | Whether to enable the Cluster Autoscaler add-on or not. | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_helm_config"></a> [cluster\_autoscaler\_helm\_config](#input\_cluster\_autoscaler\_helm\_config) | CoreDNS Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_version"></a> [cluster\_autoscaler\_version](#input\_cluster\_autoscaler\_version) | Version of the cluster autoscaler addon | `string` | `"9.46.6"` | no |
| <a name="input_cluster_issuer"></a> [cluster\_issuer](#input\_cluster\_issuer) | Specify the letsecrypt cluster-issuer for ingress tls. | `string` | `"letsencrypt-prod"` | no |
| <a name="input_cluster_proportional_autoscaler_chart_version"></a> [cluster\_proportional\_autoscaler\_chart\_version](#input\_cluster\_proportional\_autoscaler\_chart\_version) | Version of the cluster proportional autoscaler helm chart | `string` | `"1.1.0"` | no |
| <a name="input_cluster_proportional_autoscaler_enabled"></a> [cluster\_proportional\_autoscaler\_enabled](#input\_cluster\_proportional\_autoscaler\_enabled) | Whether to enable the Cluster proportional Autoscaler add-on or not. | `bool` | `false` | no |
| <a name="input_cluster_proportional_autoscaler_helm_config"></a> [cluster\_proportional\_autoscaler\_helm\_config](#input\_cluster\_proportional\_autoscaler\_helm\_config) | Configuration options for the Cluster Proportional Autoscaler Helm chart. | `any` | `{}` | no |
| <a name="input_coredns_hpa_enabled"></a> [coredns\_hpa\_enabled](#input\_coredns\_hpa\_enabled) | Determines whether Horizontal Pod Autoscaling (HPA) for CoreDNS is enabled. | `bool` | `false` | no |
| <a name="input_coredns_hpa_helm_config"></a> [coredns\_hpa\_helm\_config](#input\_coredns\_hpa\_helm\_config) | CoreDNS Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_custom_image_registry_uri"></a> [custom\_image\_registry\_uri](#input\_custom\_image\_registry\_uri) | Custom image registry URI map of `{region = dkr.endpoint }` | `map(string)` | `{}` | no |
| <a name="input_data_plane_wait_arn"></a> [data\_plane\_wait\_arn](#input\_data\_plane\_wait\_arn) | Addon deployment will not proceed until this value is known. Set to node group/Fargate profile ARN to wait for data plane to be ready before provisioning addons | `string` | `""` | no |
| <a name="input_defectdojo_enabled"></a> [defectdojo\_enabled](#input\_defectdojo\_enabled) | Enable defectdojo for service mesh. | `bool` | `false` | no |
| <a name="input_defectdojo_hostname"></a> [defectdojo\_hostname](#input\_defectdojo\_hostname) | Specify the hostname for the kubecsot. | `string` | `""` | no |
| <a name="input_ebs_csi_driver_version"></a> [ebs\_csi\_driver\_version](#input\_ebs\_csi\_driver\_version) | Version of the ebs csi driver addon | `string` | `"v1.41.0-eksbuild.1"` | no |
| <a name="input_efs_storage_class_enabled"></a> [efs\_storage\_class\_enabled](#input\_efs\_storage\_class\_enabled) | Enable or disable the Amazon Elastic File System (EFS) add-on for EKS cluster. | `bool` | `false` | no |
| <a name="input_efs_version"></a> [efs\_version](#input\_efs\_version) | Version of the efs addon | `string` | `"3.1.8"` | no |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | Endpoint for your Kubernetes API server | `string` | `null` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Fetch Cluster ID of the cluster | `string` | `""` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | The Kubernetes version for the cluster | `string` | `null` | no |
| <a name="input_eks_oidc_provider"></a> [eks\_oidc\_provider](#input\_eks\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading `https://`) | `string` | `null` | no |
| <a name="input_enable_amazon_eks_aws_ebs_csi_driver"></a> [enable\_amazon\_eks\_aws\_ebs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_ebs\_csi\_driver) | Enable EKS Managed AWS EBS CSI Driver add-on; enable\_amazon\_eks\_aws\_ebs\_csi\_driver and enable\_self\_managed\_aws\_ebs\_csi\_driver are mutually exclusive | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Enable Ipv6 network. Attaches new VPC CNI policy to the IRSA role | `bool` | `false` | no |
| <a name="input_enable_self_managed_aws_ebs_csi_driver"></a> [enable\_self\_managed\_aws\_ebs\_csi\_driver](#input\_enable\_self\_managed\_aws\_ebs\_csi\_driver) | Enable self-managed aws-ebs-csi-driver add-on; enable\_self\_managed\_aws\_ebs\_csi\_driver and enable\_amazon\_eks\_aws\_ebs\_csi\_driver are mutually exclusive | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment identifier for the Amazon Elastic Kubernetes Service (EKS) cluster. | `string` | `""` | no |
| <a name="input_external_secrets_enabled"></a> [external\_secrets\_enabled](#input\_external\_secrets\_enabled) | Enable or disable External Secrets operator add-on for managing external secrets. | `bool` | `false` | no |
| <a name="input_external_secrets_helm_config"></a> [external\_secrets\_helm\_config](#input\_external\_secrets\_helm\_config) | External Secrets operator Helm Chart config | `any` | `{}` | no |
| <a name="input_external_secrets_irsa_policies"></a> [external\_secrets\_irsa\_policies](#input\_external\_secrets\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_external_secrets_secrets_manager_arns"></a> [external\_secrets\_secrets\_manager\_arns](#input\_external\_secrets\_secrets\_manager\_arns) | List of Secrets Manager ARNs that contain secrets to mount using External Secrets | `list(string)` | <pre>[<br/>  "arn:aws:secretsmanager:*:*:secret:*"<br/>]</pre> | no |
| <a name="input_external_secrets_ssm_parameter_arns"></a> [external\_secrets\_ssm\_parameter\_arns](#input\_external\_secrets\_ssm\_parameter\_arns) | List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets | `list(string)` | <pre>[<br/>  "arn:aws:ssm:*:*:parameter/*"<br/>]</pre> | no |
| <a name="input_external_secrets_version"></a> [external\_secrets\_version](#input\_external\_secrets\_version) | Version of the external secrets addon | `string` | `"0.15.1"` | no |
| <a name="input_falco_enabled"></a> [falco\_enabled](#input\_falco\_enabled) | Determines whether Falco is enabled. | `bool` | `false` | no |
| <a name="input_falco_version"></a> [falco\_version](#input\_falco\_version) | Version of the falco addon | `string` | `"4.0.0"` | no |
| <a name="input_ingress_nginx_config"></a> [ingress\_nginx\_config](#input\_ingress\_nginx\_config) | Configure ingress-nginx to setup addons | <pre>object({<br/>    ingress_class_name     = string<br/>    enable_service_monitor = bool<br/>    values                 = any<br/>    namespace              = string<br/>  })</pre> | <pre>{<br/>  "enable_service_monitor": false,<br/>  "ingress_class_name": "ingress-nginx",<br/>  "namespace": "ingress-nginx",<br/>  "values": {}<br/>}</pre> | no |
| <a name="input_ingress_nginx_enabled"></a> [ingress\_nginx\_enabled](#input\_ingress\_nginx\_enabled) | Control wheather to install public nlb or private nlb. Default is private | `bool` | `false` | no |
| <a name="input_ingress_nginx_version"></a> [ingress\_nginx\_version](#input\_ingress\_nginx\_version) | Version of the ingress nginx addon | `string` | `"4.11.0"` | no |
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | whether IPv6 enabled or not | `bool` | `false` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_k8s_dashboard_hostname"></a> [k8s\_dashboard\_hostname](#input\_k8s\_dashboard\_hostname) | Specify the hostname for the k8s dashboard. | `string` | `""` | no |
| <a name="input_k8s_dashboard_ingress_load_balancer"></a> [k8s\_dashboard\_ingress\_load\_balancer](#input\_k8s\_dashboard\_ingress\_load\_balancer) | Controls whether to enable ALB Ingress or not. | `string` | `"nlb"` | no |
| <a name="input_karpenter_enabled"></a> [karpenter\_enabled](#input\_karpenter\_enabled) | Enable or disable Karpenter, a Kubernetes-native, multi-tenant, and auto-scaling solution for containerized workloads on Kubernetes. | `bool` | `false` | no |
| <a name="input_karpenter_helm_config"></a> [karpenter\_helm\_config](#input\_karpenter\_helm\_config) | Karpenter autoscaler add-on config | `any` | `{}` | no |
| <a name="input_karpenter_irsa_policies"></a> [karpenter\_irsa\_policies](#input\_karpenter\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_karpenter_node_iam_instance_profile"></a> [karpenter\_node\_iam\_instance\_profile](#input\_karpenter\_node\_iam\_instance\_profile) | Karpenter Node IAM Instance profile id | `string` | `""` | no |
| <a name="input_karpenter_version"></a> [karpenter\_version](#input\_karpenter\_version) | Version of the karpenter addon | `string` | `"1.3.3"` | no |
| <a name="input_keda_enabled"></a> [keda\_enabled](#input\_keda\_enabled) | Enable or disable Kubernetes Event-driven Autoscaling (KEDA) add-on for autoscaling workloads. | `bool` | `false` | no |
| <a name="input_keda_helm_config"></a> [keda\_helm\_config](#input\_keda\_helm\_config) | KEDA Event-based autoscaler add-on config | `any` | `{}` | no |
| <a name="input_keda_irsa_policies"></a> [keda\_irsa\_policies](#input\_keda\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_keda_version"></a> [keda\_version](#input\_keda\_version) | Version of the keda addon | `string` | `"2.17.0"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used to encrypt AWS resources in the EKS cluster. | `string` | `""` | no |
| <a name="input_kms_policy_arn"></a> [kms\_policy\_arn](#input\_kms\_policy\_arn) | Specify the ARN of KMS policy, for service accounts. | `string` | `""` | no |
| <a name="input_kubeclarity_enabled"></a> [kubeclarity\_enabled](#input\_kubeclarity\_enabled) | Enable or disable the deployment of an kubeclarity for Kubernetes. | `bool` | `false` | no |
| <a name="input_kubeclarity_hostname"></a> [kubeclarity\_hostname](#input\_kubeclarity\_hostname) | Specify the hostname for the Kubeclarity. | `string` | `""` | no |
| <a name="input_kubeclarity_namespace"></a> [kubeclarity\_namespace](#input\_kubeclarity\_namespace) | Name of the Kubernetes namespace where the kubeclarity deployment will be deployed. | `string` | `"kubeclarity"` | no |
| <a name="input_kubeclarity_version"></a> [kubeclarity\_version](#input\_kubeclarity\_version) | Version of the kubeclarity addon | `string` | `"2.23.0"` | no |
| <a name="input_kubecost_enabled"></a> [kubecost\_enabled](#input\_kubecost\_enabled) | Enable or disable the deployment of an Kubecost for Kubernetes. | `bool` | `false` | no |
| <a name="input_kubecost_hostname"></a> [kubecost\_hostname](#input\_kubecost\_hostname) | Specify the hostname for the kubecsot. | `string` | `""` | no |
| <a name="input_kubecost_version"></a> [kubecost\_version](#input\_kubecost\_version) | Version of the kubecost addon | `string` | `"v2.1.0-eksbuild.1"` | no |
| <a name="input_kubernetes_dashboard_config"></a> [kubernetes\_dashboard\_config](#input\_kubernetes\_dashboard\_config) | Specify all the configuration setup here | <pre>object({<br/>    k8s_dashboard_hostname              = string<br/>    values_yaml                         = any<br/>    enable_service_monitor              = bool<br/>    k8s_dashboard_ingress_load_balancer = string<br/>    alb_acm_certificate_arn             = string<br/>    private_alb_enabled                 = bool<br/>    ingress_class_name                  = string<br/>  })</pre> | <pre>{<br/>  "alb_acm_certificate_arn": "",<br/>  "enable_service_monitor": false,<br/>  "ingress_class_name": "",<br/>  "k8s_dashboard_hostname": "",<br/>  "k8s_dashboard_ingress_load_balancer": "",<br/>  "private_alb_enabled": false,<br/>  "values_yaml": {}<br/>}</pre> | no |
| <a name="input_kubernetes_dashboard_enabled"></a> [kubernetes\_dashboard\_enabled](#input\_kubernetes\_dashboard\_enabled) | Determines whether k8s-dashboard is enabled or not | `bool` | `false` | no |
| <a name="input_kubernetes_dashboard_version"></a> [kubernetes\_dashboard\_version](#input\_kubernetes\_dashboard\_version) | Version of the kubernetes dashboard addon | `string` | `"6.0.8"` | no |
| <a name="input_metrics_server_enabled"></a> [metrics\_server\_enabled](#input\_metrics\_server\_enabled) | Enable or disable the metrics server add-on for EKS cluster. | `bool` | `false` | no |
| <a name="input_metrics_server_helm_config"></a> [metrics\_server\_helm\_config](#input\_metrics\_server\_helm\_config) | Metrics Server Helm Chart config | `any` | `{}` | no |
| <a name="input_metrics_server_helm_version"></a> [metrics\_server\_helm\_version](#input\_metrics\_server\_helm\_version) | Version of the metrics server helm chart | `string` | `"3.11.0"` | no |
| <a name="input_metrics_server_version"></a> [metrics\_server\_version](#input\_metrics\_server\_version) | Version of the metrics server addon | `string` | `"3.12.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Specify the name prefix of the EKS cluster resources. | `string` | `""` | no |
| <a name="input_node_termination_handler_version"></a> [node\_termination\_handler\_version](#input\_node\_termination\_handler\_version) | Specify the version of node termination handler | `string` | `"0.21.0"` | no |
| <a name="input_private_ingress_nginx_config"></a> [private\_ingress\_nginx\_config](#input\_private\_ingress\_nginx\_config) | Configure private-ingress-nginx to setup addons | <pre>object({<br/>    ingress_class_name     = string<br/>    enable_service_monitor = bool<br/>    values                 = any<br/>    namespace              = string<br/>  })</pre> | <pre>{<br/>  "enable_service_monitor": false,<br/>  "ingress_class_name": "private-nginx",<br/>  "namespace": "private-nginx",<br/>  "values": {}<br/>}</pre> | no |
| <a name="input_private_ingress_nginx_enabled"></a> [private\_ingress\_nginx\_enabled](#input\_private\_ingress\_nginx\_enabled) | Control wheather to install public nlb or private nlb. Default is private | `bool` | `false` | no |
| <a name="input_private_ingress_nginx_version"></a> [private\_ingress\_nginx\_version](#input\_private\_ingress\_nginx\_version) | Version of the ingress nginx addon | `string` | `"4.11.0"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets of the VPC which can be used by EFS, argocd, workflow and k8s dashboard | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnets of the VPC which can be used by argocd, workflow and k8s dashboard | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_reloader_enabled"></a> [reloader\_enabled](#input\_reloader\_enabled) | Enable or disable Reloader, a Kubernetes controller to watch changes in ConfigMap and Secret objects and trigger an application reload on their changes. | `bool` | `false` | no |
| <a name="input_reloader_helm_config"></a> [reloader\_helm\_config](#input\_reloader\_helm\_config) | Reloader Helm Chart config | `any` | `{}` | no |
| <a name="input_reloader_version"></a> [reloader\_version](#input\_reloader\_version) | Version of the reloader addon | `string` | `"v1.0.115"` | no |
| <a name="input_self_managed_aws_ebs_csi_driver_helm_config"></a> [self\_managed\_aws\_ebs\_csi\_driver\_helm\_config](#input\_self\_managed\_aws\_ebs\_csi\_driver\_helm\_config) | Self-managed aws-ebs-csi-driver Helm chart config | `any` | `{}` | no |
| <a name="input_service_monitor_crd_enabled"></a> [service\_monitor\_crd\_enabled](#input\_service\_monitor\_crd\_enabled) | Enable or disable the installation of Custom Resource Definitions (CRDs) for Prometheus Service Monitor. | `bool` | `false` | no |
| <a name="input_single_az_ebs_gp3_storage_class_enabled"></a> [single\_az\_ebs\_gp3\_storage\_class\_enabled](#input\_single\_az\_ebs\_gp3\_storage\_class\_enabled) | Whether to enable the Single AZ storage class or not. | `bool` | `false` | no |
| <a name="input_single_az_sc_config"></a> [single\_az\_sc\_config](#input\_single\_az\_sc\_config) | Name and regions for storage class in Key-Value pair. | `list(any)` | `[]` | no |
| <a name="input_slack_webhook"></a> [slack\_webhook](#input\_slack\_webhook) | The Slack webhook URL used for notifications. | `string` | `""` | no |
| <a name="input_storage_class_name"></a> [storage\_class\_name](#input\_storage\_class\_name) | Specify the hostname for the kubecsot. | `string` | `"infra-service-sc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_velero_config"></a> [velero\_config](#input\_velero\_config) | Configuration to provide settings for Velero, including which namespaces to backup, retention period, backup schedule, and backup bucket name. | `any` | <pre>{<br/>  "backup_bucket_name": "",<br/>  "namespaces": "",<br/>  "retention_period_in_days": 45,<br/>  "schedule_backup_cron_time": "",<br/>  "slack_appToken": "",<br/>  "slack_botToken": "",<br/>  "slack_notification_channel_name": "",<br/>  "velero_backup_name": ""<br/>}</pre> | no |
| <a name="input_velero_enabled"></a> [velero\_enabled](#input\_velero\_enabled) | Enable or disable the installation of Velero, which is a backup and restore solution for Kubernetes clusters. | `bool` | `false` | no |
| <a name="input_velero_notification_enabled"></a> [velero\_notification\_enabled](#input\_velero\_notification\_enabled) | Enable or disable the notification for velero backup. | `bool` | `false` | no |
| <a name="input_vpa_config"></a> [vpa\_config](#input\_vpa\_config) | Configure VPA CRD to setup addon | <pre>object({<br/>    values = list(string)<br/>  })</pre> | <pre>{<br/>  "values": []<br/>}</pre> | no |
| <a name="input_vpa_enabled"></a> [vpa\_enabled](#input\_vpa\_enabled) | Choose whether to enable vpa or not | `bool` | `false` | no |
| <a name="input_vpa_version"></a> [vpa\_version](#input\_vpa\_version) | Version of VPA CRD | `string` | `"10.0.0"` | no |
| <a name="input_vpc_cni_version"></a> [vpc\_cni\_version](#input\_vpc\_cni\_version) | Specify VPC CNI addons version | `string` | `"v1.19.0-eksbuild.1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster and its nodes will be provisioned | `string` | `""` | no |
| <a name="input_worker_iam_role_arn"></a> [worker\_iam\_role\_arn](#input\_worker\_iam\_role\_arn) | Specify the IAM role Arn for the nodes | `string` | `""` | no |
| <a name="input_worker_iam_role_name"></a> [worker\_iam\_role\_name](#input\_worker\_iam\_role\_name) | Specify the IAM role for the nodes that will be provisioned through karpenter | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_credentials"></a> [argocd\_credentials](#output\_argocd\_credentials) | Argocd\_Info |
| <a name="output_argorollout_credentials"></a> [argorollout\_credentials](#output\_argorollout\_credentials) | Argorollout Details |
| <a name="output_argoworkflow_credentials"></a> [argoworkflow\_credentials](#output\_argoworkflow\_credentials) | Argocd Workflow credentials |
| <a name="output_argoworkflow_hostname"></a> [argoworkflow\_hostname](#output\_argoworkflow\_hostname) | Argocd Workflow hostname |
| <a name="output_defectdojo"></a> [defectdojo](#output\_defectdojo) | DefectDojo endpoint and credentials |
| <a name="output_ebs_encryption_enable"></a> [ebs\_encryption\_enable](#output\_ebs\_encryption\_enable) | Whether Amazon Elastic Block Store (EBS) encryption is enabled or not. |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | ID of the Amazon Elastic File System (EFS) that has been created for the EKS cluster. |
| <a name="output_environment"></a> [environment](#output\_environment) | Environment Name for the EKS cluster |
| <a name="output_internal_nginx_ingress_controller_dns_hostname"></a> [internal\_nginx\_ingress\_controller\_dns\_hostname](#output\_internal\_nginx\_ingress\_controller\_dns\_hostname) | DNS hostname of the NGINX Ingress Controller. |
| <a name="output_k8s_dashboard_admin_token"></a> [k8s\_dashboard\_admin\_token](#output\_k8s\_dashboard\_admin\_token) | Kubernetes-Dashboard Admin Token |
| <a name="output_k8s_dashboard_read_only_token"></a> [k8s\_dashboard\_read\_only\_token](#output\_k8s\_dashboard\_read\_only\_token) | Kubernetes-Dashboard Read Only Token |
| <a name="output_kubeclarity"></a> [kubeclarity](#output\_kubeclarity) | Kubeclarity endpoint and credentials |
| <a name="output_kubecost"></a> [kubecost](#output\_kubecost) | Kubecost endpoint and credentials |
| <a name="output_nginx_ingress_controller_dns_hostname"></a> [nginx\_ingress\_controller\_dns\_hostname](#output\_nginx\_ingress\_controller\_dns\_hostname) | DNS hostname of the NGINX Ingress Controller. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contribution & Issue Reporting

To report an issue with a project:

  1. Check the repository's [issue tracker](https://github.com/squareops/terraform-aws-eks-addons.git/issues) on GitHub
  2. Search to see if the issue has already been reported
  3. If you can't find an answer to your question in the documentation or issue tracker, you can ask a question by creating a new issue. Be sure to provide enough context and details so others can understand your problem.
  4. Contributing to the project can be a great way to get involved and get help. The maintainers and other contributors may be more likely to help you if you're already making contributions to the project.


## License

Apache License, Version 2.0, January 2004 (http://www.apache.org/licenses/).

## Support Us

To support a GitHub project by liking it, you can follow these steps:

  1. Visit the repository: Navigate to the [GitHub repository](https://github.com/squareops/terraform-aws-eks-addons.git).

  2. Click the "Star" button On the repository page, you'll see a "Star" button in the upper right corner. Clicking on it will star the repository, indicating your support for the project.

  3. Optionally, you can also leave a comment on the repository or open an issue to give feedback or suggest changes.

Starring a repository on GitHub is a simple way to show your support and appreciation for the project. It also helps to increase the visibility of the project and make it more discoverable to others.

## Who we are

We believe that the key to success in the digital age is the ability to deliver value quickly and reliably. That’s why we offer a comprehensive range of DevOps & Cloud services designed to help your organization optimize its systems & Processes for speed and agility.

  1. We are an AWS Advanced consulting partner which reflects our deep expertise in AWS Cloud and helping 100+ clients over the last 5 years.
  2. Expertise in Kubernetes and overall container solution helps companies expedite their journey by 10X.
  3. Infrastructure Automation is a key component to the success of our Clients and our Expertise helps deliver the same in the shortest time.
  4. DevSecOps as a service to implement security within the overall DevOps process and helping companies deploy securely and at speed.
  5. Platform engineering which supports scalable,Cost efficient infrastructure that supports rapid development, testing, and deployment.
  6. 24*7 SRE service to help you Monitor the state of your infrastructure and eradicate any issue within the SLA.

We provide [support](https://squareops.com/contact-us/) on all of our projects, no matter how small or large they may be.

You can find more information about our company on this [squareops.com](https://squareops.com/), follow us on [Linkedin](https://www.linkedin.com/company/squareops-technologies-pvt-ltd/), or fill out a [job application](https://squareops.com/careers/). If you have any questions or would like assistance with your cloud strategy and implementation, please don't hesitate to [contact us](https://squareops.com/contact-us/).

<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->
