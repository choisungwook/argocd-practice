# 개요
* EKS에 ArgoCD를 helm chart로 설치

# 선행지식
* ALB controller
* External DNS Controller
* AWS ACM

# 실행방법
* 환경변수 설정

```bash
export ACM_ARN="YOUR_ACM_ARN"
export HOST="YOUR_HOST"
```

* 템플릿 생성

```bash
envsubst < ./values-template.yaml > my-values.yaml
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
