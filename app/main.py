"""
Minimal FastAPI service with health, version, crash endpoints and request logging.
"""
import json
import os
import time
from fastapi import FastAPI

app = FastAPI()


@app.middleware("http")
async def log_requests(request, call_next):
    """Log one JSON line per request: method, path, status_code, duration_ms."""
    start = time.perf_counter()
    response = await call_next(request)
    duration_ms = (time.perf_counter() - start) * 1000
    line = {
        "method": request.method,
        "path": request.url.path,
        "status_code": response.status_code,
        "duration_ms": round(duration_ms, 2),
    }
    print(json.dumps(line))
    return response


@app.get("/health")
def health():
    """Health check for load balancers and monitoring."""
    return {"status": "ok", "source": "github-actions"}

@app.get("/version")
def version():
    """Return app version from APP_VERSION env var, or 'dev' if unset."""
    return {"version": os.environ.get("APP_VERSION", "dev")}


@app.get("/crash")
def crash():
    """Intentionally raise an exception (for testing error handling)."""
    raise RuntimeError("Intentional crash for testing")
