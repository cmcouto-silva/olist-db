# Deploy Olist Database on EC2

## 🔐 Secure Setup (Recommended)

### 1. Pull the Docker image

```bash
docker pull cmcoutosilva/olist-db:latest
```

### 2. Download and run the security setup script

```bash
# Download the setup script
curl -o setup_db.sh https://raw.githubusercontent.com/cmcoutosilva/olist-db/main/scripts/setup_db.sh
chmod +x setup_db.sh

# Run the security setup
./setup_db.sh
```

This will:

- ✅ Generate secure random passwords
- ✅ Create admin account (full access)
- ✅ Create read-only `scipy2025` account for your audience
- ✅ Save credentials to `.env` file
- ✅ Create secure docker-compose.yml

### 3. Start the database

```bash
sudo docker compose up -d
```

### 4. Access credentials

Check the `.env` file for connection details:
```bash
cat .env
```

You'll get two accounts:

- **Admin (postgres)**: Full database access
- **SciPy2025**: Read-only access for your audience

---

## ⚡ Quick Start (Basic Setup)

### 1. Pull the Docker image

```bash
docker pull cmcoutosilva/olist-db:latest
```

### 2. Create docker-compose.yml

```yaml
services:
  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_DB: olist_ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
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
      DB_PASSWORD: postgres
      DB_HOST: postgres
      DB_PORT: 5432
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
```

### 3. Run

```bash
sudo docker compose up
```

### 4. Connect

- **Host**: `your-ec2-ip:5432`
- **Database**: `olist_ecommerce`
- **User**: `postgres`
- **Password**: `postgres`

---

## 🎯 Features

- ✅ **PostgreSQL 17** (latest version)
- ✅ **Alpine Linux** (secure, lightweight)
- ✅ **Health checks** for reliable startup
- ✅ **Read-only user** for audience access
- ✅ **Secure passwords** (when using secure setup)
- ✅ **1.4M+ records** loaded with integrity constraints
- ✅ **Automatic duplicate handling**
- ✅ **Complete schema** with comments

## 🔒 User Permissions

### Admin Account (`postgres`)

- Full database access
- Can create, modify, delete tables
- Database administration

### SciPy2025 Account (`scipy2025`)

- **Read-only access** to all schemas
- Can SELECT from any table
- **Cannot** INSERT, UPDATE, DELETE, or DROP
- Perfect for your audience/students
