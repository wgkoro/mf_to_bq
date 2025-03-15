terraform {
  required_version = "~> 1.7.0"
  
  backend "gcs" {
    bucket = "zeathwing-houseworks-infra"
    prefix = "terraform/health"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}

locals {
  project_id = "zeathwing-houseworks"  # あなたのプロジェクトID
  region     = "asia-northeast1"        # デフォルトリージョン
}
