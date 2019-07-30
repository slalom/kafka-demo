resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "prometheus"
  namespace  = "kafka"
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "grafana"
  namespace  = "kafka"

  values = [
    "${file("grafana/values.yaml")}",
  ]

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.port"
    value = "8083"
  }
}