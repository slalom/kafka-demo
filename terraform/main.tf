provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
  }
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
