# 개요
* ArgoCD에 kubernetes cluster 등록

# 전제조건
* [테스트 환경 구축](../terraform/)이 되어 있어야 함

# 클러스터 등록 방법

1. python mustache 패키지 설치

```sh
pip install chevron
```

2. 파이썬 스크립트 실행해서 클러스터 등록하는 kubernetes secrets생성

```sh
$ python create_kubernetes_secrets.py
$ ls kind-cluster-*.yaml
kind-cluster-a-secrets.yaml kind-cluster-b-secrets.yaml kind-cluster-c-secrets.yaml
```

3. kubernetes secrest를 apply

```sh
KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-a-secrets.yaml
KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-b-secrets.yaml
KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-c-secrets.yaml
```

![](../imgs/argocd_cluster_1.png)

![](../imgs/argocd_cluster_2.png)

# 다음 단계
* [Argocd Project 생성](../argocd_projects/)
