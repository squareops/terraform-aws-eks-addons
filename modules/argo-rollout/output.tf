output "argorollout_credentials" {
  value = var.argorollout_config.enable_dashboard == true && var.argorollout_config.argorollout_ingress_load_balancer == "nlb" ? {
    username = "admin"
    password = nonsensitive(random_password.argorollout_password[0].result)
    hostname = var.argorollout_config.hostname
  } : { hostname = var.argorollout_config.hostname }
}
