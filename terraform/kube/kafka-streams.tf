resource "kubernetes_pod" "kafka-streams" {
  metadata {
    name = "kafka-streams"
    namespace = "kafka"
  }

  spec {
    container {
      image = "906390086161.dkr.ecr.us-west-2.amazonaws.com/kafka-streams"
      image_pull_policy = "IfNotPresent"
      name  = "kafka-streams-1"
    }
  }
}