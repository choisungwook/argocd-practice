# git-generator

멀티 클러스터 환경에서 Application 생성을 자동화하는 예제입니다. `create-update` 전략으로 삭제를 금지합니다.

## 예제 인덱스

| 파일 | 설명 | 사용 시점 |
|---|---|---|
| `git-directory-generator.yaml` | 디렉터리 구조 기반 Application 생성 | 단일 클러스터, 디렉터리 = Application |
| `git-file-generator.yaml` | config.json 파일 기반 Application 생성 | 멀티 클러스터, cluster server URL 필요 시 |

## Git Directory Generator

repo의 디렉터리 구조를 스캔하여 Application을 생성합니다.

```
repo/
└── clusters/
    ├── app-a/          → Application "app-a" 생성
    │   └── deployment.yaml
    ├── app-b/          → Application "app-b" 생성
    │   └── deployment.yaml
    └── app-c/          → Application "app-c" 생성
        └── deployment.yaml
```

디렉터리를 추가하면 Application이 자동 생성됩니다. 단, `destination.server`가 고정이므로 **단일 클러스터**에 적합합니다.

## Git File Generator

각 디렉터리의 `config.json` 파일에서 cluster 정보를 읽어 Application을 생성합니다. **멀티 클러스터에 적합합니다.**

```
repo/
└── clusters/
    ├── dev-cluster/
    │   └── config.json     → dev cluster에 Application 생성
    ├── staging-cluster/
    │   └── config.json     → staging cluster에 Application 생성
    └── prod-cluster/
        └── config.json     → prod cluster에 Application 생성
```

config.json 예시입니다.

```json
{
  "cluster": {
    "name": "dev-cluster",
    "server": "https://10.0.0.1:6443",
    "namespace": "default",
    "environment": "dev",
    "manifestPath": "clusters/dev-cluster/manifests"
  }
}
```

사전 조건으로 각 클러스터가 ArgoCD에 등록되어 있어야 합니다(`argocd cluster add`).
