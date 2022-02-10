# resource "helm_release" "jenkins" {
#   name       = "jenkins"
#   repository = "https://kubernetes-charts.storage.googleapis.com"
#   chart      = "jenkins"
#   namespace  = kubernetes_namespace.kafka.metadata[0].name
#   set {
#     name  = "master.servicePort"
#     value = "8081"
#   }
# }

