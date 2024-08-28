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
  name                 = local.name
  tags                 = local.additional_tags
  vpc_id               = "vpc-xxxxxx"                     # pass VPC ID
  private_subnet_ids   = ["subnet-xxxxx", "subnet-xxxxx"] # pass Subnet IDs
  environment          = local.environment
  ipv6_enabled         = local.ipv6_enabled
  kms_key_arn          = local.kms_key_arn
  kms_policy_arn       = "arn:aws:iam::xxx:policy/eks-kms-policy" # eks module will create kms_policy_arn
  worker_iam_role_name = "update-eks-node-role"                   # enter role name created by eks module
  worker_iam_role_arn  = "arn:aws:iam::xxx:role/-eks-node-role"   # enter roll ARN
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
    cert_manager_letsencrypt_email = "email@email.com"
  }

  ## CONFIG-RELOADER
  reloader_enabled = false # to enable config reloader in the EKS cluster
  reloader_helm_config = {
    values                 = [file("${path.module}/config/reloader.yaml")]
    enable_service_monitor = false # to enable monitoring for reloader
  }

  ## INGRESS-NGINX
  ingress_nginx_enabled = false # to enable ingress nginx
  private_nlb_enabled    = false # to enable Internal (Private) Ingress , set this and ingress_nginx_enable "true" together
  ingress_nginx_config = {
    values                 = [file("${path.module}/config/ingress-nginx.yaml")]
    enable_service_monitor = false   # enable monitoring in nginx ingress
    ingress_class_name     = "nginx" # enter ingress class name according to your requirement (example: "nginx", "internal-ingress")
    namespace              = "nginx" # enter namespace according to the requirement (example: "ingress-nginx", "internal-ingress")
  }

  ## AWS-APPLICATION-LOAD-BALANCER-CONTROLLER
  aws_load_balancer_controller_enabled = true # to enable load balancer controller
  aws_load_balancer_controller_helm_config = {
    values = [file("${path.module}/config/aws-alb.yaml")]
  }

  ## KUBERNETES-DASHBOARD
  kubernetes_dashboard_enabled        = false
  k8s_dashboard_ingress_load_balancer = "nlb"                                              ##Choose your load balancer type (e.g., NLB or ALB). Enable load balancer controller, if you require ALB, Enable Ingress Nginx if NLB.
  alb_acm_certificate_arn             = "arn:aws:acm:us-west-2:xxxxx:certificate/xxxxxxxx" # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
  k8s_dashboard_hostname              = "dashboard-test.rnd.squareops.in"                  # Enter Hostname

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

Note: The latest release 3.0.0 support EKS version 1.28, 1.29 and 1.30. For EKS version <=1.27 refer the previous release.
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
  <summary> Karpenter-Provisioner </summary>
Karpernter Provisioner is a powerful provisioning module designed to streamline the deployment process for infrastructure as code (IaC) projects. It provides a set of intuitive and easy-to-use functions to automate the provisioning of resources on various cloud platforms.
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
| <a name="module_aws-ebs-csi-driver"></a> [aws-ebs-csi-driver](#module\_aws-ebs-csi-driver) | ./modules/aws-ebs-csi-driver | n/a |
| <a name="module_aws-efs-csi-driver"></a> [aws-efs-csi-driver](#module\_aws-efs-csi-driver) | ./modules/aws-efs-csi-driver | n/a |
| <a name="module_aws-efs-filesystem-with-storage-class"></a> [aws-efs-filesystem-with-storage-class](#module\_aws-efs-filesystem-with-storage-class) | ./modules/aws-efs-filesystem-with-storage-class | n/a |
| <a name="module_aws-load-balancer-controller"></a> [aws-load-balancer-controller](#module\_aws-load-balancer-controller) | ./modules/aws-load-balancer-controller | n/a |
| <a name="module_aws-node-termination-handler"></a> [aws-node-termination-handler](#module\_aws-node-termination-handler) | ./modules/aws-node-termination-handler | n/a |
| <a name="module_aws_vpc_cni"></a> [aws\_vpc\_cni](#module\_aws\_vpc\_cni) | ./modules/aws-vpc-cni | n/a |
| <a name="module_cert-manager"></a> [cert-manager](#module\_cert-manager) | ./modules/cert-manager | n/a |
| <a name="module_cert-manager-le-http-issuer"></a> [cert-manager-le-http-issuer](#module\_cert-manager-le-http-issuer) | ./modules/cert-manager-le-http-issuer | n/a |
| <a name="module_cluster-autoscaler"></a> [cluster-autoscaler](#module\_cluster-autoscaler) | ./modules/cluster-autoscaler | n/a |
| <a name="module_coredns_hpa"></a> [coredns\_hpa](#module\_coredns\_hpa) | ./modules/core-dns-hpa | n/a |
| <a name="module_external-secrets"></a> [external-secrets](#module\_external-secrets) | ./modules/external-secret | n/a |
| <a name="module_ingress-nginx"></a> [ingress-nginx](#module\_ingress-nginx) | ./modules/ingress-nginx | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | ./modules/karpenter | n/a |
| <a name="module_karpenter-provisioner"></a> [karpenter-provisioner](#module\_karpenter-provisioner) | ./modules/karpenter-provisioner | n/a |
| <a name="module_keda"></a> [keda](#module\_keda) | ./modules/keda | n/a |
| <a name="module_kubernetes-dashboard"></a> [kubernetes-dashboard](#module\_kubernetes-dashboard) | ./modules/kubernetes-dashboard | n/a |
| <a name="module_metrics-server"></a> [metrics-server](#module\_metrics-server) | ./modules/metrics-server | n/a |
| <a name="module_metrics-server-vpa"></a> [metrics-server-vpa](#module\_metrics-server-vpa) | ./modules/metrics-server-vpa | n/a |
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_acm_certificate_arn"></a> [alb\_acm\_certificate\_arn](#input\_alb\_acm\_certificate\_arn) | ARN of the ACM certificate to be used for ALB Ingress. | `string` | `""` | no |
| <a name="input_amazon_eks_aws_ebs_csi_driver_config"></a> [amazon\_eks\_aws\_ebs\_csi\_driver\_config](#input\_amazon\_eks\_aws\_ebs\_csi\_driver\_config) | configMap for AWS EBS CSI Driver add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_vpc_cni_enabled"></a> [amazon\_eks\_vpc\_cni\_enabled](#input\_amazon\_eks\_vpc\_cni\_enabled) | Enable or disable the installation of the Amazon EKS VPC CNI addon. | `bool` | `false` | no |
| <a name="input_argocd_manage_add_ons"></a> [argocd\_manage\_add\_ons](#input\_argocd\_manage\_add\_ons) | Enable managing add-on configuration via ArgoCD App of Apps | `bool` | `false` | no |
| <a name="input_auto_scaling_group_names"></a> [auto\_scaling\_group\_names](#input\_auto\_scaling\_group\_names) | List of self-managed node groups autoscaling group names | `list(string)` | `[]` | no |
| <a name="input_aws_efs_csi_driver_helm_config"></a> [aws\_efs\_csi\_driver\_helm\_config](#input\_aws\_efs\_csi\_driver\_helm\_config) | AWS EFS CSI driver Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_load_balancer_controller_enabled"></a> [aws\_load\_balancer\_controller\_enabled](#input\_aws\_load\_balancer\_controller\_enabled) | Enable or disable AWS Load Balancer Controller add-on for managing and controlling load balancers in Kubernetes. | `bool` | `false` | no |
| <a name="input_aws_load_balancer_controller_helm_config"></a> [aws\_load\_balancer\_controller\_helm\_config](#input\_aws\_load\_balancer\_controller\_helm\_config) | Configuration for the AWS Load Balancer Controller Helm release | <pre>object({<br>    values                        = any<br>    namespace                     = string<br>    load_balancer_controller_name = string<br>  })</pre> | <pre>{<br>  "load_balancer_controller_name": "",<br>  "namespace": "",<br>  "values": []<br>}</pre> | no |
| <a name="input_aws_node_termination_handler_enabled"></a> [aws\_node\_termination\_handler\_enabled](#input\_aws\_node\_termination\_handler\_enabled) | Enable or disable node termination handler | `bool` | `false` | no |
| <a name="input_aws_node_termination_handler_helm_config"></a> [aws\_node\_termination\_handler\_helm\_config](#input\_aws\_node\_termination\_handler\_helm\_config) | AWS Node Termination Handler Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_node_termination_handler_irsa_policies"></a> [aws\_node\_termination\_handler\_irsa\_policies](#input\_aws\_node\_termination\_handler\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_cert_manager_domain_names"></a> [cert\_manager\_domain\_names](#input\_cert\_manager\_domain\_names) | Domain names of the Route53 hosted zone to use with cert-manager | `list(string)` | `[]` | no |
| <a name="input_cert_manager_enabled"></a> [cert\_manager\_enabled](#input\_cert\_manager\_enabled) | Enable or disable the cert manager add-on for EKS cluster. | `bool` | `false` | no |
| <a name="input_cert_manager_helm_config"></a> [cert\_manager\_helm\_config](#input\_cert\_manager\_helm\_config) | Cert Manager Helm Chart config | `any` | `{}` | no |
| <a name="input_cert_manager_install_letsencrypt_r53_issuers"></a> [cert\_manager\_install\_letsencrypt\_r53\_issuers](#input\_cert\_manager\_install\_letsencrypt\_r53\_issuers) | Enable or disable the creation of Route53 issuer while installing cert manager. | `bool` | `false` | no |
| <a name="input_cert_manager_irsa_policies"></a> [cert\_manager\_irsa\_policies](#input\_cert\_manager\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_cert_manager_kubernetes_svc_image_pull_secrets"></a> [cert\_manager\_kubernetes\_svc\_image\_pull\_secrets](#input\_cert\_manager\_kubernetes\_svc\_image\_pull\_secrets) | list(string) of kubernetes imagePullSecrets | `list(string)` | `[]` | no |
| <a name="input_cert_manager_letsencrypt_email"></a> [cert\_manager\_letsencrypt\_email](#input\_cert\_manager\_letsencrypt\_email) | Specifies the email address to be used by cert-manager to request Let's Encrypt certificates | `string` | `""` | no |
| <a name="input_cluster_autoscaler_chart_version"></a> [cluster\_autoscaler\_chart\_version](#input\_cluster\_autoscaler\_chart\_version) | Version of the cluster autoscaler helm chart | `string` | `"9.29.0"` | no |
| <a name="input_cluster_autoscaler_enabled"></a> [cluster\_autoscaler\_enabled](#input\_cluster\_autoscaler\_enabled) | Whether to enable the Cluster Autoscaler add-on or not. | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_helm_config"></a> [cluster\_autoscaler\_helm\_config](#input\_cluster\_autoscaler\_helm\_config) | CoreDNS Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_cluster_issuer"></a> [cluster\_issuer](#input\_cluster\_issuer) | Specify the letsecrypt cluster-issuer for ingress tls. | `string` | `"letsencrypt-prod"` | no |
| <a name="input_coredns_hpa_enabled"></a> [coredns\_hpa\_enabled](#input\_coredns\_hpa\_enabled) | Determines whether Horizontal Pod Autoscaling (HPA) for CoreDNS is enabled. | `bool` | `false` | no |
| <a name="input_coredns_hpa_helm_config"></a> [coredns\_hpa\_helm\_config](#input\_coredns\_hpa\_helm\_config) | CoreDNS Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_custom_image_registry_uri"></a> [custom\_image\_registry\_uri](#input\_custom\_image\_registry\_uri) | Custom image registry URI map of `{region = dkr.endpoint }` | `map(string)` | `{}` | no |
| <a name="input_data_plane_wait_arn"></a> [data\_plane\_wait\_arn](#input\_data\_plane\_wait\_arn) | Addon deployment will not proceed until this value is known. Set to node group/Fargate profile ARN to wait for data plane to be ready before provisioning addons | `string` | `""` | no |
| <a name="input_defectdojo_enabled"></a> [defectdojo\_enabled](#input\_defectdojo\_enabled) | Enable defectdojo for service mesh. | `bool` | `false` | no |
| <a name="input_defectdojo_hostname"></a> [defectdojo\_hostname](#input\_defectdojo\_hostname) | Specify the hostname for the kubecsot. | `string` | `""` | no |
| <a name="input_efs_storage_class_enabled"></a> [efs\_storage\_class\_enabled](#input\_efs\_storage\_class\_enabled) | Enable or disable the Amazon Elastic File System (EFS) add-on for EKS cluster. | `bool` | `false` | no |
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
| <a name="input_external_secrets_secrets_manager_arns"></a> [external\_secrets\_secrets\_manager\_arns](#input\_external\_secrets\_secrets\_manager\_arns) | List of Secrets Manager ARNs that contain secrets to mount using External Secrets | `list(string)` | <pre>[<br>  "arn:aws:secretsmanager:*:*:secret:*"<br>]</pre> | no |
| <a name="input_external_secrets_ssm_parameter_arns"></a> [external\_secrets\_ssm\_parameter\_arns](#input\_external\_secrets\_ssm\_parameter\_arns) | List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets | `list(string)` | <pre>[<br>  "arn:aws:ssm:*:*:parameter/*"<br>]</pre> | no |
| <a name="input_falco_enabled"></a> [falco\_enabled](#input\_falco\_enabled) | Determines whether Falco is enabled. | `bool` | `false` | no |
| <a name="input_ingress_nginx_config"></a> [ingress\_nginx\_config](#input\_ingress\_nginx\_config) | Configure ingress-nginx to setup addons | <pre>object({<br>    ingress_class_name     = string<br>    enable_service_monitor = bool<br>    values                 = any<br>    namespace              = string<br>  })</pre> | <pre>{<br>  "enable_service_monitor": false,<br>  "ingress_class_name": "ingress-nginx",<br>  "namespace": "ingress-nginx",<br>  "values": {}<br>}</pre> | no |
| <a name="input_ingress_nginx_enabled"></a> [ingress\_nginx\_enabled](#input\_ingress\_nginx\_enabled) | Control wheather to install public nlb or private nlb. Default is private | `bool` | `false` | no |
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | whether IPv6 enabled or not | `bool` | `false` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_k8s_dashboard_hostname"></a> [k8s\_dashboard\_hostname](#input\_k8s\_dashboard\_hostname) | Specify the hostname for the k8s dashboard. | `string` | `""` | no |
| <a name="input_k8s_dashboard_ingress_load_balancer"></a> [k8s\_dashboard\_ingress\_load\_balancer](#input\_k8s\_dashboard\_ingress\_load\_balancer) | Controls whether to enable ALB Ingress or not. | `string` | `"nlb"` | no |
| <a name="input_karpenter_enabled"></a> [karpenter\_enabled](#input\_karpenter\_enabled) | Enable or disable Karpenter, a Kubernetes-native, multi-tenant, and auto-scaling solution for containerized workloads on Kubernetes. | `bool` | `false` | no |
| <a name="input_karpenter_helm_config"></a> [karpenter\_helm\_config](#input\_karpenter\_helm\_config) | Karpenter autoscaler add-on config | `any` | `{}` | no |
| <a name="input_karpenter_irsa_policies"></a> [karpenter\_irsa\_policies](#input\_karpenter\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_karpenter_node_iam_instance_profile"></a> [karpenter\_node\_iam\_instance\_profile](#input\_karpenter\_node\_iam\_instance\_profile) | Karpenter Node IAM Instance profile id | `string` | `""` | no |
| <a name="input_karpenter_provisioner_config"></a> [karpenter\_provisioner\_config](#input\_karpenter\_provisioner\_config) | Configuration to provide settings for Karpenter, including which private subnet to use, instance capacity types, and excluded instance types. | `any` | <pre>{<br>  "excluded_instance_type": [<br>    "nano",<br>    "micro",<br>    "small"<br>  ],<br>  "instance_capacity_type": [<br>    "spot"<br>  ],<br>  "instance_hypervisor": [<br>    "nitro"<br>  ],<br>  "private_subnet_name": ""<br>}</pre> | no |
| <a name="input_karpenter_provisioner_enabled"></a> [karpenter\_provisioner\_enabled](#input\_karpenter\_provisioner\_enabled) | Enable or disable the installation of Karpenter, which is a Kubernetes cluster autoscaler. | `bool` | `false` | no |
| <a name="input_keda_enabled"></a> [keda\_enabled](#input\_keda\_enabled) | Enable or disable Kubernetes Event-driven Autoscaling (KEDA) add-on for autoscaling workloads. | `bool` | `false` | no |
| <a name="input_keda_helm_config"></a> [keda\_helm\_config](#input\_keda\_helm\_config) | KEDA Event-based autoscaler add-on config | `any` | `{}` | no |
| <a name="input_keda_irsa_policies"></a> [keda\_irsa\_policies](#input\_keda\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used to encrypt AWS resources in the EKS cluster. | `string` | `""` | no |
| <a name="input_kms_policy_arn"></a> [kms\_policy\_arn](#input\_kms\_policy\_arn) | Specify the ARN of KMS policy, for service accounts. | `string` | `""` | no |
| <a name="input_kubeclarity_enabled"></a> [kubeclarity\_enabled](#input\_kubeclarity\_enabled) | Enable or disable the deployment of an kubeclarity for Kubernetes. | `bool` | `false` | no |
| <a name="input_kubeclarity_hostname"></a> [kubeclarity\_hostname](#input\_kubeclarity\_hostname) | Specify the hostname for the Kubeclarity. | `string` | `""` | no |
| <a name="input_kubeclarity_namespace"></a> [kubeclarity\_namespace](#input\_kubeclarity\_namespace) | Name of the Kubernetes namespace where the kubeclarity deployment will be deployed. | `string` | `"kubeclarity"` | no |
| <a name="input_kubecost_enabled"></a> [kubecost\_enabled](#input\_kubecost\_enabled) | Enable or disable the deployment of an Kubecost for Kubernetes. | `bool` | `false` | no |
| <a name="input_kubecost_hostname"></a> [kubecost\_hostname](#input\_kubecost\_hostname) | Specify the hostname for the kubecsot. | `string` | `""` | no |
| <a name="input_kubernetes_dashboard_config"></a> [kubernetes\_dashboard\_config](#input\_kubernetes\_dashboard\_config) | Specify all the configuration setup here | <pre>object({<br>    k8s_dashboard_ingress_load_balancer = string<br>    alb_acm_certificate_arn             = string<br>    k8s_dashboard_hostname              = string<br>    private_alb_enabled                 = bool<br>  })</pre> | <pre>{<br>  "alb_acm_certificate_arn": "",<br>  "k8s_dashboard_hostname": "",<br>  "k8s_dashboard_ingress_load_balancer": "",<br>  "private_alb_enabled": false<br>}</pre> | no |
| <a name="input_kubernetes_dashboard_enabled"></a> [kubernetes\_dashboard\_enabled](#input\_kubernetes\_dashboard\_enabled) | Determines whether k8s-dashboard is enabled or not | `bool` | `false` | no |
| <a name="input_metrics_server_enabled"></a> [metrics\_server\_enabled](#input\_metrics\_server\_enabled) | Enable or disable the metrics server add-on for EKS cluster. | `bool` | `false` | no |
| <a name="input_metrics_server_helm_config"></a> [metrics\_server\_helm\_config](#input\_metrics\_server\_helm\_config) | Metrics Server Helm Chart config | `any` | `{}` | no |
| <a name="input_metrics_server_helm_version"></a> [metrics\_server\_helm\_version](#input\_metrics\_server\_helm\_version) | Version of the metrics server helm chart | `string` | `"3.11.0"` | no |
| <a name="input_name"></a> [name](#input\_name) | Specify the name prefix of the EKS cluster resources. | `string` | `""` | no |
| <a name="input_node_termination_handler_version"></a> [node\_termination\_handler\_version](#input\_node\_termination\_handler\_version) | Specify the version of node termination handler | `string` | `"0.21.0"` | no |
| <a name="input_private_nlb_enabled"></a> [private\_nlb\_enabled](#input\_private\_nlb\_enabled) | Control wheather to install public nlb or private nlb. Default is private | `bool` | `false` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets of the VPC which can be used by EFS | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_reloader_enabled"></a> [reloader\_enabled](#input\_reloader\_enabled) | Enable or disable Reloader, a Kubernetes controller to watch changes in ConfigMap and Secret objects and trigger an application reload on their changes. | `bool` | `false` | no |
| <a name="input_reloader_helm_config"></a> [reloader\_helm\_config](#input\_reloader\_helm\_config) | Reloader Helm Chart config | `any` | `{}` | no |
| <a name="input_self_managed_aws_ebs_csi_driver_helm_config"></a> [self\_managed\_aws\_ebs\_csi\_driver\_helm\_config](#input\_self\_managed\_aws\_ebs\_csi\_driver\_helm\_config) | Self-managed aws-ebs-csi-driver Helm chart config | `any` | `{}` | no |
| <a name="input_service_monitor_crd_enabled"></a> [service\_monitor\_crd\_enabled](#input\_service\_monitor\_crd\_enabled) | Enable or disable the installation of Custom Resource Definitions (CRDs) for Prometheus Service Monitor. | `bool` | `false` | no |
| <a name="input_single_az_ebs_gp3_storage_class_enabled"></a> [single\_az\_ebs\_gp3\_storage\_class\_enabled](#input\_single\_az\_ebs\_gp3\_storage\_class\_enabled) | Whether to enable the Single AZ storage class or not. | `bool` | `false` | no |
| <a name="input_single_az_sc_config"></a> [single\_az\_sc\_config](#input\_single\_az\_sc\_config) | Name and regions for storage class in Key-Value pair. | `list(any)` | `[]` | no |
| <a name="input_slack_webhook"></a> [slack\_webhook](#input\_slack\_webhook) | The Slack webhook URL used for notifications. | `string` | `""` | no |
| <a name="input_storage_class_name"></a> [storage\_class\_name](#input\_storage\_class\_name) | Specify the hostname for the kubecsot. | `string` | `"infra-service-sc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_velero_config"></a> [velero\_config](#input\_velero\_config) | Configuration to provide settings for Velero, including which namespaces to backup, retention period, backup schedule, and backup bucket name. | `any` | <pre>{<br>  "backup_bucket_name": "",<br>  "namespaces": "",<br>  "retention_period_in_days": 45,<br>  "schedule_backup_cron_time": "",<br>  "slack_appToken": "",<br>  "slack_botToken": "",<br>  "slack_notification_channel_name": "",<br>  "velero_backup_name": ""<br>}</pre> | no |
| <a name="input_velero_enabled"></a> [velero\_enabled](#input\_velero\_enabled) | Enable or disable the installation of Velero, which is a backup and restore solution for Kubernetes clusters. | `bool` | `false` | no |
| <a name="input_velero_notification_enabled"></a> [velero\_notification\_enabled](#input\_velero\_notification\_enabled) | Enable or disable the notification for velero backup. | `bool` | `false` | no |
| <a name="input_vpa_config"></a> [vpa\_config](#input\_vpa\_config) | Configure VPA CRD to setup addon | <pre>object({<br>    values = list(string)<br>  })</pre> | <pre>{<br>  "values": []<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster and its nodes will be provisioned | `string` | `""` | no |
| <a name="input_worker_iam_role_arn"></a> [worker\_iam\_role\_arn](#input\_worker\_iam\_role\_arn) | Specify the IAM role Arn for the nodes | `string` | `""` | no |
| <a name="input_worker_iam_role_name"></a> [worker\_iam\_role\_name](#input\_worker\_iam\_role\_name) | Specify the IAM role for the nodes that will be provisioned through karpenter | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
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
