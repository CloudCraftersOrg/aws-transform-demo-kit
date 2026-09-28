provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "transform-demo"
      Env       = "oramod"
      Owner     = var.owner
      ManagedBy = "terraform"
    }
  }
}
