resource "kind_cluster" "to-be" {
  name           = "to-be"
  wait_for_ready = true
  node_image     = "kindest/node:v1.29.2"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # ArgoCD NodePort
      extra_port_mappings {
        container_port = 30960
        host_port      = 30960
      }
    }

    node {
      role = "worker"
    }
  }
}
