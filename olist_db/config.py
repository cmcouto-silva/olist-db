"""Simplified configuration for olist e-commerce dataset loading"""

import os
from dataclasses import dataclass
from pathlib import Path


@dataclass
class DatabaseConfig:
    """Database connection configuration"""

    name: str = "olist_ecommerce"
    user: str = "postgres"
    password: str = "postgres"
    host: str = "localhost"
    port: str = "5432"

    @classmethod
    def from_env(cls):
        """Create config from environment variables with defaults"""
        return cls(
            name=os.getenv("DB_NAME", "olist_ecommerce"),
            user=os.getenv("DB_USER", "postgres"),
            password=os.getenv("DB_PASSWORD", "postgres"),
            host=os.getenv("DB_HOST", "localhost"),
            port=os.getenv("DB_PORT", "5432"),
        )


# Simple constant - no functions needed!
DATA_DIR = Path(__file__).parent.parent / "data"
