# GitHub Actions에서 argocd-diff-preview 한계 및 주의사항

## 요약

- argocd-diff-preview는 GitHub Actions runner 위에서 Docker container로 실행됩니다
- 내부적으로 Kind 클러스터를 생성하므로 **Docker socket mount가 필수**이고 **runner 리소스를 많이 소비**합니다
- 기본적으로 **모든 Application을 렌더링**합니다. `AUTO_DETECT_FILES_CHANGED=true`를 설정하면 변경된 Application만 렌더링합니다
- live state가 아닌 **desired state vs desired state 비교**이므로 실제 클러스터 상태는 반영하지 않습니다
- public repository에서 외부 fork PR이 올라오면 `GITHUB_TOKEN`이 read-only이고 secrets가 제공되지 않아 `gh pr comment` 등 쓰기 권한이 필요한 단계가 실패합니다. 이 문서의 기본 동작 범위는 **동일 repository 내 브랜치에서 생성된 PR**을 대상으로 합니다

## 렌더링이란

여기서 "렌더링"이란 ArgoCD가 Helm/Kustomize 템플릿을 **최종 Kubernetes manifest로 변환**하는 것을 의미합니다. 내부적으로 `argocd app manifests <app-name>` CLI 명령어를 사용하여 렌더링된 YAML을 추출합니다.

동작 순서:

1. `kubectl apply`로 패치된 Application을 임시 ArgoCD에 등록
2. ArgoCD가 Application을 **OutOfSync 상태로 렌더링** (실제 배포는 하지 않음, syncPolicy를 제거했기 때문)
3. `argocd app manifests <app-name>`으로 렌더링된 manifest 추출

근거 — 공식 문서 Step 10: *"Uses argocd app manifests to retrieve fully-rendered YAML"*

## 렌더링 범위

### 기본 동작: 전체 Application 렌더링

기본적으로 base 브랜치와 target 브랜치의 **모든 Application/ApplicationSet을 전부 렌더링**합니다. Application이 10개면 양쪽 합쳐 20번 렌더링합니다. Application이 많을수록 시간이 오래 걸립니다.

### 변경된 Application만 렌더링하는 방법

`AUTO_DETECT_FILES_CHANGED=true`를 설정하면 PR에서 **변경된 파일에 영향받는 Application만 렌더링**합니다.

docker run에 환경 변수를 추가합니다.

```bash
-e AUTO_DETECT_FILES_CHANGED=true
```

이 옵션은 Application 수가 많은 환경에서 **실행 시간을 크게 줄여줍니다.** 다만, Application 간 의존성이 있는 경우 (예: shared values 파일 변경) 영향받는 Application을 놓칠 수 있습니다.

### 기타 필터링 방법

| 방법 | 환경 변수 | 설명 |
| --- | --- | --- |
| 파일 경로 필터 | `FILE_REGEX` | 특정 경로의 Application만 대상. 예: `chicken_and_egg/.*` |
| label selector | `SELECTOR` | Application label로 필터링. 예: `team=platform` |
| annotation | Application YAML에 추가 | `argocd-diff-preview/watch-pattern` annotation 사용 |

## GitHub Actions runner 제약

### Docker socket 필수

argocd-diff-preview는 Docker container 안에서 Kind 클러스터를 생성합니다. `/var/run/docker.sock` volume mount가 반드시 필요합니다.

**동작하지 않는 경우:**

- self-hosted runner에서 Docker socket 권한이 없는 경우
- 보안 정책으로 `/var/run/docker.sock` mount가 차단된 경우
- container-based runner (GitHub Actions의 `container:` 옵션 사용 시)

### runner 리소스 소비

ephemeral 모드에서 Kind 클러스터 + ArgoCD를 실행하므로 **CPU/메모리를 많이 사용**합니다.

| 항목 | 예상 소비량 |
| --- | --- |
| 메모리 | 2-4GB (ArgoCD + Kind) |
| 디스크 | Docker image pull로 1-2GB |
| 시간 | 최소 60-90초 (클러스터 생성 + ArgoCD 설치) |

`ubuntu-latest` runner는 7GB 메모리를 제공하므로 동작하지만, 다른 무거운 job과 동시에 실행하면 리소스 부족이 발생할 수 있습니다.

### 실행 시간

PR을 자주 push하면 workflow 실행이 쌓입니다. **GitHub Actions workflow 파일**(`.github/workflows/argocd-diff-preview.yaml`)에 `concurrency` 설정을 추가하면 동일 PR에 대해 이전 실행을 자동 취소할 수 있습니다.

```yaml
# .github/workflows/argocd-diff-preview.yaml의 최상위 레벨에 추가
name: ArgoCD Diff Preview
on:
  pull_request:
    branches: [main]

concurrency:                                      # 여기에 설정
  group: argocd-diff-${{ github.event.number }}
  cancel-in-progress: true

jobs:
  diff:
    runs-on: ubuntu-latest
    # ...
```

## 렌더링 실패 케이스

### CRD에 의존하는 Application

임시 Kind 클러스터에는 기본 Kubernetes CRD만 존재합니다. Application이 CRD에 의존하면 렌더링이 실패합니다.

실패하는 예시:

- Istio VirtualService, Gateway
- Prometheus ServiceMonitor, PrometheusRule
- cert-manager Certificate, ClusterIssuer

해결: ArgoCD helm values에 CRD를 설치하는 설정을 추가합니다.

### Config Management Plugin (CMP)

CMP를 사용하는 Application은 argocd-diff-preview의 ArgoCD helm values에 동일한 CMP 설정을 추가해야 합니다.

### 외부 Helm chart 다운로드

Application이 외부 Helm repository(예: bitnami, prometheus-community)를 참조하면 chart 다운로드 시간이 추가됩니다. OCI registry의 대용량 chart는 타임아웃 위험이 높습니다.

## 타임아웃

기본 타임아웃은 **180초**입니다. Application이 OutOfSync 상태가 될 때까지 대기합니다.

타임아웃이 발생하는 상황:

- Application 수가 많은 경우
- 외부 Helm chart 다운로드가 느린 경우
- CRD 누락으로 렌더링이 멈춘 경우

타임아웃을 늘리려면 환경 변수를 조정합니다.

```bash
-e TIMEOUT=300
```

## PR comment 크기 제한

GitHub PR comment에는 **65,535자 제한**이 있습니다. diff가 이보다 크면 comment 작성이 실패합니다.

대응 방법:

- `MAX_DIFF_LENGTH` 환경 변수로 Markdown 출력 길이를 제한합니다
- `FILE_REGEX`나 `AUTO_DETECT_FILES_CHANGED=true`로 대상 Application을 줄입니다
- diff가 너무 큰 경우 `diff.html`을 GitHub Actions artifact로 업로드합니다

## Private repo 주의사항

### GITHUB_TOKEN 범위

`GITHUB_TOKEN`은 현재 repository에 대한 권한만 가집니다. **다른 repository의 Helm chart나 Application을 참조하면 별도의 PAT(Personal Access Token)이 필요**합니다.

### Private Helm OCI registry

private Helm OCI registry를 사용하면 repo 인증과 별도로 **registry 인증 Secret**도 `/secrets`에 추가해야 합니다.

## 참고자료

- <https://github.com/dag-andersen/argocd-diff-preview>
