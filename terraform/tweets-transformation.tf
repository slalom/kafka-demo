# resource "kubernetes_pod" "tweets-transformation" {
#   metadata {
#     name = "tweets-transformation"
#     namespace = "kafka"
#     labels = {
#       app = "tweets-transformation"
#     }
#   }

#   spec {
#     container {
#       image = "sfo/tweets-transformation"
#       image_pull_policy = "IfNotPresent"
#       name  = "tweets-transformation-1"
#     }
#   }
# }

# resource "kubernetes_service" "tweets-transformation" {
#   metadata {
#     name = "tweets-transformation"
#     namespace = "kafka"
#   }
#   spec {
#     selector = {
#       app = "${kubernetes_pod.tweets-transformation.metadata.0.labels.app}"
#     }
#     port {
#       port        = 3000
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }