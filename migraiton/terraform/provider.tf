terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.4.0"
    }
  }
}

provider "kind" {}

provider "helm" {
  alias = "as-is"
  kubernetes {
    host                   = kind_cluster.as-is.endpoint
    cluster_ca_certificate = kind_cluster.as-is.cluster_ca_certificate
    client_key             = kind_cluster.as-is.client_key
    client_certificate     = kind_cluster.as-is.client_certificate
  }
}

provider "helm" {
  alias = "to-be"
  kubernetes {
    host                   = kind_cluster.to-be.endpoint
    cluster_ca_certificate = kind_cluster.to-be.cluster_ca_certificate
    client_key             = kind_cluster.to-be.client_key
    client_certificate     = kind_cluster.to-be.client_certificate
  }
}
