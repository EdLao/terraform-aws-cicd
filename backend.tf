terraform {
  backend "s3" {
    bucket       = "edlao-terraform-state-083026"
    key          = "project3/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}
