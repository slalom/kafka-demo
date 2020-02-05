resource "helm_release" "pg" {
  name       = "pg"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "postgresql"
  namespace  = "kafka"

  values = [
    "${file("pg/pg-values.yaml")}",
  ]

  set {
    name  = "persistence.enabled"
    value = "false"
  }
}
