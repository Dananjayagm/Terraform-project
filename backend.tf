terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "ecs-cluster/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table"
  }
}
