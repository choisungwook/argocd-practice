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

resource "helm_release" "to_be_argocd" {
  provider = helm.to-be

  name             = "to-be-argocd"
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
    value = "30960"
  }
}
