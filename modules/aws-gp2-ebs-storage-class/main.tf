resource "kubernetes_storage_class_v1" "gp2_sc" {
  count = var.single_az_ebs_gp2_storage_class_enabled ? 1 : 0
  metadata {
    name = var.single_az_ebs_gp2_storage_class_name
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    type      = "gp2"
    encrypted = true
    kmskeyId  = var.kms_key_id
    zone      = var.availability_zone
  }
}
