-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

DROP SCHEMA IF EXISTS ecommerce CASCADE;
CREATE SCHEMA ecommerce;

-- This dataset has information about the customer and its location. Use it to identify unique customers in the orders dataset and to find the orders delivery location.
-- At our system each order is assigned to a unique customer_id. This means that the same customer will get different ids for different orders.
-- The purpose of having a customer_unique_id on the dataset is to allow you to identify customers that made repurchases at the store. Otherwise you would find that each order had a different customer associated with.
DROP TABLE IF EXISTS ecommerce.customers CASCADE;
CREATE TABLE ecommerce.customers
(
    customer_id              TEXT PRIMARY KEY, -- key to the orders dataset. Each order has a unique customer_id.
    customer_unique_id       TEXT NOT NULL,    -- unique identifier of a customer.
    customer_zip_code_prefix TEXT,             -- first five digits of customer zip code
    customer_city            TEXT,             -- customer city name
    customer_state           TEXT              -- customer state
);

COMMENT ON TABLE ecommerce.customers IS 'This dataset has information about the customer and its location. Use it to identify unique customers in the orders dataset and to find the orders delivery location. At our system each order is assigned to a unique customer_id. This means that the same customer will get different ids for different orders. The purpose of having a customer_unique_id on the dataset is to allow you to identify customers that made repurchases at the store. Otherwise you would find that each order had a different customer associated with.';
COMMENT ON COLUMN ecommerce.customers.customer_id IS 'key to the orders dataset. Each order has a unique customer_id.';
COMMENT ON COLUMN ecommerce.customers.customer_unique_id IS 'unique identifier of a customer.';
COMMENT ON COLUMN ecommerce.customers.customer_zip_code_prefix IS 'first five digits of customer zip code';
COMMENT ON COLUMN ecommerce.customers.customer_city IS 'customer city name';
COMMENT ON COLUMN ecommerce.customers.customer_state IS 'customer state';

-- This dataset has information Brazilian zip codes and its lat/lng coordinates. Use it to plot maps and find distances between sellers and customers.
DROP TABLE IF EXISTS ecommerce.geolocation CASCADE;
CREATE TABLE ecommerce.geolocation
(
    geolocation_id              SERIAL PRIMARY KEY,      -- Surrogate key for geolocation entries
    geolocation_zip_code_prefix TEXT,                    -- first 5 digits of zip code
    geolocation_lat             DOUBLE PRECISION,        -- latitude
    geolocation_lng             DOUBLE PRECISION,        -- longitude
    geolocation_city            TEXT,                    -- city name
    geolocation_state           TEXT                     -- state
);

COMMENT ON TABLE ecommerce.geolocation IS 'This dataset has information Brazilian zip codes and its lat/lng coordinates. Use it to plot maps and find distances between sellers and customers.';
COMMENT ON COLUMN ecommerce.geolocation.geolocation_id IS 'Surrogate key for geolocation entries';
COMMENT ON COLUMN ecommerce.geolocation.geolocation_zip_code_prefix IS 'first 5 digits of zip code';
COMMENT ON COLUMN ecommerce.geolocation.geolocation_lat IS 'latitude';
COMMENT ON COLUMN ecommerce.geolocation.geolocation_lng IS 'longitude';
COMMENT ON COLUMN ecommerce.geolocation.geolocation_city IS 'city name';
COMMENT ON COLUMN ecommerce.geolocation.geolocation_state IS 'state';

-- This dataset includes data about the products sold by Olist.
DROP TABLE IF EXISTS ecommerce.products CASCADE;
CREATE TABLE ecommerce.products
(
    product_id                   TEXT PRIMARY KEY,    -- unique product identifier
    product_category_name        TEXT,                -- root category of product, in Portuguese.
    product_name_lenght          INTEGER,             -- number of characters extracted from the product name.
    product_description_lenght   INTEGER,             -- number of characters extracted from the product description.
    product_photos_qty           INTEGER,             -- number of product published photos
    product_weight_g             INTEGER,             -- product weight measured in grams.
    product_length_cm            INTEGER,             -- product length measured in centimeters.
    product_height_cm            INTEGER,             -- product height measured in centimeters.
    product_width_cm             INTEGER              -- product width measured in centimeters.
);

COMMENT ON TABLE ecommerce.products IS 'This dataset includes data about the products sold by Olist.';
COMMENT ON COLUMN ecommerce.products.product_id IS 'unique product identifier';
COMMENT ON COLUMN ecommerce.products.product_category_name IS 'root category of product, in Portuguese.';
COMMENT ON COLUMN ecommerce.products.product_name_lenght IS 'number of characters extracted from the product name.';
COMMENT ON COLUMN ecommerce.products.product_description_lenght IS 'number of characters extracted from the product description.';
COMMENT ON COLUMN ecommerce.products.product_photos_qty IS 'number of product published photos';
COMMENT ON COLUMN ecommerce.products.product_weight_g IS 'product weight measured in grams.';
COMMENT ON COLUMN ecommerce.products.product_length_cm IS 'product length measured in centimeters.';
COMMENT ON COLUMN ecommerce.products.product_height_cm IS 'product height measured in centimeters.';
COMMENT ON COLUMN ecommerce.products.product_width_cm IS 'product width measured in centimeters.';

-- This dataset includes data about the sellers that fulfilled orders made at Olist. Use it to find the seller location and to identify which seller fulfilled each product.
DROP TABLE IF EXISTS ecommerce.sellers CASCADE;
CREATE TABLE ecommerce.sellers
(
    seller_id              TEXT PRIMARY KEY,    -- seller unique identifier
    seller_zip_code_prefix TEXT,                -- first 5 digits of seller zip code
    seller_city            TEXT,                -- seller city name
    seller_state           TEXT                 -- seller state
);

COMMENT ON TABLE ecommerce.sellers IS 'This dataset includes data about the sellers that fulfilled orders made at Olist. Use it to find the seller location and to identify which seller fulfilled each product.';
COMMENT ON COLUMN ecommerce.sellers.seller_id IS 'seller unique identifier';
COMMENT ON COLUMN ecommerce.sellers.seller_zip_code_prefix IS 'first 5 digits of seller zip code';
COMMENT ON COLUMN ecommerce.sellers.seller_city IS 'seller city name';
COMMENT ON COLUMN ecommerce.sellers.seller_state IS 'seller state';

-- Translates the product_category_name to english.
DROP TABLE IF EXISTS ecommerce.product_category_name_translations CASCADE;
CREATE TABLE ecommerce.product_category_name_translations
(
    product_category_name         TEXT PRIMARY KEY,    -- category name in Portuguese
    product_category_name_english TEXT NOT NULL         -- category name in English
);

COMMENT ON TABLE ecommerce.product_category_name_translations IS 'Translates the product_category_name to english.';
COMMENT ON COLUMN ecommerce.product_category_name_translations.product_category_name IS 'category name in Portuguese';
COMMENT ON COLUMN ecommerce.product_category_name_translations.product_category_name_english IS 'category name in English';

-- This is the core dataset. From each order you might find all other information.
DROP TABLE IF EXISTS ecommerce.orders CASCADE;
CREATE TABLE ecommerce.orders
(
    order_id                      TEXT PRIMARY KEY,             -- unique identifier of the order.
    customer_id                   TEXT NOT NULL,                -- key to the customer dataset. Each order has a unique customer_id.
    order_status                  TEXT,                         -- Reference to the order status (delivered, shipped, etc).
    order_purchase_timestamp      TIMESTAMP,                    -- Shows the purchase timestamp.
    order_approved_at             TIMESTAMP WITH TIME ZONE,     -- Shows the payment approval timestamp.
    order_delivered_carrier_date  TIMESTAMP WITH TIME ZONE,     -- Shows the order posting timestamp. When it was handled to the logistic partner.
    order_delivered_customer_date TIMESTAMP WITH TIME ZONE,     -- Shows the actual order delivery date to the customer.
    order_estimated_delivery_date TIMESTAMP WITH TIME ZONE,     -- Shows the estimated delivery date that was informed to customer at the purchase moment.
    FOREIGN KEY (customer_id) REFERENCES ecommerce.customers(customer_id)
);

COMMENT ON TABLE ecommerce.orders IS 'This is the core dataset. From each order you might find all other information.';
COMMENT ON COLUMN ecommerce.orders.order_id IS 'unique identifier of the order.';
COMMENT ON COLUMN ecommerce.orders.customer_id IS 'key to the customer dataset. Each order has a unique customer_id.';
COMMENT ON COLUMN ecommerce.orders.order_status IS 'Reference to the order status (delivered, shipped, etc).';
COMMENT ON COLUMN ecommerce.orders.order_purchase_timestamp IS 'Shows the purchase timestamp.';
COMMENT ON COLUMN ecommerce.orders.order_approved_at IS 'Shows the payment approval timestamp.';
COMMENT ON COLUMN ecommerce.orders.order_delivered_carrier_date IS 'Shows the order posting timestamp. When it was handled to the logistic partner.';
COMMENT ON COLUMN ecommerce.orders.order_delivered_customer_date IS 'Shows the actual order delivery date to the customer.';
COMMENT ON COLUMN ecommerce.orders.order_estimated_delivery_date IS 'Shows the estimated delivery date that was informed to customer at the purchase moment.';

-- This dataset includes data about the items purchased within each order.
DROP TABLE IF EXISTS ecommerce.order_items CASCADE;
CREATE TABLE ecommerce.order_items
(
    order_id            TEXT NOT NULL,                -- order unique identifier
    order_item_id       INTEGER NOT NULL,             -- sequential number identifying number of items included in the same order.
    product_id          TEXT NOT NULL,                -- product unique identifier
    seller_id           TEXT NOT NULL,                -- seller unique identifier
    shipping_limit_date TIMESTAMP WITH TIME ZONE,     -- Shows the seller shipping limit date for handling the order over to the logistic partner.
    price               DOUBLE PRECISION,             -- item price
    freight_value       DOUBLE PRECISION,             -- item freight value item (if an order has more than one item the freight value is splitted between items)
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES ecommerce.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES ecommerce.products(product_id),
    FOREIGN KEY (seller_id) REFERENCES ecommerce.sellers(seller_id)
);

COMMENT ON TABLE ecommerce.order_items IS 'This dataset includes data about the items purchased within each order.';
COMMENT ON COLUMN ecommerce.order_items.order_id IS 'order unique identifier';
COMMENT ON COLUMN ecommerce.order_items.order_item_id IS 'sequential number identifying number of items included in the same order.';
COMMENT ON COLUMN ecommerce.order_items.product_id IS 'product unique identifier';
COMMENT ON COLUMN ecommerce.order_items.seller_id IS 'seller unique identifier';
COMMENT ON COLUMN ecommerce.order_items.shipping_limit_date IS 'Shows the seller shipping limit date for handling the order over to the logistic partner.';
COMMENT ON COLUMN ecommerce.order_items.price IS 'item price';
COMMENT ON COLUMN ecommerce.order_items.freight_value IS 'item freight value item (if an order has more than one item the freight value is splitted between items)';

-- This dataset includes data about the orders payment options.
DROP TABLE IF EXISTS ecommerce.order_payments CASCADE;
CREATE TABLE ecommerce.order_payments
(
    order_id             TEXT NOT NULL,       -- unique identifier of an order.
    payment_sequential   INTEGER NOT NULL,    -- a customer may pay an order with more than one payment method. If he does so, a sequence will be created to accommodate all payments.
    payment_type         TEXT,                -- method of payment chosen by the customer.
    payment_installments INTEGER,             -- number of installments chosen by the customer.
    payment_value        DOUBLE PRECISION,    -- transaction value.
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES ecommerce.orders(order_id)
);

COMMENT ON TABLE ecommerce.order_payments IS 'This dataset includes data about the orders payment options.';
COMMENT ON COLUMN ecommerce.order_payments.order_id IS 'unique identifier of an order.';
COMMENT ON COLUMN ecommerce.order_payments.payment_sequential IS 'a customer may pay an order with more than one payment method. If he does so, a sequence will be created to accommodate all payments.';
COMMENT ON COLUMN ecommerce.order_payments.payment_type IS 'method of payment chosen by the customer.';
COMMENT ON COLUMN ecommerce.order_payments.payment_installments IS 'number of installments chosen by the customer.';
COMMENT ON COLUMN ecommerce.order_payments.payment_value IS 'transaction value.';

-- This dataset includes data about the reviews made by the customers. After a customer purchases the product from Olist Store a seller gets notified to fulfill that order. Once the customer receives the product, or the estimated delivery date is due, the customer gets a satisfaction survey by email where he can give a note for the purchase experience and write down some comments.
DROP TABLE IF EXISTS ecommerce.order_reviews CASCADE;
CREATE TABLE ecommerce.order_reviews
(
    review_id               TEXT PRIMARY KEY,             -- unique review identifier
    order_id                TEXT NOT NULL,                -- unique order identifier
    review_score            INTEGER,                      -- Note ranging from 1 to 5 given by the customer on a satisfaction survey.
    review_comment_title    TEXT,                         -- Comment title from the review left by the customer, in Portuguese.
    review_comment_message  TEXT,                         -- Comment message from the review left by the customer, in Portuguese.
    review_creation_date    TIMESTAMP WITH TIME ZONE,     -- Shows the date in which the satisfaction survey was sent to the customer.
    review_answer_timestamp TIMESTAMP WITH TIME ZONE,     -- Shows satisfaction survey answer timestamp.
    FOREIGN KEY (order_id) REFERENCES ecommerce.orders(order_id),
    CHECK (review_score >= 1 AND review_score <= 5)
);

COMMENT ON TABLE ecommerce.order_reviews IS 'This dataset includes data about the reviews made by the customers. After a customer purchases the product from Olist Store a seller gets notified to fulfill that order. Once the customer receives the product, or the estimated delivery date is due, the customer gets a satisfaction survey by email where he can give a note for the purchase experience and write down some comments.';
COMMENT ON COLUMN ecommerce.order_reviews.review_id IS 'unique review identifier';
COMMENT ON COLUMN ecommerce.order_reviews.order_id IS 'unique order identifier';
COMMENT ON COLUMN ecommerce.order_reviews.review_score IS 'Note ranging from 1 to 5 given by the customer on a satisfaction survey.';
COMMENT ON COLUMN ecommerce.order_reviews.review_comment_title IS 'Comment title from the review left by the customer, in Portuguese.';
COMMENT ON COLUMN ecommerce.order_reviews.review_comment_message IS 'Comment message from the review left by the customer, in Portuguese.';
COMMENT ON COLUMN ecommerce.order_reviews.review_creation_date IS 'Shows the date in which the satisfaction survey was sent to the customer.';
COMMENT ON COLUMN ecommerce.order_reviews.review_answer_timestamp IS 'Shows satisfaction survey answer timestamp.';