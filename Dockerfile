FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_RUN_PORT=5000 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Create non-root user first
RUN useradd -m -u 1000 pythonuser && \
    chown -R pythonuser:pythonuser /app

# Copy requirements first for better layer caching
COPY --chown=pythonuser:pythonuser app/requirements.txt .

# Install dependencies as root, then switch to user
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=pythonuser:pythonuser app/ .

# Switch to non-root user
USER pythonuser

EXPOSE 5000

# Use gunicorn with production settings
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "30", "app:app"]