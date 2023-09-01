resource "kubernetes_namespace" "securecodebox-system" {
  metadata {
    name = "securecodebox-system"
  }
}

resource "helm_release" "securecodebox_operator" {
  depends_on = [kubernetes_namespace.securecodebox-system]
  name       = "securecodebox"
  repository = "https://charts.securecodebox.io"
  chart      = "operator"
  namespace  = "securecodebox-system"
  timeout    = 600
  values = [
    file("${path.module}/helm/securecodebox.yaml")
  ]
}

resource "helm_release" "zap" {
  depends_on = [helm_release.securecodebox_operator]
  name       = "zap-advanced"
  repository = "https://charts.securecodebox.io"
  chart      = "zap-advanced"
  namespace  = "securecodebox-system"
  timeout    = 600
}

resource "helm_release" "zap_advanced" {
  depends_on = [helm_release.securecodebox_operator]
  name       = "zap"
  repository = "https://charts.securecodebox.io"
  chart      = "zap"
  namespace  = "securecodebox-system"
  timeout    = 600
}

resource "helm_release" "nmap" {
  depends_on = [helm_release.securecodebox_operator]
  name       = "nmap"
  repository = "https://charts.securecodebox.io"
  chart      = "nmap"
  namespace  = "securecodebox-system"
  timeout    = 600
}

resource "helm_release" "sslyze" {
  depends_on = [helm_release.securecodebox_operator]
  name       = "sslyze"
  repository = "https://charts.securecodebox.io"
  chart      = "sslyze"
  namespace  = "securecodebox-system"
  timeout    = 600
}

# resource "kubernetes_secret" "defectdojo" {
#   metadata {
#     name      = "defectdojo-secret"
#     namespace = "securecodebox-system"
#   }
#   data = {
#     username = "admin"
#     apikey = "84ed72f2107eeaae983f59ac4f09164f79945d58" #var.apikey
#   }
#   type       = "Opaque"
#   depends_on = [kubernetes_namespace.securecodebox-system]
# }

resource "helm_release" "persistence-defectdojo" {
  depends_on = [helm_release.securecodebox_operator]
  name       = "persistence-defectdojo"
  repository = "https://charts.securecodebox.io"
  chart      = "persistence-defectdojo"
  namespace  = "securecodebox-system"
  timeout    = 600
  values = [
    templatefile("${path.module}/helm/persistence-defectdojo.yaml", {
      defectdojo_hostname = var.defectdojo_hostname
    })
  ]
}
