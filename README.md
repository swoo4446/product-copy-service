# Day 8 실습 키트 — CI/CD 파이프라인

**사용법**: 이 폴더(배포 위치)는 원본으로 두고, 작업 폴더 `C:\apps\product-copy-service`로 복사해 그곳을 **새 GitHub 리포지토리**로 올려 실습한다.

```powershell
# day08-cicd-lab이 보이는 상위 폴더에서 — 작업 폴더로 복사하고, 강사용 정답 폴더는 지운다
Copy-Item -Recurse .\day08-cicd-lab C:\apps\product-copy-service
cd C:\apps\product-copy-service
if (Test-Path .\정답) { Remove-Item -Recurse -Force .\정답 }

# 이후 모든 명령은 작업 폴더에서
git init
git add .
git commit -m "Day8: 서비스 초기 코드"
# GitHub에서 빈 리포지토리(product-copy-service) 생성 후
git remote add origin https://github.com/<내계정>/product-copy-service.git
git branch -M main
git push -u origin main
```

## 구성

| 경로 | 내용 | 출처 |
| --- | --- | --- |
| `app/` | FastAPI 검사 서비스 | Day 6 산출물 (M1 Day 1 검사기 재사용) |
| `tests/` | 단위·API 테스트 | CI가 매 푸시마다 실행 |
| `Dockerfile` | 이미지 정의 | Day 6 산출물 |
| `.github/workflows/ci.yml` | CI 워크플로우 (빈칸 채우기) | Day 8 3단계 |

## 로컬 확인 (푸시 전)

```powershell
uv venv                                 # 처음 한 번 — 작업 폴더 안에 .venv를 만든다
uv pip install -r requirements.txt      # 처음 한 번 — CI 러너와 같은 목록으로 설치
uv run pytest -q                        # 테스트 통과 확인 — 기대 결과: 5 passed
uv run uvicorn app.main:app --reload    # http://127.0.0.1:8000/docs 에서 API 확인
```

`requirements.txt`는 Docker 이미지, CI(GitHub Actions) 러너, 작업 폴더의 `.venv`가 모두 같이 쓰는 설치 목록이다. 패키지를 더하면 여기에 적는다. 작업 폴더는 `agent-dev` 밖이라 저장소 루트의 uv 환경을 쓰지 않는다.

## 커버리지 기준 (5단계)

```powershell
uv run pytest -q --cov=app --cov-fail-under=85   # 기대 결과: 5 passed, Total coverage 85.71% → 통과
uv run pytest -q tests/test_api.py --cov=app --cov-fail-under=85   # 검사기 테스트를 빼면 80.95% → 실패 (종료 코드 1)
```

기준 85%는 "현재 수준보다 약간 아래"로 잡았다 → 지금 코드는 통과하고, 테스트를 지우면 실패한다.

> ⚠️ 테스트는 LLM을 호출하지 않는다 → CI에서 API 키·비용 없이 돈다. LLM 경로의 검증은 Day 9(모니터링)에서 다룬다.
