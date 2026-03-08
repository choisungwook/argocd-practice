# Multi-Environment ApplicationSet

ApplicationSet으로 dev, stage, prod 환경을 관리하는 예제이다. dev 환경만 자동 동기화되고, stage/prod 환경은 수동 승인이 필요하다.

## 문서

| 문서 | 설명 |
|---|---|
| [수동 동기화가 필요한 이유](./docs/why-manual-sync.md) | Progressive Delivery 개념과 동기화 정책 분리 |
| [templatePatch 대안](./docs/templatepatch-alternative.md) | 단일 ApplicationSet으로 구현하는 방법 |

## 아키텍처

이 예제는 두 개의 ApplicationSet으로 구성된다.

| ApplicationSet | 대상 환경 | 동기화 정책 |
|---|---|---|
| `multi-env-dev` | dev | 자동 동기화 (prune + selfHeal) |
| `multi-env-stage-prod` | stage, prod | 수동 동기화 |

배포 흐름은 다음과 같다.

```
Git Push → dev 자동 배포 → dev 검증 → stage 수동 Sync → stage 검증 → prod 수동 Sync
```

핵심은 ApplicationSet의 template이 모든 Application에 동일하게 적용되므로, syncPolicy를 분리하려면 ApplicationSet 자체를 나눠야 한다는 것이다.

## 실습

실습 manifest는 [manifests](./manifests/) 디렉터리에 있다.

### ApplicationSet 배포

dev 환경 ApplicationSet을 배포하는 명령어이다.

```bash
kubectl apply -f manifests/applicationset-dev.yaml
```

stage, prod 환경 ApplicationSet을 배포하는 명령어이다.

```bash
kubectl apply -f manifests/applicationset-stage-prod.yaml
```

### 배포 확인

ApplicationSet 목록을 확인하는 명령어이다.

```bash
kubectl get applicationset -n argocd
```

생성된 Application 목록을 확인하는 명령어이다.

```bash
kubectl get app -n argocd
```

dev는 자동 동기화되어 `Synced` 상태이고, stage/prod는 `OutOfSync` 상태인 것을 확인할 수 있다.

### 수동 동기화

stage 환경을 수동으로 동기화하는 명령어이다.

```bash
argocd app sync stage-multi-env
```

prod 환경을 수동으로 동기화하는 명령어이다.

```bash
argocd app sync prod-multi-env
```

ArgoCD UI에서도 해당 Application의 `SYNC` 버튼을 클릭하여 수동 동기화할 수 있다.

## 정리

배포한 리소스를 삭제하는 명령어이다.

```bash
kubectl delete -f manifests/applicationset-dev.yaml
kubectl delete -f manifests/applicationset-stage-prod.yaml
```
