terraform {
  backend "s3" {
    bucket         = "devops-stage-6-terraform-state1"
    key            = "prod/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
  }
}