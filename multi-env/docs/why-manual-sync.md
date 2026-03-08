# 수동 동기화(Manual Sync)가 필요한 이유

## 요약

- ApplicationSet으로 멀티 환경을 관리할 때, 모든 환경을 자동 동기화하면 검증되지 않은 변경이 프로덕션에 바로 반영된다.
- dev는 자동 동기화, stage/prod는 수동 동기화로 분리하면 Progressive Delivery를 구현할 수 있다.

## 목차

- [Progressive Delivery란?](#progressive-delivery란)
- [자동 동기화 vs 수동 동기화](#자동-동기화-vs-수동-동기화)
- [왜 stage/prod는 수동 동기화인가?](#왜-stageprod는-수동-동기화인가)
- [ApplicationSet에서 동기화 정책 분리](#applicationset에서-동기화-정책-분리)

## Progressive Delivery란?

Progressive Delivery는 변경 사항을 한 번에 모든 환경에 배포하지 않고, 단계적으로 배포하는 전략이다.

일반적인 순서는 다음과 같다.

```
dev (자동 배포) → stage (수동 승인 후 배포) → prod (수동 승인 후 배포)
```

각 단계에서 충분히 검증한 뒤 다음 단계로 진행하므로, 프로덕션 장애 위험을 줄일 수 있다.

## 자동 동기화 vs 수동 동기화

| 항목 | 자동 동기화 (Automated Sync) | 수동 동기화 (Manual Sync) |
|---|---|---|
| 설정 | `syncPolicy.automated: { prune: true, selfHeal: true }` | `syncPolicy`에 `automated` 없음 |
| 동작 | Git 변경 감지 시 즉시 배포 | OutOfSync 상태 유지, 수동 트리거 필요 |
| 적합한 환경 | dev (빠른 반복 개발) | stage, prod (안정성 우선) |
| 롤백 | selfHeal로 자동 복구 | 수동으로 이전 버전 sync |

## 왜 stage/prod는 수동 동기화인가?

자동 동기화가 모든 환경에 적용되면 다음 문제가 발생한다.

- **검증 없는 배포**: dev에서 충분히 테스트하지 않은 변경이 프로덕션에 바로 반영된다.
- **장애 전파**: dev에서 발생한 문제가 stage, prod로 동시에 확산된다.
- **감사(Audit) 부재**: 누가, 언제 프로덕션 배포를 승인했는지 추적할 수 없다.

수동 동기화를 사용하면 다음을 보장할 수 있다.

- dev에서 충분히 검증한 변경만 stage로 승격한다.
- stage에서 검증한 변경만 prod로 승격한다.
- ArgoCD UI 또는 CLI에서 명시적으로 sync를 트리거하므로 승인 기록이 남는다.

## ApplicationSet에서 동기화 정책 분리

ApplicationSet의 `template`은 모든 생성된 Application에 동일하게 적용된다. 따라서 하나의 ApplicationSet에서 환경별로 다른 syncPolicy를 설정할 수 없다.

해결 방법은 ApplicationSet을 분리하는 것이다.

dev 환경 ApplicationSet 예시이다.

```yaml
# applicationset-dev.yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

stage/prod 환경 ApplicationSet 예시이다.

```yaml
# applicationset-stage-prod.yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true
  # automated 없음 → 수동 sync 필요
```

단일 ApplicationSet으로 구현하고 싶다면 `templatePatch`를 사용할 수 있다. 자세한 내용은 [templatePatch 대안](./templatepatch-alternative.md) 문서를 참고한다.

## 참고자료

- [ArgoCD Sync Policy 공식 문서](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/)
- [ArgoCD ApplicationSet 공식 문서](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/)
