terraform {
  backend "s3" {
    bucket         = "your-s3-bucket-name"
    key            = "path/to/your/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}
