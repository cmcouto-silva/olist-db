#!/bin/bash
set -e

echo "🚀 PGVector Verification for Olist Database"
echo "==========================================="
echo ""

# Check if docker-compose is running
if ! docker-compose ps | grep -q "postgres.*Up"; then
    echo "⚠️  Database not running. Please start with: docker-compose up -d"
    exit 1
fi

echo "🔍 Testing pgvector extension..."

# Test 1: Check if extension is installed
echo "📋 Checking extension installation..."
EXTENSION_CHECK=$(docker-compose exec -T postgres psql -U postgres -d olist_ecommerce -t -c "SELECT extname FROM pg_extension WHERE extname = 'vector';" | tr -d ' ')

if [ "$EXTENSION_CHECK" = "vector" ]; then
    echo "✅ pgvector extension is installed"
    VERSION=$(docker-compose exec -T postgres psql -U postgres -d olist_ecommerce -t -c "SELECT extversion FROM pg_extension WHERE extname = 'vector';" | tr -d ' ')
    echo "   Version: $VERSION"
else
    echo "❌ pgvector extension not found"
    exit 1
fi

# Test 2: Test vector operations
echo ""
echo "🧮 Testing vector operations..."
docker-compose exec -T postgres psql -U postgres -d olist_ecommerce << 'EOF'
-- Create test table
CREATE TABLE IF NOT EXISTS pgvector_test (
    id SERIAL PRIMARY KEY,
    name TEXT,
    embedding vector(3)
);

-- Insert test data
INSERT INTO pgvector_test (name, embedding) VALUES 
('test1', '[1,2,3]'),
('test2', '[4,5,6]'),
('test3', '[7,8,9]')
ON CONFLICT DO NOTHING;

-- Test similarity search
\echo '✅ Vector similarity search:'
SELECT name, embedding, 
       ROUND((embedding <-> '[2,3,4]')::numeric, 3) AS distance
FROM pgvector_test
ORDER BY embedding <-> '[2,3,4]'
LIMIT 2;

-- Test dot product
\echo '✅ Vector dot product:'
SELECT name, 
       ROUND((embedding <#> '[1,1,1]')::numeric, 3) AS dot_product
FROM pgvector_test
ORDER BY embedding <#> '[1,1,1]'
LIMIT 1;

-- Test cosine similarity
\echo '✅ Vector cosine similarity:'
SELECT name, 
       ROUND((embedding <=> '[1,1,1]')::numeric, 3) AS cosine_distance
FROM pgvector_test
ORDER BY embedding <=> '[1,1,1]'
LIMIT 1;

-- Cleanup
DROP TABLE pgvector_test;
EOF

# Test 3: Check schemas
echo ""
echo "📊 Checking database schemas..."
ECOMMERCE_TABLES=$(docker-compose exec -T postgres psql -U postgres -d olist_ecommerce -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'ecommerce';" | tr -d ' ')
MARKETING_TABLES=$(docker-compose exec -T postgres psql -U postgres -d olist_ecommerce -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'marketing';" | tr -d ' ')

echo "✅ Ecommerce schema: $ECOMMERCE_TABLES tables"
echo "✅ Marketing schema: $MARKETING_TABLES tables"

echo ""
echo "🎉 ALL TESTS PASSED!"
echo ""
echo "🚀 Your Olist database is ready for:"
echo "   • Vector embeddings storage"
echo "   • Similarity search operations"
echo "   • AI/ML workloads with pgvector"
echo "   • Recommendation systems"
echo "   • Semantic search capabilities"
echo ""
echo "💡 Example usage:"
echo "   CREATE TABLE product_embeddings (product_id TEXT, embedding vector(1536));"
echo "   SELECT * FROM products ORDER BY embedding <-> '[0.1, 0.2, ...]' LIMIT 10;"