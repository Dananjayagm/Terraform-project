terraform {
  backend "s3" {
    bucket         = "terraform-statefile"
    key            = "**********/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}
