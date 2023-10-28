up:
	@kind create cluster --config ./kind-cluster/config.yaml

down:
	@kind delete cluster --name argocd-practice
