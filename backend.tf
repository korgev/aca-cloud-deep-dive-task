terraform {
  backend "s3" {
    bucket         = "aca-cloud-deep-dive-tf-backend"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "aca-cloud-deep-dive-tf-backend/homework/aca-terraform-states.tfstate"
    region         = "us-east-1"
  }
}