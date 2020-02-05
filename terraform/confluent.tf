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

  set {
    name  = "cp-kafka.brokers"
    value = "3"
  }
}
