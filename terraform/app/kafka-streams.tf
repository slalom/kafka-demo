resource "kubernetes_pod" "kafka-streams" {
  metadata {
    name = "kafka-streams"
    namespace = "kafka"
  }

  spec {
    container {
      image = "${var.kafka-streams-img}"
      image_pull_policy = "IfNotPresent"
      name  = "kafka-streams-1"
    }
  }
}

variable "kafka-streams-img" {
  type = "string"
  default = "kafka-streams:latest"
}
