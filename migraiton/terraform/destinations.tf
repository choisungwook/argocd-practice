resource "kind_cluster" "cluster_a" {
  name           = "cluster-a"
  wait_for_ready = true
  node_image     = "kindest/node:v1.29.2"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }
  }
}

resource "kind_cluster" "cluster_b" {
  name           = "cluster-b"
  wait_for_ready = true
  node_image     = "kindest/node:v1.29.2"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }
  }
}

resource "kind_cluster" "cluster_c" {
  name           = "cluster-c"
  wait_for_ready = true
  node_image     = "kindest/node:v1.29.2"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }
  }
}
