module "cluster" {
  source       = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v4.0.2"
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