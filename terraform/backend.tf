terraform {
  backend "s3" {
    bucket  = "tfstatefile-depi-project-123456789"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
