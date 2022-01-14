resource "helm_release" "prometheus" {
  name       = "prometheus-kafka-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-kafka-exporter"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  values = [
    "${file("../grafana/values.yaml")}",
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
