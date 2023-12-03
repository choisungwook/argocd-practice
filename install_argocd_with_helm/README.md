# 개요
* helm 으로 argocd 설치

# 설치방법

* helm chart 추가

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

* helm chart 릴리즈

```bash
helm upgrade --install argocd argo/argo-cd \
  -n argocd --create-namespace \
  -f my-values.yaml
```

# 삭제방법

```bash
helm uninstall -n argocd argocd
```

# EKS에 ArgoCD 설치
* [메뉴얼 바로가기](./eks/)
