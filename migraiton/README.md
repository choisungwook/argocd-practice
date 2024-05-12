# 1. 개요
* ArgoCD migration 진행


# 2. AS-IS kind클러스터와 ArgoCD 생성

* AS-IS kind클러스터와 A,B,C kind클러스터 3대가 생성
* AS-IS kind 클러스터에는 ArgoCD helm chart가 릴리즈 되어 있음

```sh
1. cd terraform
2. terrafprm apply
```

# 3. ArgoCD에 A,B,C kind 클러스터 등록

* 2번과정에서 terraform으로 kind cluster가 생성되어야 있어야 합니다.

```sh
1. cd argocd_clusters

2. pip install chevron

3. python create_kubernetes_secrets

# helm values 생성하는 스크립트(전제조건, A,B,C kind kubeconfig가 생성되어 있어야 함)
4. kubernetes secrest를 apply
KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-a-secrets.yaml
KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-b-secrets.yaml
KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-c-secrets.yaml
```

![](./imgs/argocd_cluster_1.png)

![](./imgs/argocd_cluster_2.png)

# 4. ArgoCD Project 생성

* 2번과정에서 terraform으로 kind cluster가 생성되어야 있어야 합니다.

```sh
1. cd argocd_projects

2. kubernetes secrest를 apply
KUBECONFIG=../terraform/as-is-config kubectl apply -f ./cluster_A/
KUBECONFIG=../terraform/as-is-config kubectl apply -f ./cluster_B/
KUBECONFIG=../terraform/as-is-config kubectl apply -f ./cluster_C/
```


![](./imgs/argocd_project_1.png)

![](./imgs/argocd_project_2.png)
