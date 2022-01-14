resource "helm_release" "pg" {
  name       = "pg"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  values = [
    "${file("../pg/pg-values.yaml")}",
  ]

  set {
    name  = "persistence.enabled"
    value = "false"
  }
}
