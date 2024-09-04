resource "helm_release" "argo_project" {
  name       = "argo-project"
  chart      = "${path.module}/argo-project"
  values = [templatefile("${path.module}/argo-project/values.yaml", {
    namespace  = var.namespace
    name = var.name
  })]
  namespace  = var.namespace
}