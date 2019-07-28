provider "helm" {}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "jenkins"
  namespace  = "kafka"

  set {
    name  = "master.servicePort"
    value = "8081"
  }
}

resource "helm_release" "kube-dashboard" {
  name       = "kube-dashboard"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "kubernetes-dashboard"
}

resource "helm_release" "confluent" {
  name       = "confluent"
  repository = "./"
  chart      = "cp-helm-charts"
  namespace  = "kafka"
}

resource "helm_release" "publisher" {
  depends_on = ["helm_release.confluent"]

  name       = "publisher"
  repository = "./"
  chart      = "python-chart"
  namespace  = "kafka"

  set {
    name  = "image.repository"
    value = "sfo/python-publisher"
  }
}

resource "helm_release" "pg" {
  name       = "pg"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "postgresql"
  namespace  = "kafka"

  values = [
    "${file("pg/pg-values.yaml")}"
  ]

  set {
    name = "persistence.enabled"
    value = "false"
  }
}