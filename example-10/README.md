# ApplicationSet Pull Request Generator

ArgoCD ApplicationSet Pull Request Generator의 개념과 실습 예제입니다.

## 문서

| 문서 | 설명 |
|---|---|
| [Pull Request Generator란?](./docs/what-is-pr-generator.md) | PR Generator 개념과 동작 원리 |
| [설정 방법](./docs/configuration.md) | GitHub 설정, 인증, Label 필터, Template 작성 |
| [한계와 주의사항](./docs/limits.md) | API 장애 시 Application 삭제 위험과 방어 방법 |

## 사전 준비

GitHub Personal Access Token이 필요합니다. Token을 Secret으로 생성하는 명령어입니다.

```bash
kubectl create secret generic github-token \
  --namespace argocd \
  --from-literal=token=ghp_xxxxxxxxxxxxxxxxxxxx
```

## 실습

실습 manifest는 [manifests](./manifests/) 디렉터리에 있습니다. `basic/`은 안전한 예제, `dangerous/`는 위험한 설정 예제입니다.
