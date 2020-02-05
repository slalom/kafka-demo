resource "kubernetes_pod" "twitter-forwarder" {
  metadata {
    name      = "twitter-forwarder"
    namespace = "kafka"

    labels = {
      app = "twitter-forwarder"
    }
  }

  spec {
    container {
      image             = "sfo/twitter-forwarder"
      image_pull_policy = "IfNotPresent"
      name              = "twitter-forwarder-1"
    }
  }
}

resource "kubernetes_service" "twitter-forwarder" {
  metadata {
    name      = "twitter-forwarder"
    namespace = "kafka"
  }

  spec {
    selector = {
      app = "${kubernetes_pod.twitter-forwarder.metadata.0.labels.app}"
    }

    port {
      port        = 3000
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
