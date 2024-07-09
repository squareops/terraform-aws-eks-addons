output "k8s-dashboard-admin-token" {
  value = nonsensitive(kubernetes_secret_v1.admin-user.data.token) 
}

output "k8s-dashboard-read-only-token" {
  value = nonsensitive(kubernetes_secret_v1.dashboard_read_only_sa_token.data.token)
}