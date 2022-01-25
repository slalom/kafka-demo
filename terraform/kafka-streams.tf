resource "kubernetes_pod" "kafka-streams" {
  metadata {
    name      = "kafka-streams"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }

  spec {
    container {
      image             = "slalom/kafka-streams"
      image_pull_policy = "Never"
      name              = "kafka-streams-1"
    }
  }
}
