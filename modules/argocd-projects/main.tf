resource "helm_release" "argo_project" {
  name       = "argo-project"
  chart      = "${path.module}/argo-project"
  namespace  = "argocd"
}