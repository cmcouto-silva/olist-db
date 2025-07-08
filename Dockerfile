# Olist Database Loader with PGVector Support
# This container loads Brazilian E-commerce data into PostgreSQL with vector extensions
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY README.md ./
COPY LICENSE ./

# Copy source code and data
COPY olist_db/ ./olist_db/
COPY data/ ./data/

# Install uv for faster package management
RUN pip install uv

# Install dependencies using uv
# Includes psycopg>=3.2.9 with native PGVector support
RUN uv pip install --system .

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash app
RUN chown -R app:app /app
USER app

# Expose environment variables for database configuration
ENV DB_NAME=olist_ecommerce \
    DB_USER=postgres \
    DB_PASSWORD=postgres \
    DB_HOST=localhost \
    DB_PORT=5432

# Default command
CMD ["load-olist-ecommerce-data", "--data-dir", "/app/data"] 