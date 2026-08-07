

terraform {
  backend "s3" {
    bucket = "asset-bucket-790"
    key    = "terraform-aws-environment/terraform.tfstate"
    region = "ap-south-1"
  }
}
