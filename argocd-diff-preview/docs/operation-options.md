# argocd-diff-preview 운영 모드 선택 가이드

## 요약

- argocd-diff-preview는 **Ephemeral Cluster**(임시 클러스터)와 **Pre-installed ArgoCD**(기존 클러스터 연결) 두 가지 모드로 운영할 수 있습니다
- Ephemeral 모드는 설정이 간단하지만 매 실행마다 60-90초의 오버헤드가 발생합니다
- Pre-installed 모드는 약 10초만에 실행되지만, **네트워크 접근**(GitHub Actions runner → ArgoCD 클러스터)을 해결해야 합니다
- private 클러스터(EKS 등)에 연결하려면 **self-hosted runner**가 필요하고, AWS 환경에서는 CodeBuild를 self-hosted runner로 사용하는 방법이 있습니다

## 모드 비교

| 항목 | Ephemeral Cluster (기본) | Pre-installed ArgoCD |
| --- | --- | --- |
| 실행 시간 | 60-90초 + 렌더링 시간 | **약 10초** + 렌더링 시간 |
| 설정 난이도 | 낮음 | 높음 (네트워크, 인증 설정 필요) |
| 클러스터 생성 | 매번 Kind 클러스터 생성/삭제 | 생성하지 않음 |
| Docker socket | 필수 | 바이너리 직접 실행 시 불필요 |
| 인증 정보 | `/secrets` volume mount | 클러스터에 사전 등록 |
| 격리 수준 | 완전 격리 (매번 새 클러스터) | ArgoCD 인스턴스 공유 |

근거 — 공식 문서: *"saves approximately 60–90 seconds per run"*, *"Total execution time: 10s"*

## Ephemeral Cluster 모드

### 동작 방식

매 실행마다 Kind 클러스터를 생성하고 ArgoCD를 Helm으로 설치한 뒤, 렌더링이 끝나면 클러스터를 삭제합니다.

### 언제 사용하는가

- **처음 도입할 때** — 별도의 인프라 설정 없이 바로 사용 가능합니다
- **Application이 적을 때** — 60-90초 오버헤드가 크지 않은 경우입니다
- **완전한 격리가 필요할 때** — 매번 깨끗한 환경에서 실행합니다

### 설정

docker run에 별도 플래그 없이 기본 동작합니다.

```yaml
- name: Generate Diff
  run: |
    docker run \
      --network=host \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v $(pwd)/main:/base-branch \
      -v $(pwd)/pull-request:/target-branch \
      -v $(pwd)/output:/output \
      -e TARGET_BRANCH=${{ github.head_ref }} \
      -e REPO=${{ github.repository }} \
      dagandersen/argocd-diff-preview:latest
```

## Pre-installed ArgoCD 모드

### 동작 방식

기존에 설치된 ArgoCD 클러스터에 kubeconfig 또는 service account로 연결합니다. 클러스터 생성을 건너뛰므로 빠릅니다.

### 핵심 플래그

```bash
--create-cluster=false --argocd-namespace <namespace>
```

### 사전 요구사항

공식 문서 원문:

- *"The default Argo CD project must exist"*
- *"The required secrets for authentication have already been added to the cluster"*

**중요**: 공식 문서에서 production ArgoCD 인스턴스 사용을 권장하지 않습니다. 원문: *"We highly recommend not using your production Argo CD instance for rendering manifests. Instead, install a dedicated Argo CD instance for diff previews."*

### 네트워크 문제: runner가 클러스터에 접근할 수 있는가?

Pre-installed 모드의 핵심 과제는 **GitHub Actions runner에서 ArgoCD 클러스터에 네트워크 접근이 가능해야 한다**는 것입니다.

## 네트워크 시나리오별 설정

### 시나리오 1: Public 클러스터

ArgoCD 클러스터의 API server가 public endpoint로 노출된 경우입니다.

```text
GitHub-hosted runner ──(internet)──▶ Public K8s API server ──▶ ArgoCD
```

**설정 방법:**

kubeconfig를 GitHub Secrets에 저장하고 workflow에서 mount합니다.

```yaml
- name: Setup kubeconfig
  run: |
    mkdir -p ~/.kube
    echo "${{ secrets.KUBECONFIG }}" > ~/.kube/config

- name: Generate Diff
  run: |
    docker run \
      --network=host \
      -v ~/.kube:/root/.kube \
      -v $(pwd)/main:/base-branch \
      -v $(pwd)/pull-request:/target-branch \
      -v $(pwd)/output:/output \
      -e TARGET_BRANCH=${{ github.head_ref }} \
      -e REPO=${{ github.repository }} \
      dagandersen/argocd-diff-preview:latest \
      --create-cluster=false \
      --argocd-namespace=argocd-diff-preview
```

**주의**: kubeconfig에 `aws eks get-token` 같은 ExecConfig를 사용하는 경우, Docker 이미지 안에 해당 바이너리가 없으므로 **바이너리 직접 실행 방식**을 사용해야 합니다. 공식 문서 원문: *"These plugins/binaries are not available inside the Docker image, so you'll need to run argocd-diff-preview as a standalone binary."*

### 시나리오 2: Private 클러스터

ArgoCD 클러스터의 API server가 private network에만 노출된 경우입니다. **GitHub-hosted runner는 접근할 수 없습니다.**

```text
GitHub-hosted runner ──(internet)──✗──▶ Private K8s API server
```

이 경우 **self-hosted runner**를 클러스터와 같은 네트워크에 배치해야 합니다.

```text
Self-hosted runner ──(private network)──▶ Private K8s API server ──▶ ArgoCD
```

## Self-hosted Runner 구성 방법

### 방법 1: Action Runner Controller (ARC)

Kubernetes 클러스터 안에 GitHub Actions runner를 Pod로 실행하는 방식입니다. ArgoCD와 같은 클러스터에 설치하면 네트워크 문제가 없습니다.

공식 문서 원문: *"Running argocd-diff-preview on a self-hosted runner on a cluster that has Argo CD pre-installed combines maximum performance with enhanced security."*

```text
[Kubernetes Cluster]
├── argocd-diff-preview namespace (ArgoCD)
├── arc-systems namespace (ARC controller)
└── arc-runners namespace (Runner Pod)
    └── argocd-diff-preview 실행 ──▶ ArgoCD (같은 클러스터)
```

**장점:**

- 네트워크 문제 없음 (같은 클러스터)
- kubeconfig 관리 불필요 (service account 사용)
- 인증 정보를 GitHub에 저장하지 않아도 됩니다

**workflow에서 `runs-on`을 ARC runner 이름으로 지정합니다.**

```yaml
jobs:
  diff-preview:
    runs-on: argocd-diff-runner  # ARC runner scale set 이름
```

### 방법 2: AWS CodeBuild를 GitHub Actions self-hosted runner로 사용

EKS private 클러스터 환경에서는 **AWS CodeBuild를 GitHub Actions self-hosted runner로 사용**하는 방법이 있습니다. CodeBuild가 EKS와 같은 VPC에 있으면 private API server에 접근할 수 있습니다.

```text
GitHub PR trigger
    │
    ▼
AWS CodeBuild (self-hosted runner, same VPC)
    │
    ▼
EKS Private API server ──▶ ArgoCD (diff 전용)
```

**장점:**

- EKS와 같은 VPC에서 실행되므로 private API server에 접근 가능합니다
- IAM role로 EKS 인증 (`aws eks get-token`)이 자연스럽게 동작합니다
- 별도의 Kubernetes runner Pod 관리가 불필요합니다

**설정 핵심:**

- CodeBuild 프로젝트를 EKS와 같은 VPC의 private subnet에 배치합니다
- CodeBuild에 EKS 접근 권한이 있는 IAM role을 할당합니다
- GitHub에서 CodeBuild를 self-hosted runner로 등록합니다

### CodeBuild self-hosted runner 주의사항

**`runs-on` 라벨을 반드시 분리해야 합니다.** CodeBuild를 self-hosted runner로 등록하면 기본적으로 **모든 GitHub Actions workflow가 CodeBuild에서 실행**될 수 있습니다.

argocd-diff-preview만 CodeBuild에서 실행하고, 나머지 workflow는 GitHub-hosted runner에서 실행하려면 **라벨로 구분**해야 합니다.

```yaml
# argocd-diff-preview workflow — CodeBuild에서 실행
jobs:
  diff:
    runs-on: codebuild-argocd-diff  # CodeBuild runner 전용 라벨
```

```yaml
# 다른 workflow (lint, test 등) — GitHub-hosted runner에서 실행
jobs:
  test:
    runs-on: ubuntu-latest  # 기본 GitHub-hosted runner
```

**라벨을 구분하지 않으면 발생하는 문제:**

- 단순한 lint, test workflow도 CodeBuild에서 실행되어 **비용이 증가**합니다
- CodeBuild 시작 시간(cold start)으로 인해 **간단한 job이 느려집니다**
- CodeBuild의 동시 실행 제한에 걸려 **다른 workflow가 대기**할 수 있습니다

**비용 관점:**

| runner | 비용 모델 |
| --- | --- |
| GitHub-hosted (`ubuntu-latest`) | GitHub Actions 무료 분(public repo 무제한, private repo 2000분/월) |
| CodeBuild self-hosted | **AWS CodeBuild 요금** (분당 과금, 인스턴스 타입별 상이) |

단순 CI job은 GitHub-hosted runner에서 실행하고, private 클러스터 접근이 필요한 argocd-diff-preview만 CodeBuild에서 실행하는 것이 비용 효율적입니다.

## 운영 모드 선택 가이드

| 상황 | 권장 모드 | 이유 |
| --- | --- | --- |
| 처음 도입, PoC | Ephemeral | 설정 간단 |
| Application 적음 (10개 이하) | Ephemeral | 60-90초 오버헤드 감수 가능 |
| Application 많음, 속도 중요 | Pre-installed | 10초 실행 |
| Public 클러스터 | Pre-installed + GitHub-hosted runner | kubeconfig만 Secrets에 저장 |
| Private 클러스터 (EKS 등) | Pre-installed + self-hosted runner | ARC 또는 CodeBuild |
| AWS EKS private + IAM 인증 | Pre-installed + CodeBuild runner | IAM role로 EKS 인증 자연스러움 |

## 참고자료

- <https://dag-andersen.github.io/argocd-diff-preview/how-it-works/>
- <https://dag-andersen.github.io/argocd-diff-preview/reusing-clusters/connecting/>
- <https://dag-andersen.github.io/argocd-diff-preview/reusing-clusters/self-hosted-gh-runner/>
- <https://dag-andersen.github.io/argocd-diff-preview/getting-started/self-hosted-gh-runner/>
