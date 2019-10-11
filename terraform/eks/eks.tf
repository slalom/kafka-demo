module "cluster" {
  source       = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v4.0.2"
  cluster_name = "kafka-demo"
  subnets      = ["${module.vpc.public_subnets}"]
  vpc_id       = "${module.vpc.vpc_id}"
  cluster_create_timeout = "30m"
  cluster_delete_timeout = "30m"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 2
      asg_desired_capacity = 2
    }
  ]
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "region" {
  value = "${data.aws_region.current.name}"
}

module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "1.60.0"
  name           = "kafka-demo-vpc"
  cidr           = "10.0.0.0/16"
  azs            = ["${data.aws_availability_zones.available.names}"]
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  tags = {
    "kubernetes.io/cluster/kafka-demo" = "shared"
  }
}