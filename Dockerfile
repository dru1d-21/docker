# Stage 1: Builder — install all Python dependencies
FROM python:3.12-slim AS builder

WORKDIR /build
COPY pyproject.toml .
# Create minimal src package so setuptools can resolve the project
RUN mkdir -p src && touch src/__init__.py
RUN pip install --no-cache-dir --prefix=/install ".[test]"

# Stage 2: Minimal runtime image
FROM python:3.12-slim

WORKDIR /app
COPY --from=builder /install /usr/local
COPY src/ ./src/
COPY tests/ ./tests/

EXPOSE 8058
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8058"]
