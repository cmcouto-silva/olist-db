#!/bin/bash
set -e

echo "🔐 Setting up secure Olist database..."

# Configuration
READONLY_USER="scipy2025"

# Generate secure passwords
ADMIN_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-20)
READONLY_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-20)

# Create .env file with secure passwords
cat > .env << EOF
# Database Admin (full access)
DB_ADMIN_USER=postgres
DB_ADMIN_PASSWORD=${ADMIN_PASSWORD}

# Read-only service account (for audience)
DB_READONLY_USER=${READONLY_USER}
DB_READONLY_PASSWORD=${READONLY_PASSWORD}

# Database config
DB_NAME=olist_ecommerce
DB_HOST=postgres
DB_PORT=5432
EOF

# Create docker-compose with secure passwords
cat > docker-compose.yml << EOF
services:
  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_DB: olist_ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${ADMIN_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-readonly-user.sql:/docker-entrypoint-initdb.d/01-readonly-user.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  olist-loader:
    image: cmcoutosilva/olist-db:latest
    environment:
      DB_NAME: olist_ecommerce
      DB_USER: postgres
      DB_PASSWORD: ${ADMIN_PASSWORD}
      DB_HOST: postgres
      DB_PORT: 5432
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
EOF

# Create SQL script for read-only user
cat > init-readonly-user.sql << EOF
-- Create read-only ${READONLY_USER} user
CREATE USER ${READONLY_USER} WITH PASSWORD '${READONLY_PASSWORD}';

-- Grant connect privileges
GRANT CONNECT ON DATABASE olist_ecommerce TO ${READONLY_USER};

-- Grant usage on schemas
GRANT USAGE ON SCHEMA ecommerce TO ${READONLY_USER};
GRANT USAGE ON SCHEMA marketing TO ${READONLY_USER};

-- Grant SELECT on all existing tables
GRANT SELECT ON ALL TABLES IN SCHEMA ecommerce TO ${READONLY_USER};
GRANT SELECT ON ALL TABLES IN SCHEMA marketing TO ${READONLY_USER};

-- Grant SELECT on future tables (auto-grant)
ALTER DEFAULT PRIVILEGES IN SCHEMA ecommerce GRANT SELECT ON TABLES TO ${READONLY_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA marketing GRANT SELECT ON TABLES TO ${READONLY_USER};

-- Grant usage on sequences (for primary keys in queries)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA ecommerce TO ${READONLY_USER};
GRANT USAGE ON ALL SEQUENCES IN SCHEMA marketing TO ${READONLY_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA ecommerce GRANT USAGE ON SEQUENCES TO ${READONLY_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA marketing GRANT USAGE ON SEQUENCES TO ${READONLY_USER};

-- Prevent any modification privileges (explicit deny)
REVOKE CREATE ON SCHEMA ecommerce FROM ${READONLY_USER};
REVOKE CREATE ON SCHEMA marketing FROM ${READONLY_USER};
REVOKE ALL ON SCHEMA public FROM ${READONLY_USER};
EOF

echo ""
echo "✅ Security setup complete!"
echo ""
echo "📋 Connection Details:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 ADMIN ACCESS (Full privileges):"
echo "   Host: your-ec2-ip:5432"
echo "   Database: olist_ecommerce"
echo "   Username: postgres"
echo "   Password: ${ADMIN_PASSWORD}"
echo ""
echo "👥 ${READONLY_USER^^} ACCESS (Read-only for audience):"
echo "   Host: your-ec2-ip:5432"
echo "   Database: olist_ecommerce"
echo "   Username: ${READONLY_USER}"
echo "   Password: ${READONLY_PASSWORD}"
echo ""
echo "💾 Credentials saved to .env file"
echo "🚀 Run: sudo docker compose up"
echo "" 