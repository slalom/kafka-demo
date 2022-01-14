# resource "helm_release" "jenkins" {
#   name       = "jenkins"
#   repository = var.helm_repo
#   chart      = "jenkins"
#   namespace  = kubernetes_namespace.kafka.metadata[0].name
#   set {
#     name  = "master.servicePort"
#     value = "8081"
#   }
# }

