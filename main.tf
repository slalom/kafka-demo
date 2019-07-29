provider "helm" {}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

# resource "helm_release" "jenkins" {
#   name       = "jenkins"
#   repository = "${data.helm_repository.stable.metadata.0.name}"
#   chart      = "jenkins"
#   namespace  = "kafka"

#   set {
#     name  = "master.servicePort"
#     value = "8081"
#   }
# }

# resource "helm_release" "kube-dashboard" {
#   name       = "kube-dashboard"
#   repository = "${data.helm_repository.stable.metadata.0.name}"
#   chart      = "kubernetes-dashboard"
# }

resource "helm_release" "confluent" {
  name       = "confluent"
  repository = "./"
  chart      = "cp-helm-charts"
  namespace  = "kafka"

  set {
    name  = "cp-kafka.persistence.enabled"
    value = "false"
  }

  set {
    name  = "cp-zookeeper.persistence.enabled"
    value = "false"
  }

  set {
    name  = "cp-zookeeper.servers"
    value = "1"
  }
}

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


provider "kubernetes" {
}

resource "kubernetes_pod" "twitter-forwarder" {
  metadata {
    name = "twitter-forwarder"
    namespace = "kafka"
    labels = {
      app = "twitter-forwarder"
    }
  }

  spec {
    container {
      image = "sfo/twitter-forwarder"
      image_pull_policy = "IfNotPresent"
      name  = "twitter-forwarder-1"
    }
  }
}

resource "kubernetes_service" "twitter-forwarder" {
  metadata {
    name = "twitter-forwarder"
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

resource "kubernetes_pod" "kafka-streams" {
  metadata {
    name = "kafka-streams"
    namespace = "kafka"
  }

  spec {
    container {
      image = "sfo/kafka-streams"
      image_pull_policy = "IfNotPresent"
      name  = "kafka-streams-1"
    }
  }
}
