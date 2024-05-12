# 개요
Argo CD 예제

<br />

# 실습 환경(옵션)
* [kind cluster 사용](./kind-cluster/)

```bash
# 생성
make up

# 삭제
make down
```

<br />

# 목차
* [kustomize로 argocd 설치](./install_argocd_with_kustomize)
* [helm chart로 argocd 설치](./install_argocd_with_helm/)
* [terraform으로 argocd 설치](./migraiton/terraform/as-is.tf)
* [example-1: hello world - nginx pod, service](./example-1/)
* [example-3: nginx deployment](./example-3/)
* [example-4: prune](./example-4/)
* [example-5: directory Recurse](./example-5/)
* [example-6: failed job](./example-5/)
* [example-8: namespace 예제](./example-8/)
* [argocd-user: 사용자 생성 예제](./argocd-user/)
* [kustomize-helm 예제](./kustomize-helm)
* [self-managed argocd application](./bootstrap/self-managed-applicaiton.yaml)
* [bootstrap applicationset 예제](./bootstrap/bootstrap-applicationset.yaml)
* [argocd application관리(chicken and egg) 문제 해결](./chicken_and_egg/)
* [쿠버네티스 업그레이드 시 (중앙) ArgoCD Migration](./migraiton/)
