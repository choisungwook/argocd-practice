# Generator 종류

## 요약

* Generator는 ApplicationSet에서 **Application을 생성할 파라미터를 만드는 역할**을 합니다.
* ArgoCD는 다양한 Generator를 제공하며, 용도에 따라 선택합니다.
* 가장 기본적인 Generator는 List Generator입니다.

![arch](../imgs/arch.png "arch")

## 목차

* [Generator란?](#generator란)
* [Generator 종류](#generator-종류)
* [List Generator](#list-generator)
* [Git Generator](#git-generator)
* [Cluster Generator](#cluster-generator)
* [Pull Request Generator](#pull-request-generator)
* [어떤 Generator를 선택해야 할까?](#어떤-generator를-선택해야-할까)
* [참고자료](#참고자료)

## Generator란?

Generator는 ApplicationSet의 핵심 구성요소입니다. **Template에 전달할 파라미터(key-value)를 생성하는 역할**을 합니다.

Generator가 파라미터를 3개 생성하면, Application도 3개 만들어집니다. 즉, Generator가 생성하는 파라미터 개수가 곧 Application 개수를 결정합니다.

## Generator 종류

ArgoCD는 여러 종류의 Generator를 제공합니다.

| Generator | 설명 | 사용 사례 |
|---|---|---|
| List | 사용자가 직접 파라미터 목록을 정의 | 소수의 클러스터/환경 관리 |
| Git Directory | Git 저장소의 디렉터리 구조를 기반으로 생성 | 디렉터리별 Application 자동 생성 |
| Git File | Git 저장소의 파일 내용을 기반으로 생성 | 설정 파일 기반 Application 생성 |
| Cluster | ArgoCD에 등록된 클러스터 목록을 기반으로 생성 | 멀티 클러스터 배포 |
| Pull Request | Git 저장소의 PR을 기반으로 생성 | PR 환경 자동 생성 |
| Matrix | 두 Generator를 조합하여 생성 | 복합 조건 Application 생성 |
| Merge | 두 Generator 결과를 병합하여 생성 | Generator 결과 병합 |

## List Generator

가장 기본적인 Generator입니다. 사용자가 직접 파라미터 목록을 YAML에 정의합니다.

```yaml
generators:
  - list:
      elements:
        - cluster: dev
          url: https://dev-cluster.example.com
        - cluster: staging
          url: https://staging-cluster.example.com
```

위 예제는 파라미터를 2개 생성합니다. 따라서 Application도 2개 만들어집니다.

## Git Generator

Git 저장소의 디렉터리 구조나 파일 내용을 기반으로 파라미터를 생성합니다. 두 가지 방식이 있습니다.

1. **Directory**: 특정 경로 아래 디렉터리 이름을 파라미터로 사용
2. **File**: 특정 경로의 JSON/YAML 파일 내용을 파라미터로 사용

Git Generator는 저장소에 디렉터리나 파일을 추가하면 자동으로 Application이 생성되어 편리합니다.

## Cluster Generator

ArgoCD에 등록된 클러스터 목록을 기반으로 파라미터를 생성합니다. 새 클러스터를 ArgoCD에 등록하면 자동으로 Application이 생성됩니다.

**멀티 클러스터 환경에서 동일한 애플리케이션을 모든 클러스터에 배포할 때 유용합니다.**

## Pull Request Generator

Git 저장소의 Pull Request를 기반으로 파라미터를 생성합니다. PR이 생성되면 자동으로 preview 환경을 만들 수 있습니다.

Pull Request Generator에 대한 자세한 내용은 [example-10](../../example-10/)을 참고하세요.

## 어떤 Generator를 선택해야 할까?

Generator 선택은 사용 사례에 따라 달라집니다.

* 환경이 고정되어 있고 수가 적다면 → **List Generator**
* Git 저장소 구조 기반으로 자동화하고 싶다면 → **Git Generator**
* 멀티 클러스터에 동일 앱을 배포한다면 → **Cluster Generator**
* PR마다 preview 환경을 만들고 싶다면 → **Pull Request Generator**

## 참고자료

* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators/>
* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-List/>
* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/>
* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Cluster/>
* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/>
