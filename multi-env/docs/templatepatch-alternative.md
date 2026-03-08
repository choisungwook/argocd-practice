# templatePatch를 사용한 대안

## 요약

- `templatePatch`를 사용하면 하나의 ApplicationSet으로 환경별 syncPolicy를 다르게 설정할 수 있다.
- Go 템플릿 문법을 사용하므로 `goTemplate: true` 설정이 필요하다.
- 간결하지만 디버깅이 어렵고 가독성이 떨어지는 단점이 있다.

## templatePatch란?

`templatePatch`는 ApplicationSet의 template에 조건부 패치를 적용하는 기능이다. Go 템플릿 문법으로 파라미터 값에 따라 Application spec의 일부를 변경할 수 있다.

ArgoCD v2.7 이상에서 사용할 수 있다.

## 예제

단일 ApplicationSet으로 dev는 자동 동기화, stage/prod는 수동 동기화를 설정하는 예제이다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-env-templatepatch
  labels:
    app.kubernetes.io/name: multi-env-templatepatch
    app.kubernetes.io/part-of: argocd-applicationset-example
  namespace: argocd
spec:
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  generators:
    - list:
        elements:
          - env: dev
            url: https://kubernetes.default.svc
            namespace: dev
            autoSync: "true"
          - env: stage
            url: https://kubernetes.default.svc
            namespace: stage
            autoSync: "false"
          - env: prod
            url: https://kubernetes.default.svc
            namespace: prod
            autoSync: "false"
  template:
    metadata:
      name: "{{ .env }}-multi-env"
    spec:
      project: default
      source:
        repoURL: https://github.com/choisungwook/argocd-applicationset.git
        targetRevision: main
        path: "multi-env/manifests/apps/{{ .env }}"
      destination:
        server: "{{ .url }}"
        namespace: "{{ .namespace }}"
      syncPolicy:
        syncOptions:
          - CreateNamespace=true
  templatePatch: |
    {{- if eq .autoSync "true" }}
    spec:
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
    {{- end }}
```

핵심은 `autoSync` 파라미터 값에 따라 `templatePatch`가 syncPolicy를 덮어쓰는 것이다. `autoSync: "true"`인 dev만 자동 동기화가 적용되고, stage/prod는 기본 template의 syncPolicy(automated 없음)가 유지된다.

## 장단점

| 항목 | 장점 | 단점 |
|---|---|---|
| 파일 수 | ApplicationSet 1개로 관리 | - |
| 가독성 | - | Go 템플릿 문법이 YAML 안에 섞여 읽기 어려움 |
| 디버깅 | - | templatePatch 오류 시 원인 파악이 어려움 |
| 호환성 | - | ArgoCD v2.7 이상 필요, goTemplate: true 필수 |
| 유지보수 | 환경 추가 시 element만 추가 | 조건이 복잡해지면 templatePatch가 비대해짐 |

## 이 예제에서 분리 방식을 선택한 이유

본 예제에서는 ApplicationSet을 두 개로 분리하는 방식을 사용했다. 이유는 다음과 같다.

- 교육 목적으로 각 파일의 역할이 명확하게 드러난다.
- Go 템플릿 문법 없이도 이해할 수 있다.
- 실무에서도 분리 방식이 더 일반적이다.

## 참고자료

- [ArgoCD templatePatch 공식 문서](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Template/#template-patch)
- [Go 템플릿 문법](https://pkg.go.dev/text/template)
