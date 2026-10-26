# 상품 소개문 서비스 — Day 6에서 만든 FastAPI 서비스 (Day 8 CI/CD의 대상)
from fastapi import FastAPI
from pydantic import BaseModel

from app.checker import check_rules

app = FastAPI(title="상품 소개문 서비스")


class CheckRequest(BaseModel):
    text: str
    name: str
    price: str


@app.get("/health")
def health():
    """서비스 생존 확인용 (Day 10 Auto Healing에서 재사용)"""
    return {"status": "ok"}


@app.post("/check")
def check(req: CheckRequest):
    """소개문이 작성 규칙을 지켰는지 검사한다."""
    violations = check_rules(req.text, {"name": req.name, "price": req.price})
    return {"passed": not violations, "violations": violations}
