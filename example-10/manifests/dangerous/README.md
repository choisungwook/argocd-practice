# dangerous

잘못된 설정으로 Application 삭제 위험이 있는 예제입니다. **학습 목적으로만 참고하고, 프로덕션 환경에 배포하지 마세요.**

## 예제 인덱스

| 파일 | 설명 | 위험 요소 |
|---|---|---|
| `no-label-filter.yaml` | Label 필터 없는 PR Generator | 모든 PR이 Application을 생성하여 리소스 폭증 |
| `no-preserve-resources.yaml` | preserveResourcesOnDeletion 없이 짧은 polling 주기 | API 장애 시 Application과 K8s 리소스 동시 삭제 |
| `worst-case.yaml` | Label 필터 없음 + 10초 polling + prune 활성화 | API 장애 시 모든 Application과 K8s 리소스 대량 삭제 |
