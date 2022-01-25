resource "kubernetes_pod" "twitter-forwarder" {
  metadata {
    name      = "twitter-forwarder"
    namespace = kubernetes_namespace.kafka.metadata[0].name

    labels = {
      app = "twitter-forwarder"
    }
  }

  spec {
    container {
      image             = "slalom/twitter-forwarder"
      image_pull_policy = "Never"
      name              = "twitter-forwarder-1"
    }
  }
}

resource "kubernetes_service" "twitter-forwarder" {
  metadata {
    name      = "twitter-forwarder"
    namespace = kubernetes_namespace.kafka.metadata[0].name
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
