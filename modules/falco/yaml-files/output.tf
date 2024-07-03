output "falco_namespace" {
  value = kubernetes_namespace.falco.metadata[0].name
  description = "The namespace where Falco is deployed"
}

output "falco_release" {
  value = helm_release.falco.name
  description = "The Helm release name for Falco"
}
