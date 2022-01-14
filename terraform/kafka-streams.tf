resource "kubernetes_pod" "kafka-streams" {
  metadata {
    name      = "kafka-streams"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }

  spec {
    container {
      image             = "sfo/kafka-streams"
      image_pull_policy = "IfNotPresent"
      name              = "kafka-streams-1"
    }
  }
}
