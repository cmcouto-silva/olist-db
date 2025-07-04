# Olist E-commerce Database

A simple PostgreSQL database builder for the Olist Brazilian E-commerce dataset, designed for educational purposes.

## Features

- 🐘 **PostgreSQL schemas**: `ecommerce` and `marketing` with proper relationships
- 📝 **Database comments**: Comprehensive table and column documentation
- 🔧 **Data quality fixes**: Handles duplicate records and referential integrity issues
- 🐳 **Docker ready**: Easy deployment with Docker and Docker Compose

## Quick Start

### Using Docker Compose

```bash
git clone https://github.com/cmcoutosilva/mara-olist-ecommerce-data.git
cd mara-olist-ecommerce-data
docker-compose up
```

### Using Python

```bash
pip install git+https://github.com/cmcoutosilva/mara-olist-ecommerce-data.git
load-olist-ecommerce-data --help
```

## Database Structure

- **Ecommerce Schema**: 9 tables with customer orders, products, reviews, and payments
- **Marketing Schema**: 2 tables with marketing qualified leads and closed deals
- **1.4M+ records** across all tables with proper foreign key relationships

## Data Quality Improvements

- ✅ **Duplicate handling**: 827 duplicate review IDs resolved
- ✅ **Referential integrity**: 462 invalid seller references filtered
- ✅ **Primary/Foreign keys**: Properly enforced database constraints
- ✅ **Documentation**: All tables and columns have descriptive comments

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
