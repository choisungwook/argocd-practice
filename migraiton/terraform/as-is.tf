resource "kind_cluster" "as-is" {
  name           = "as-is"
  wait_for_ready = true
  node_image     = "kindest/node:v1.28.7"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # ArgoCD NodePort
      extra_port_mappings {
        container_port = 30950
        host_port      = 30950
      }
    }

    node {
      role = "worker"
    }
  }
}
