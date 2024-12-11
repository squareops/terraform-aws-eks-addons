output "argorollout_host" {
  value = var.argorollout_config.hostname
}

output "argo_workflow_token" {
  # value = "Bearer ${nonsensitive(kubernetes_secret.argo_workflow_token_secret.data.token)}"
  value = "test"
}
