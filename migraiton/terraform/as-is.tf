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

resource "helm_release" "as_is_argocd" {
  provider = helm.as-is

  name             = "as-is-argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_helm_chart_version
  # wait             = false

  values = [
    "${file("values.yaml")}"
  ]

  set {
    name  = "server.service.type"
    value = "NodePort"
  }

  set {
    name  = "server.service.nodePortHttps"
    value = "30950"
  }
}
