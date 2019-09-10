
provider "helm" {
}

provider "kubernetes" {
}

provider "aws" {
  version = ">= 2.11"
  region = "us-west-2"
}

module "eks" {
  source = "./eks"
  providers = {
    aws = "aws"
  }
}

module "kube" {
  source = "./kube"
  providers = {
    helm = "helm"
    kubernetes = "kubernetes"
  }
}
