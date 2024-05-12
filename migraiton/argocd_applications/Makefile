create-to-asis:
	@KUBECONFIG=../terraform/as-is-config kubectl apply -f as-is/
	@KUBECONFIG=../terraform/as-is-config kubectl apply -f cluster_A/
	@KUBECONFIG=../terraform/as-is-config kubectl apply -f cluster_B/
	@KUBECONFIG=../terraform/as-is-config kubectl apply -f cluster_C/

create-to-tobe:
	@KUBECONFIG=../terraform/to-be-config kubectl apply -f cluster_A/
	@KUBECONFIG=../terraform/to-be-config kubectl apply -f cluster_B/
	@KUBECONFIG=../terraform/to-be-config kubectl apply -f cluster_C/

delete-to-asis:
	@KUBECONFIG=../terraform/as-is-config kubectl delete -f as-is/
	@KUBECONFIG=../terraform/as-is-config kubectl delete -f cluster_A/
	@KUBECONFIG=../terraform/as-is-config kubectl delete -f cluster_B/
	@KUBECONFIG=../terraform/as-is-config kubectl delete -f cluster_C/

delete-to-tobe:
	@KUBECONFIG=../terraform/to-be-config kubectl delete -f cluster_A/
	@KUBECONFIG=../terraform/to-be-config kubectl delete -f cluster_B/
	@KUBECONFIG=../terraform/to-be-config kubectl delete -f cluster_C/
