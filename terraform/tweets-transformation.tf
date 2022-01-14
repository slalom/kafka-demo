resource "kubernetes_pod" "tweets-transformation" {
  metadata {
    name      = "tweets-transformation"
    namespace = kubernetes_namespace.kafka.metadata[0].name

    labels = {
      app = "tweets-transformation"
    }
  }

  spec {
    container {
      image             = "sfo/tweets-transformation"
      image_pull_policy = "IfNotPresent"
      name              = "tweets-transformation-1"
    }
  }
}
