output "k8s-dashboard-admin-token" {
  value = var.kubernetes_dashboard_enabled ? nonsensitive(kubernetes_secret_v1.admin-user[0].data.token) : null
}

output "k8s-dashboard-read-only-token" {
  value = var.kubernetes_dashboard_enabled ? nonsensitive(kubernetes_secret_v1.dashboard_read_only_sa_token[0].data.token) : null
}