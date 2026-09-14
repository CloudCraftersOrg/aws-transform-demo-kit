terraform {
  backend "s3" {
    bucket       = "transform-demo-tfstate-337058058699-use1"
    key          = "discovery-collector/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
