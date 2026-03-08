# Pull Request Generator 설정 방법

## 요약

* Pull Request Generator는 `generators` 필드에 Git 호스팅 서비스 정보와 저장소 정보를 설정합니다.
* GitHub를 예시로 설명하며, Token 인증과 GitHub App 인증 두 가지 방식을 지원합니다.
* Label 필터를 사용하여 특정 PR만 대상으로 지정할 수 있습니다.

## 목차

* [기본 구조](#기본-구조)
* [GitHub 설정](#github-설정)
* [인증 설정](#인증-설정)
* [Label 필터](#label-필터)
* [Template 작성](#template-작성)
* [주의사항](#주의사항)
* [참고자료](#참고자료)

## 기본 구조

Pull Request Generator의 기본 구조는 다음과 같습니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: pr-generator-example
  namespace: argocd
spec:
  generators:
    - pullRequest:
        github:
          owner: <GitHub org 또는 사용자 이름>
          repo: <저장소 이름>
          tokenRef:
            secretName: github-token
            key: token
  template:
    # ... Application 템플릿
```

`pullRequest` 필드 아래에 Git 호스팅 서비스 설정을 추가합니다.

## GitHub 설정

GitHub를 사용하는 경우 `github` 필드를 설정합니다.

```yaml
generators:
  - pullRequest:
      github:
        owner: choisungwook
        repo: argocd-applicationset
        tokenRef:
          secretName: github-token
          key: token
```

| 필드 | 설명 | 필수 |
|---|---|---|
| `owner` | GitHub Organization 또는 사용자 이름 | O |
| `repo` | 저장소 이름 | O |
| `tokenRef` | 인증 토큰 Secret 참조 | O (private repo) |
| `labels` | PR 라벨 필터 | X |
| `api` | GitHub Enterprise API URL | X |

## 인증 설정

Private 저장소에 접근하려면 인증이 필요합니다. GitHub Personal Access Token(PAT)을 Kubernetes Secret으로 생성합니다.

Secret을 생성하는 명령어입니다.

```bash
kubectl create secret generic github-token \
  --namespace argocd \
  --from-literal=token=ghp_xxxxxxxxxxxxxxxxxxxx
```

ApplicationSet에서 Secret을 참조하는 설정입니다.

```yaml
tokenRef:
  secretName: github-token
  key: token
```

**Token에는 최소한 `repo` 권한이 필요합니다.** Public 저장소라면 `tokenRef`를 생략할 수 있습니다.

## Label 필터

모든 PR에 대해 preview 환경을 만들 필요는 없습니다. Label 필터를 사용하면 특정 라벨이 붙은 PR만 대상으로 지정할 수 있습니다.

```yaml
generators:
  - pullRequest:
      github:
        owner: choisungwook
        repo: argocd-applicationset
        labels:
          - preview
        tokenRef:
          secretName: github-token
          key: token
```

위 설정은 `preview` 라벨이 붙은 PR만 Application을 생성합니다.

## Template 작성

Pull Request Generator가 제공하는 파라미터를 Template에서 활용하는 예제입니다.

```yaml
template:
  metadata:
    name: 'pr-{{number}}-{{branch_slug}}'
  spec:
    project: default
    source:
      repoURL: https://github.com/choisungwook/argocd-applicationset.git
      targetRevision: '{{head_sha}}'
      path: example-3
    destination:
      server: https://kubernetes.default.svc
      namespace: 'pr-{{number}}'
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
```

핵심 포인트입니다.

* `name`: PR 번호와 브랜치 이름을 조합하여 고유한 Application 이름을 만듭니다.
* `targetRevision`: PR의 최신 커밋(`head_sha`)을 배포 대상으로 설정합니다.
* `namespace`: PR 번호를 활용하여 격리된 namespace를 만듭니다.
* `CreateNamespace=true`: namespace가 없으면 자동으로 생성합니다.

## 주의사항

Pull Request Generator를 사용할 때 헷갈리면 안되는 점이 있습니다.

1. **Polling 주기**: ApplicationSet Controller는 기본 30분 주기로 PR 목록을 확인합니다. `requeueAfterSeconds` 필드로 주기를 조정할 수 있습니다.
2. **리소스 정리**: PR이 닫히거나 머지되면 Application이 자동으로 삭제됩니다. 단, `syncPolicy.automated.prune: true` 설정이 필요합니다.
3. **Token 권한**: Private 저장소는 반드시 `repo` 권한이 있는 Token이 필요합니다.
4. **브랜치 이름 제약**: `branch_slug`를 사용하면 특수문자가 하이픈으로 변환됩니다. Kubernetes 리소스 이름 규칙에 맞출 때 유용합니다.

## 참고자료

* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/>
* <https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens>
