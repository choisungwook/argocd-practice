create-secrets:
	@python create_kubernetes_secrets.py

create-to-asis: create-secrets
	@KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-a-secrets.yaml
	@KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-b-secrets.yaml
	@KUBECONFIG=../terraform/as-is-config kubectl apply -f kind-cluster-c-secrets.yaml

create-to-tobe: create-secrets
	@KUBECONFIG=../terraform/to-be-config kubectl apply -f kind-cluster-a-secrets.yaml
	@KUBECONFIG=../terraform/to-be-config kubectl apply -f kind-cluster-b-secrets.yaml
	@KUBECONFIG=../terraform/to-be-config kubectl apply -f kind-cluster-c-secrets.yaml
