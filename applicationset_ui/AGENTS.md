# Problem of argocd application

2026년 3월 기준으로 Argo CD web dashboard에서 왼쪽 메뉴에 applicationset을 보는게 가능할까? web_fetch tools를 사용하여 아래 참고자료를 보고 판단하고, 가능하다면 실습자료를 만드세요.

- 참고자료
  - https://www.linkedin.com/posts/argoproj_heads-up-argo-cd-users-applicationsets-activity-7422399925180862465-wORP?utm_source=share&utm_medium=member_desktop&rcm=ACoAAB3jNXwBQaX2ciprQbfJ2o33vJjPd_arJ5E
  - https://docs.akuity.io/argocd/managing-instances/settings/extensions/applicationset-extension/

## 실습환경

- 로컬에서 kind cluster를 사용하여 쿠버네티스를 생성한다.
- Argo CD는 helm chart를 사용한다.

## agent skills

- 문서작성은 akbun style skills를 사용한다.
