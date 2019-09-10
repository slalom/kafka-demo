module "cluster" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "kafka-demo"
  subnets      = [""]
  vpc_id       = ""
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