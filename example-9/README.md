# ApplicationSet

ArgoCD ApplicationSet의 개념과 실습 예제입니다.

## 문서

| 문서 | 설명 |
|---|---|
| [ApplicationSet이란?](./docs/what-is-applicationset.md) | ApplicationSet 개념과 동작 원리 |
| [Generator 종류](./docs/generators-overview.md) | Generator 종류와 선택 기준 |
| [Template 구조](./docs/template.md) | Template 구조와 파라미터 치환 |

## 실습

실습 manifest는 [manifests](./manifests/) 디렉터리에 있습니다.

List Generator 예제를 배포하는 명령어입니다.

```bash
kubectl apply -f manifests/list-generator.yaml
```

배포 확인 명령어입니다.

```bash
kubectl get applicationset -n argocd
```
