#!/bin/bash
# Olist Database Setup Script

set -e

echo "🚀 Olist Database Deployment Guide"
echo "=================================="

echo ""
echo "📋 Deployment Options:"
echo ""
echo "1️⃣  Local Development:"
echo "   docker-compose up"
echo ""
echo "2️⃣  Docker Hub Deployment:"
echo "   docker build -t your-username/olist-db ."
echo "   docker push your-username/olist-db"
echo ""
echo "3️⃣  EC2 Deployment:"
echo "   docker pull your-username/olist-db"
echo "   docker run -d -p 5432:5432 your-username/olist-db"
echo ""
echo "📚 Database Info:"
echo "   Host: localhost:5432"
echo "   Database: olist_ecommerce"
echo "   User: postgres"
echo "   Password: postgres"
echo ""
echo "💡 User Management:"
echo "   Create additional users as needed directly via psql"
echo "   All tables have comprehensive comments from data_dictionary.yml" 
