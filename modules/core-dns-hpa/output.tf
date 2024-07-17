output "helm_release_status" {
  description = "Status of the Helm release"
  value       = helm_release.coredns-hpa.status
}
