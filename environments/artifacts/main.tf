# Standalone root for the persistent artifacts bucket: it must SURVIVE
# `terraform destroy` of the on-demand roots (sqlmod, oramod,
# discovery-collector). Destroy cycles never touch this root.

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "transform-demo-tfstate-337058058699-use1"
    key          = "artifacts/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "transform-demo"
      Env       = "demo"
      Owner     = "davismar98"
      ManagedBy = "terraform"
    }
  }
}

module "artifacts" {
  source = "../../modules/artifacts"

  bucket_name = "transform-demo-artifacts-337058058699-use1"
}

output "bucket_name" {
  value = module.artifacts.bucket_name
}
