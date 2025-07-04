"""Simplified CLI for loading Olist e-commerce data into PostgreSQL"""

import os

import click

from olist_db.config import DATA_DIR, DatabaseConfig
from olist_db.load_data import load_data_with_config


@click.command()
@click.option(
    "--data-dir", default=str(DATA_DIR), help="Directory containing CSV files"
)
@click.option(
    "--db-name",
    default=lambda: os.getenv("DB_NAME", "olist_ecommerce"),
    help="Database name",
)
@click.option(
    "--db-user", default=lambda: os.getenv("DB_USER", "postgres"), help="Database user"
)
@click.option(
    "--db-password",
    default=lambda: os.getenv("DB_PASSWORD", "postgres"),
    help="Database password",
)
@click.option(
    "--db-host", default=lambda: os.getenv("DB_HOST", "localhost"), help="Database host"
)
@click.option(
    "--db-port", default=lambda: os.getenv("DB_PORT", "5432"), help="Database port"
)
def load_data_cli(data_dir, db_name, db_user, db_password, db_host, db_port):
    """Load Olist e-commerce data into PostgreSQL"""
    # Create database config object
    db_config = DatabaseConfig(
        name=db_name, user=db_user, password=db_password, host=db_host, port=db_port
    )
    # Load the data
    load_data_with_config(db_config, data_dir)
