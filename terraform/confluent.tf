resource "helm_release" "confluent" {
  name       = "confluent"
  repository = "https://confluentinc.github.io/cp-helm-charts/"
  chart      = "cp-helm-charts"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

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

  set {
    name  = "cp-kafka.brokers"
    value = "3"
  }

  set {
    name = "cp-kafka-connect.image"
    value = "slalom/kafka-connect-jdbc"
  }

  set {
    name = "cp-kafka-connect.imageTag"
    value = "latest"
  }
}
