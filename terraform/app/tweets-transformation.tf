resource "kubernetes_pod" "tweets-transformation" {
  metadata {
    name = "tweets-transformation"
    namespace = "kafka"
    labels = {
      app = "tweets-transformation"
    }
  }

  spec {
    container {
      image = "${var.tweets-transformation-img}"
      image_pull_policy = "IfNotPresent"
      name  = "tweets-transformation-1"
    }
  }
}

variable "tweets-transformation-img" {
  type = "string"
  default = "tweets-transformation:latest"
}