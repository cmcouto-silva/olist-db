import contextlib
import pathlib

import psycopg

# File to table mapping in dependency order (independent tables first)
ECOMMERCE_FILE_TABLE_MAPPING = {
    "olist_customers_dataset.csv": "ecommerce.customers",
    "olist_geolocation_dataset.csv": "ecommerce.geolocation",
    "olist_products_dataset.csv": "ecommerce.products",
    "olist_sellers_dataset.csv": "ecommerce.sellers",
    "product_category_name_translation.csv": (
        "ecommerce.product_category_name_translations"
    ),
    "olist_orders_dataset.csv": "ecommerce.orders",  # Depends on customers
    "olist_order_items_dataset.csv": (
        "ecommerce.order_items"  # Depends on orders, products, sellers
    ),
    "olist_order_payments_dataset.csv": (
        "ecommerce.order_payments"  # Depends on orders
    ),
    "olist_order_reviews_dataset.csv": (
        "ecommerce.order_reviews"  # Depends on orders
    ),
}

MARKETING_FILE_TABLE_MAPPING = {
    "olist_marketing_qualified_leads_dataset.csv": (
        "marketing.marketing_qualified_leads"
    ),
    "olist_closed_deals_dataset.csv": (
        "marketing.closed_deals"  # Depends on marketing_qualified_leads and sellers
    ),
}

# Column mappings for tables that need specific column lists
# (excluding auto-generated columns)
TABLE_COLUMNS = {
    "ecommerce.geolocation": (
        "(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, "
        "geolocation_city, geolocation_state)"
    )
}

# Tables with verified data quality issues that need special handling
# Analysis: order_reviews has 827 duplicate review_ids (same ID for different orders)
# Analysis: closed_deals has 462 seller_ids that don't exist in ecommerce.sellers
TABLES_WITH_DUPLICATES = {
    "ecommerce.order_reviews",  # 827 duplicate review_ids out of 100,000 records
    "marketing.closed_deals",   # 462 invalid seller_id references out of 842 records
}


@contextlib.contextmanager
def postgres_cursor_context(db_config=None):
    """Creates a context with a psycopg cursor"""
    if db_config:
        # Use provided DatabaseConfig object
        connection_params = {
            "dbname": db_config.name,
            "user": db_config.user,
            "password": db_config.password,
            "host": db_config.host,
            "port": db_config.port,
        }
    else:
        # Use default config from environment
        from olist_db.config import DatabaseConfig

        default_config = DatabaseConfig.from_env()
        connection_params = {
            "dbname": default_config.name,
            "user": default_config.user,
            "password": default_config.password,
            "host": default_config.host,
            "port": default_config.port,
        }

    with (
        psycopg.connect(**connection_params) as connection,
        connection.cursor() as cursor,
    ):
        yield cursor


def create_schema(schema_script, db_config=None):
    """Creates the database schemas"""
    with open(pathlib.Path(__file__).parent / "schemas" / schema_script) as file:
        script = file.read()

    with postgres_cursor_context(db_config) as cursor:
        cursor.execute(script)


def insert_data_with_conflict_resolution(
    csv_file, table_name, columns_spec="", db_config=None
):
    """Insert data using temporary table with verified data quality issue resolution

    Handles two confirmed data issues:
    - order_reviews: 827 duplicate review_ids (keeps first occurrence)
    - closed_deals: 462 invalid seller_id FKs (filters out invalid references)
    """
    # Remove schema from table name for temp table (temp tables can't have schema)
    table_name_only = table_name.split(".")[-1]
    temp_table = f"{table_name_only}_temp"

    with postgres_cursor_context(db_config) as cursor:
        # Create temporary table with same structure but WITHOUT constraints
        cursor.execute(
            f"CREATE TEMP TABLE {temp_table} (LIKE {table_name} INCLUDING DEFAULTS)"
        )

        # Load data into temporary table (duplicates allowed)
        copy_sql = f"""
        COPY {temp_table} {columns_spec} FROM STDIN WITH
            CSV
            HEADER
            DELIMITER AS ','
            QUOTE '"'
        """

        with open(csv_file, encoding="utf-8") as file, cursor.copy(copy_sql) as copy:
            copy.write(file.read())

        # Insert from temp table with specific conflict resolution strategies
        if table_name == "ecommerce.order_reviews":
            # Data issue: 827 rows have duplicate review_ids
            # (same ID for different orders)
            # Solution: Keep first occurrence to satisfy PRIMARY KEY constraint
            insert_sql = f"""
            INSERT INTO {table_name}
            SELECT DISTINCT ON (review_id) * FROM {temp_table}
            ORDER BY review_id
            ON CONFLICT (review_id) DO NOTHING
            """
        elif table_name == "marketing.closed_deals":
            # Data issue: 462 rows reference seller_ids that don't exist
            # in ecommerce.sellers
            # Solution: Only insert deals where seller_id exists or is NULL
            # to satisfy FK constraint
            insert_sql = f"""
            INSERT INTO {table_name}
            SELECT * FROM {temp_table}
            WHERE seller_id IS NULL
               OR seller_id IN (SELECT seller_id FROM ecommerce.sellers)
            ON CONFLICT (mql_id) DO NOTHING
            """
        else:
            # Fallback for other tables (shouldn't be reached for current data)
            insert_sql = f"INSERT INTO {table_name} SELECT * FROM {temp_table}"

        cursor.execute(insert_sql)

        # Get row count for feedback
        cursor.execute(f"SELECT COUNT(*) FROM {temp_table}")
        temp_count = cursor.fetchone()[0]
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        final_count = cursor.fetchone()[0]
        duplicates_removed = temp_count - final_count

        if duplicates_removed > 0:
            print(
                f"  → Inserted {final_count} rows "
                f"({duplicates_removed} duplicates removed)"
            )
        else:
            print(f"  → Inserted {final_count} rows")


def insert_data(dataset, data_dir_path, db_config=None):
    """Inserts the the csv files in PostgreSQL"""
    mapping = (
        ECOMMERCE_FILE_TABLE_MAPPING
        if "ecommerce" in dataset
        else MARKETING_FILE_TABLE_MAPPING
    )

    data_dir = pathlib.Path(data_dir_path) / dataset

    # Load files in dependency order
    for csv_filename, table_name in mapping.items():
        csv_file = data_dir / csv_filename

        if not csv_file.exists():
            print(f"Warning: {csv_filename} not found, skipping...")
            continue

        print(f"Loading {csv_filename} -> {table_name}")

        # Get column specification for this table (if any)
        columns_spec = TABLE_COLUMNS.get(table_name, "")

        # Use conflict resolution for problematic tables
        if table_name in TABLES_WITH_DUPLICATES:
            insert_data_with_conflict_resolution(
                csv_file, table_name, columns_spec, db_config
            )
        else:
            # Use direct COPY for clean tables
            sql_statement = f"""
            COPY {table_name} {columns_spec} FROM STDIN WITH
                CSV
                HEADER
                DELIMITER AS ','
                QUOTE '"'
            """

            with (
                open(csv_file, encoding="utf-8") as file,
                postgres_cursor_context(db_config) as cursor,
                cursor.copy(sql_statement) as copy,
            ):
                copy.write(file.read())


def load_data():
    """Load data using default configuration from environment"""
    from olist_db.config import DATA_DIR, DatabaseConfig

    db_config = DatabaseConfig.from_env()
    load_data_with_config(db_config, str(DATA_DIR))


def load_data_with_config(db_config, data_dir):
    """Simplified function that accepts DatabaseConfig object and data directory"""
    print("Creating ecommerce schema...")
    create_schema("ecommerce.sql", db_config)

    print("Loading ecommerce data...")
    insert_data("olist-ecommerce", data_dir, db_config)
    print(
        'Schema "ecommerce" created successfully. Tables loaded: [{}]'.format(
            ", ".join(ECOMMERCE_FILE_TABLE_MAPPING.values())
        )
    )

    print("Creating marketing schema...")
    create_schema("marketing.sql", db_config)

    print("Loading marketing data...")
    insert_data("olist-marketing-funnel", data_dir, db_config)
    print(
        'Schema "marketing" created successfully. Tables loaded: [{}]'.format(
            ", ".join(MARKETING_FILE_TABLE_MAPPING.values())
        )
    )
