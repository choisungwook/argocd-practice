# 개요

helm 으로 argocd 설치하는 방법을 다룹니다.

## 설치방법

- helm chart 추가

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

- helm chart 릴리즈

```bash
helm upgrade --install argocd argo/argo-cd \
  -n argocd --create-namespace \
  -f my-values.yaml
```

## argocd-server 접속 방법

### 방법1: NodePort

argocd-server를 NodePort로 설정한 경우 브라우저에서 접속합니다.

```bash
http://localhost:{NodePort} # 예시: 30950 http://localhost:30950
```

### 방법2: kubectl port-forward

port-forward로 argocd-server에 접속합니다.

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

브라우저에서 접속합니다.

```bash
http://localhost:8080
```

## admin 비밀번호 조회

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 삭제방법

```bash
helm uninstall -n argocd argocd
```

## EKS에 ArgoCD 설치

- [메뉴얼 바로가기](./eks/)
