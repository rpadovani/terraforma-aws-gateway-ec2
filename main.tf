terraform {
  backend "s3" {
    bucket = "where-to-save-state"
    key    = "unique-key/terraform.tfstate"
    region = "eu-central-1"
    acl    = "private"
  }
}

provider "aws" {
  region     = "eu-central-1"
  version    = "~> 1.15"
}