
terraform {
  backend "s3" {
    bucket = "mybucketskillnet"
    key    = "path/terraform.tfstate"
    region = "us-east-1"
  }
}
