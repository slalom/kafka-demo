provider "helm" {}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

provider "kubernetes" {}

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"

    annotations = {
      name = "kafka"
    }
  }
}
