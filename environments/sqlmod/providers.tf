provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "transform-demo"
      Env       = "sqlmod"
      Owner     = var.owner
      ManagedBy = "terraform"
    }
  }
}
