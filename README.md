# Olist E-commerce Database

A simple PostgreSQL database builder for the Olist Brazilian E-commerce dataset, designed for educational purposes.

## Features

- 🐘 **PostgreSQL schemas**: `ecommerce` and `marketing` with proper relationships
- 📝 **Database comments**: Comprehensive table and column documentation
- 🔧 **Data quality fixes**: Handles duplicate records and referential integrity issues
- 🐳 **Docker ready**: Easy deployment with Docker and Docker Compose
- 🚀 **PGVector support**: Vector embeddings and similarity search capabilities

## Quick Start

### Using Docker Hub (Recommended)

```bash
# Pull the pre-built image with data included
docker pull cmcoutosilva/olist-db:latest

# Create docker-compose.yml
curl -o docker-compose.yml https://raw.githubusercontent.com/cmcoutosilva/olist_db/main/docker-compose.yml

# Start the database with PGVector support
docker-compose up
```

### Using Docker Compose (Development)

```bash
git clone https://github.com/cmcoutosilva/olist_db.git
cd olist_db
docker-compose up
```

### Testing PGVector Setup

```bash
# Test that pgvector extension is working
./scripts/test_pgvector.sh
```

### Using Python

```bash
pip install git+https://github.com/cmcoutosilva/olist_db.git
load-olist-ecommerce-data --help
```

## Database Structure

- **Ecommerce Schema**: 9 tables with customer orders, products, reviews, and payments
- **Marketing Schema**: 2 tables with marketing qualified leads and closed deals
- **1.4M+ records** across all tables with proper foreign key relationships
- **PGVector Extension**: Enabled for vector embeddings and similarity search

## Vector Search Capabilities

- 🔍 **Vector similarity search**: Find similar products, customers, or reviews
- 📊 **Embedding storage**: Store AI-generated embeddings for any text fields
- ⚡ **High performance**: HNSW and IVFFlat indexing for fast vector queries
- 🤖 **AI/ML ready**: Perfect for recommendation systems and semantic search

## Data Quality Improvements

- ✅ **Duplicate handling**: 827 duplicate review IDs resolved
- ✅ **Referential integrity**: 462 invalid seller references filtered
- ✅ **Primary/Foreign keys**: Properly enforced database constraints
- ✅ **Documentation**: All tables and columns have descriptive comments

## Deployment

### Docker Hub

The pre-built image is available on Docker Hub:

```bash
# Pull the latest image (includes PostgreSQL + PGVector + Olist data)
docker pull cmcoutosilva/olist-db:latest

# Or use in docker-compose.yml
services:
  olist-loader:
    image: cmcoutosilva/olist-db:latest
```

### Building Your Own Image

```bash
# Clone and build
git clone https://github.com/cmcoutosilva/olist_db.git
cd olist_db
docker build -t your-username/olist-db .

# Push to your Docker Hub
docker push your-username/olist-db
```

### EC2 Deployment

See detailed instructions: [Deploy on EC2](docs/deploy-ec2.md)

```bash
# Quick EC2 setup
curl -o setup_db.sh https://raw.githubusercontent.com/cmcoutosilva/olist_db/main/scripts/setup_db.sh
chmod +x setup_db.sh && ./setup_db.sh
docker-compose up -d
```

## References

### Original Data Sources

1. [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data)
2. [Marketing Funnel by Olist](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist/data)

### Based On

- [mara/mara-olist-ecommerce-data](https://github.com/mara/mara-olist-ecommerce-data)

### Improvements Made

- Modern Python codebase (Python 3.10+, uv, ruff)
- Comprehensive database comments and documentation  
- Fixed data quality issues (duplicates and referential integrity)
- Simplified configuration and deployment scripts
- Docker containerization for easy deployment

## License

MIT License - Educational use encouraged!
