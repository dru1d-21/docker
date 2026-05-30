# Stage 1: Builder — install only production dependencies
FROM python:3.12-slim AS builder

WORKDIR /build
COPY pyproject.toml .
RUN mkdir -p src && touch src/__init__.py
RUN pip install --no-cache-dir --prefix=/install .

# Stage 2: Production runtime (deployed to server)
FROM python:3.12-slim AS production

WORKDIR /app
ENV PYTHONPATH=/app
COPY --from=builder /install /usr/local
COPY src/ ./src/
EXPOSE 8058
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8058"]

# Stage 3: Test image — extends production, adds test tools
FROM production AS test

RUN pip install --no-cache-dir pytest pytest-asyncio==0.25.3 httpx==0.28.1
COPY tests/ ./tests/
