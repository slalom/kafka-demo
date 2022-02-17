provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "dan.siwiec@slalom.com@kafka-demo.us-west-1.eksctl.io"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "dan.siwiec@slalom.com@kafka-demo.us-west-1.eksctl.io"
}

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"

    annotations = {
      name = "kafka"
    }
  }
}
