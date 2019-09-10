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
      image = "906390086161.dkr.ecr.us-west-2.amazonaws.com/tweets-transformation"
      image_pull_policy = "IfNotPresent"
      name  = "tweets-transformation-1"
    }
  }
}