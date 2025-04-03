resource "kubernetes_storage_class_v1" "single_az_sc" {
  count = var.single_az_ebs_gp3_storage_class ? 1 : 0
  metadata {
    name = var.single_az_ebs_gp3_storage_class_name
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = merge(
    {
      type      = "gp3"
      encrypted = true
      kmskeyId  = var.kms_key_id != "" ? var.kms_key_id : null
      zone      = var.availability_zone
    },
    { for k, v in var.tags_all : "tagSpecification_${k}" => "${k}=${v}" }
  )
}
