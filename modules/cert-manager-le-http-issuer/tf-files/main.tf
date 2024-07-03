resource "helm_release" "cert-manager-le-http-issuer" {
  name       = "cert-manager-le-http-issuer"
  chart      = "${path.module}/../yaml-files/"
  version    = "0.1.0"
  
  set {
    name  = "email"
    value = var.cert_manager_letsencrypt_email
    type  = "string"
  }
}
