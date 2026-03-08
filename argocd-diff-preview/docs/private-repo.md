# Private Repo 설정

## 요약

- private repository에서 argocd-diff-preview를 사용하는 GitHub Actions workflow를 설정합니다
- ArgoCD가 git clone할 때 인증이 필요하므로 Kubernetes Secret을 추가해야 합니다
- public repo 설정에 secret 준비 step과 `/secrets` volume mount가 추가됩니다

## Public Repo와 차이점

| 항목 | Public Repo | Private Repo |
| --- | --- | --- |
| 인증 정보 | 불필요 | Kubernetes Secret 필요 |
| secrets volume | 없음 | `-v $(pwd)/secrets:/secrets` 추가 |
| workflow step | 3개 | 4개 (secret 준비 step 추가) |

## GitHub Actions workflow

`.github/workflows/argocd-diff-preview.yaml` 파일을 생성합니다.

```yaml
    # ... (public repo와 동일한 부분 생략)

    steps:
      # ... checkout steps 동일 ...

      # ✅ private repo 추가: secret 준비
      - name: Prepare secrets
        run: |
          mkdir secrets
          cat > secrets/secret.yaml << "EOF"
          apiVersion: v1
          kind: Secret
          metadata:
            name: private-repo
            namespace: argocd
            labels:
              argocd.argoproj.io/secret-type: repo-creds
          stringData:
            url: https://github.com/${{ github.repository }}
            password: ${{ secrets.GITHUB_TOKEN }}
            username: not-used
          EOF

      - name: Generate Diff
        run: |
          docker run \
            --network=host \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v $(pwd)/main:/base-branch \
            -v $(pwd)/pull-request:/target-branch \
            -v $(pwd)/output:/output \
            # ✅ private repo 추가: secrets volume mount
            -v $(pwd)/secrets:/secrets \
            -e TARGET_BRANCH=${{ github.head_ref }} \
            -e REPO=${{ github.repository }} \
            dagandersen/argocd-diff-preview:latest

      # ... Post diff comment 동일 ...
```

## Secret 설명

ArgoCD가 private repo를 clone하려면 인증 정보가 필요합니다. `repo-creds` 타입의 Kubernetes Secret을 생성합니다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  url: https://github.com/<OWNER>/<REPO>
  password: <GITHUB_TOKEN>
  username: not-used
```

| 필드 | 설명 |
| --- | --- |
| `argocd.argoproj.io/secret-type: repo-creds` | ArgoCD가 이 Secret을 repo 인증 정보로 인식하는 label |
| `stringData.url` | repository URL |
| `stringData.password` | GitHub token (GITHUB_TOKEN 사용) |
| `stringData.username` | 사용하지 않지만 필수 필드 |

## SSH key 방식

HTTPS 대신 SSH key를 사용할 수도 있습니다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-ssh
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  url: git@github.com:<OWNER>/<REPO>
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
```

SSH key를 사용하려면 GitHub repository의 Settings > Secrets에 SSH private key를 등록한 뒤, workflow에서 `${{ secrets.SSH_PRIVATE_KEY }}`로 참조합니다.

## 참고자료

- <https://github.com/dag-andersen/argocd-diff-preview>
- <https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories>
