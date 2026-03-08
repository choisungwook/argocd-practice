# delete-applicationset

ApplicationSet을 삭제(`kubectl delete applicationset`)하면 어떤 일이 발생하는지 비교하는 예제입니다.

## 예제 인덱스

| 파일 | 설명 | ApplicationSet 삭제 시 |
|---|---|---|
| `without-preserve.yaml` | `preserveResourcesOnDeletion` 미설정 | Application 삭제 + K8s 리소스 삭제 |
| `with-preserve.yaml` | `preserveResourcesOnDeletion: true` 설정 | Application 삭제 + **K8s 리소스 보존** |

## 삭제 동작 비교

`preserveResourcesOnDeletion` 설정 유무에 따른 차이입니다.

```
[without-preserve] kubectl delete applicationset dangerous-no-preserve -n argocd
  → Application "dev-cluster" 삭제
  → Application "prod-cluster" 삭제
  → dev-cluster의 Deployment, Service 등 K8s 리소스 삭제
  → prod-cluster의 Deployment, Service 등 K8s 리소스 삭제
  → 결과: 전부 삭제됨

[with-preserve] kubectl delete applicationset safe-with-preserve -n argocd
  → Application "dev-cluster" 삭제
  → Application "prod-cluster" 삭제
  → dev-cluster의 K8s 리소스는 그대로 유지
  → prod-cluster의 K8s 리소스는 그대로 유지
  → 결과: Application만 삭제, K8s 리소스는 보존
```

**주의**: `preserveResourcesOnDeletion: true`를 설정해도 **Application 오브젝트 자체는 삭제**됩니다. 보존되는 것은 Application이 관리하던 K8s 리소스(Deployment, Service 등)입니다.
