# ApplicationSet이란?

## 요약

* ApplicationSet은 **하나의 리소스로 여러 ArgoCD Application을 자동 생성하는 기능**입니다.
* ApplicationSet Controller가 ApplicationSet 리소스를 감시하고, 조건에 맞는 Application을 생성합니다.
* Generator와 Template 두 가지 핵심 구성요소로 이루어져 있습니다.

## 목차

* [ApplicationSet 정의](#applicationset-정의)
* [왜 ApplicationSet이 필요할까?](#왜-applicationset이-필요할까)
* [ApplicationSet 동작 원리](#applicationset-동작-원리)
* [핵심 구성요소](#핵심-구성요소)
* [참고자료](#참고자료)

## ApplicationSet 정의

ApplicationSet은 두 가지 단어를 합친 용어입니다. Application + Set

1. Application: ArgoCD에서 배포 단위를 의미합니다. Git 저장소의 manifest를 쿠버네티스 클러스터에 동기화하는 리소스입니다.
2. Set: 집합을 의미합니다.
3. ApplicationSet: **여러 ArgoCD Application을 하나의 리소스로 묶어서 관리하는 기능**입니다.

즉, ApplicationSet은 반복적인 Application 생성 작업을 자동화합니다.

## 왜 ApplicationSet이 필요할까?

ArgoCD Application을 하나씩 만드는 것은 클러스터가 적을 때는 문제가 없습니다. 하지만 관리하는 클러스터나 환경이 늘어나면 이야기가 달라집니다.

예를 들어, 3개 클러스터(dev, staging, prod)에 같은 애플리케이션을 배포한다고 가정합니다. Application을 하나씩 만들면 3개의 YAML 파일이 필요합니다. 환경이 10개로 늘어나면 10개의 YAML 파일을 관리해야 합니다.

**ApplicationSet을 사용하면 하나의 YAML 파일로 여러 환경에 Application을 자동 생성할 수 있습니다.**

## ApplicationSet 동작 원리

[아키텍처 그림: ApplicationSet Controller가 ApplicationSet 리소스를 감시하고 Application을 생성하는 흐름]

ApplicationSet Controller는 ArgoCD에 포함된 컨트롤러입니다. 동작 흐름은 다음과 같습니다.

1. 사용자가 ApplicationSet 리소스를 쿠버네티스에 배포합니다.
2. ApplicationSet Controller가 리소스를 감시하고, Generator에서 파라미터를 생성합니다.
3. 생성된 파라미터를 Template에 적용하여 ArgoCD Application을 자동으로 만듭니다.

정리하면, **Generator가 "무엇을" 만들지 결정하고, Template이 "어떻게" 만들지 정의합니다.**

## 핵심 구성요소

ApplicationSet은 크게 두 가지 구성요소로 이루어져 있습니다.

| 구성요소 | 역할 | 설명 |
|---|---|---|
| Generator | 파라미터 생성 | Application을 생성할 조건과 값을 정의 |
| Template | Application 템플릿 | 생성될 Application의 형태를 정의 |

Generator 종류에 대한 자세한 내용은 [Generator 종류](./generators-overview.md)를 참고하세요.
Template 구조에 대한 자세한 내용은 [Template 구조](./template.md)를 참고하세요.

## 참고자료

* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/>
* <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Appset-Any-Namespace/>
