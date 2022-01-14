provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
  }
}

variable "helm_repo" {
  type = string
  default = "https://kubernetes-charts.storage.googleapis.com"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
}

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"

    annotations = {
      name = "kafka"
    }
  }
}
