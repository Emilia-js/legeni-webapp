# --- Étape 1 : Tests ---
FROM python:3.12-slim AS test
WORKDIR /app
COPY requirements.txt requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r requirements-dev.txt
COPY . .
RUN flake8 app.py && pytest --cov=app --cov-fail-under=80

# --- Étape 2 : Image finale minimale ---
FROM python:3.12-slim
WORKDIR /app
RUN useradd -m appuser
USER appuser
COPY --from=test /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --from=test /app/app.py .
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/health || exit 1
CMD ["flask", "run", "--host=0.0.0.0"]
