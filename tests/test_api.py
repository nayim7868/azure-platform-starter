"""API tests using FastAPI TestClient."""
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app, raise_server_exceptions=False)

def test_health_returns_200_and_status_ok():
    """GET /health returns 200 and JSON includes status ok."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_crash_returns_500():
    """GET /crash returns 500."""
    response = client.get("/crash")
    assert response.status_code == 500
