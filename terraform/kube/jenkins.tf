# resource "helm_release" "jenkins" {
#   name       = "jenkins"
#   repository = "${data.helm_repository.stable.metadata.0.name}"
#   chart      = "jenkins"
#   namespace  = "kafka"

#   set {
#     name  = "master.servicePort"
#     value = "8081"
#   }
# }
