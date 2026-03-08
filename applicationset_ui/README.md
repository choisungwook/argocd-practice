# Argo CD ApplicationSet UI 조사

## 요약

- 2026년 3월 기준, 오픈소스 Argo CD v3.3.2에서는 **왼쪽 메뉴에 ApplicationSet 항목이 없음**
- v3.3.0의 `appset ui support` 커밋은 내부 코드 레벨의 추상화 레이어일 뿐, UI 메뉴로 노출되지 않음
- **ApplicationSet UI는 Akuity Platform의 상용 extension에서만 제공**

## 목차

- [배경](#배경)
- [조사 결과](#조사-결과)
- [결론](#결론)
- [참고자료](#참고자료)

## 배경

Argo CD web dashboard에서 ApplicationSet을 왼쪽 메뉴에서 직접 확인할 수 있는지 조사했습니다.

기존에는 ApplicationSet을 YAML로만 관리하고, UI에서는 생성된 Application만 볼 수 있었습니다. **ApplicationSet 자체를 UI에서 시각화하고 관리하는 기능은 오랫동안 커뮤니티에서 요청받아온 기능입니다.**

## 조사 결과

2026년 3월 기준, 오픈소스 Argo CD에서는 ApplicationSet을 UI로 관리할 수 없습니다. ApplicationSet UI가 필요한 경우 Akuity Platform을 사용해야 합니다.

| 항목 | 오픈소스 Argo CD v3.3.x | Akuity Platform |
| --- | --- | --- |
| ApplicationSet UI 메뉴 | 없음 | 있음 (Extension 설치 필요) |
| 비용 | 무료 | 상용 |

## 조사 상세 내용

### Argo Project 공식 발표 (2026년 1월)

Argo Project는 2026년 1월 28일 LinkedIn에서 "ApplicationSets are coming to the Argo CD UI"를 발표했습니다. Peter Jiang이 개발을 주도하고 있으며, 초기 mock-up이 공개되었습니다.

### Argo CD v3.3.2 실제 확인 (2026년 3월)

Argo CD v3.3.2를 kind cluster에 설치하여 확인한 결과, **왼쪽 메뉴에 ApplicationSet 항목이 존재하지 않습니다.** 이 커밋은 향후 UI 기능을 위한 내부 코드 추상화 레이어일 뿐입니다. v3.3.0 릴리스에 다음 커밋이 포함되었지만, 실제 UI에 반영되지 않았습니다.

```text
feat(ui): implement abstraction layer for appset ui support (#24916) - @pjiang-dev
```

### Akuity Platform (상용)

Akuity Platform에서는 ApplicationSet extension을 제공합니다.

- Full CRUD Management (생성, 조회, 수정, 삭제)
- Status Visualization (상태 시각화)
- Live Previews (배포 전 미리보기)

Settings > Extensions > ApplicationSet extension에서 설치할 수 있습니다. **오픈소스 Argo CD에서는 이 extension을 사용할 수 없습니다.**

## 참고자료

- <https://www.linkedin.com/posts/argoproj_heads-up-argo-cd-users-applicationsets-activity-7422399925180862465-wORP>
- <https://docs.akuity.io/argocd/managing-instances/settings/extensions/applicationset-extension/>
- <https://github.com/argoproj/argo-cd/releases/tag/v3.3.0>
- <https://github.com/argoproj/argo-cd/pull/24916>
