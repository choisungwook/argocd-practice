# Public Repo 설정

## 요약

- public repository에서 argocd-diff-preview를 사용하는 GitHub Actions workflow를 설정합니다
- 별도의 인증 정보 없이 `GITHUB_TOKEN`만으로 동작합니다

## 사전 준비

- GitHub Actions가 활성화된 repository
- repository에 `kind: Application` 또는 `kind: ApplicationSet` YAML 파일이 존재해야 합니다

## GitHub Actions workflow

`.github/workflows/argocd-diff-preview.yaml` 파일을 생성합니다.

```yaml
name: ArgoCD Diff Preview
on:
  pull_request:
    branches: [main]
    paths:
      - 'chicken_and_egg/**'

jobs:
  diff:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.head_ref }}
          path: pull-request

      - uses: actions/checkout@v4
        with:
          ref: main
          path: main

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

      - name: Post diff comment
        run: |
          gh pr comment ${{ github.event.number }} \
            --repo ${{ github.repository }} \
            --body-file output/diff.md --edit-last || \
          gh pr comment ${{ github.event.number }} \
            --repo ${{ github.repository }} \
            --body-file output/diff.md
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## workflow 설명

| 항목 | 설명 |
| --- | --- |
| `on.pull_request.paths` | `chicken_and_egg/` 디렉터리 변경 시에만 동작합니다 |
| `permissions.pull-requests: write` | PR comment 작성 권한입니다 |
| `actions/checkout` (2번) | PR 소스 브랜치(`head_ref`)와 base 브랜치(main)를 각각 checkout합니다 |
| `docker run` | argocd-diff-preview를 실행합니다 |
| `gh pr comment --edit-last` | 기존 comment를 업데이트하고, 없으면 새로 생성합니다 |

## Docker volume mount 설명

| Mount | 설명 |
| --- | --- |
| `/var/run/docker.sock` | Kind 클러스터 생성을 위한 Docker socket입니다 |
| `/base-branch` | base 브랜치 checkout 경로입니다 |
| `/target-branch` | PR 브랜치 checkout 경로입니다 |
| `/output` | diff 결과물 출력 경로입니다 |

## 주요 옵션

환경 변수로 동작을 제어할 수 있습니다. docker run의 `-e` 플래그로 전달합니다.

| 환경 변수 | 기본값 | 설명 |
| --- | --- | --- |
| `CREATE_CLUSTER` | `true` | 임시 클러스터 생성 여부입니다 |
| `CLUSTER` | `auto` | 클러스터 도구: `kind`, `k3d`, `minikube`입니다 |
| `TIMEOUT` | `180` | 렌더링 타임아웃 (초)입니다 |
| `DIFF_IGNORE` | - | diff에서 무시할 라인 (정규식)입니다 |
| `FILE_REGEX` | - | 파일 경로 필터 (정규식)입니다 |
| `MAX_DIFF_LENGTH` | `65536` | Markdown 최대 글자 수입니다 |

## 참고자료

- <https://github.com/dag-andersen/argocd-diff-preview>
