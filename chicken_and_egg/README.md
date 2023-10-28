# 개요
* argocd(또는 gitops)에서 겪는 argocd application관리 문제에 대한 예제

# argocd application 관리 문제
* argocd application을 누군가 수동으로 매번 생성,수정,삭제해야 하는 문제를 가지고 있다. 이 문제를 gitops chicken and egg(닭이 먼저냐, 달걀이 먼저냐)라고 부른다.
* 이 예제는 bootstrap과정에서 디렉터리 구조를 설정하여 수동으로 argocd application을 관리하는 문제를 해결한다.

# 해결 방법
* 디렉터리 구조는 [bootstrap과정](../bootstrap/apps-applicationset.yaml)에서 최초 한번 해야 한다.
* bootstrap과정에서 argocd appliation을 관리하는 argocd application을 생성한다. 즉 app of apps패턴을 생성한다.
* app of apps패턴을 [argocd applicationset](../bootstrap/apps-applicationset.yaml)으로 생성했다.
* 사용자는 argocd application을 생성하고 [kustomize.resource](./cluster-a/kustomization.yaml)에 목록만 추가하면 된다. 제거하고 싶으면 [kustomize.resource](./cluster-a/kustomization.yaml)목록에서 제거한다.
