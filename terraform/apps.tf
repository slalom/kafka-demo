resource "helm_release" "kafka-streams" {
  name       = "kafka-streams"
  chart = "../kafka-streams/chart"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
}

resource "helm_release" "tweets-transformation" {
  name       = "tweets-transformation"
  chart = "../tweets-transformation/chart"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
}

resource "helm_release" "twitter-forwarder" {
  name       = "twitter-forwarder"
  chart = "../twitter-forwarder/chart"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
}