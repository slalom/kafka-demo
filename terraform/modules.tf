
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

module "app" {
  source = "./app"
  providers = {
    helm = "helm"
    kubernetes = "kubernetes"
  }
  kafka-streams-img = "${var.is_aws == true ? join("." , list(module.eks.account_id,"dkr.ecr",module.eks.region,"amazonaws.com/kafka-streams:latest")) : "kafka-streams:latest"}"
  twitter-forwarder-img = "${var.is_aws == true ? join("." , list(module.eks.account_id,"dkr.ecr",module.eks.region,"amazonaws.com/twitter-forwarder:latest")) : "twitter-forwarder:latest"}"
  tweets-transformation-img  = "${var.is_aws == true ? join("." , list(module.eks.account_id,"dkr.ecr",module.eks.region,"amazonaws.com/tweets-transformation:latest")) : "tweets-transformation:latest"}"
}

variable "is_aws" {
  type = "string"
  default = "false"
}