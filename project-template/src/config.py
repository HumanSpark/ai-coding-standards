# File: src/projectname/config.py
# Purpose: Centralised configuration - all tuneable values in one place.
# Project: {ProjectName} | Date: {YYYY-MM-DD}
#
# Overview: Defines typed configuration using frozen dataclasses. Each
# module gets its own config section. The top-level AppConfig composes
# them and provides a from_env() classmethod that reads environment
# variables with sensible defaults.
#
# Modules receive their specific config section (e.g. ScraperConfig),
# never the full AppConfig and never raw env variables. This makes
# modules independently testable - pass a config object, not a live
# environment.
#
# Environment variables: loaded from ~/.env.shared (machine-level) and
# .env (project-level, never committed). The from_env() method reads
# these via os.getenv() with defaults for every value.

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import os


# TODO: Replace these examples with your project's actual configuration.
# Keep frozen=True so config can't be accidentally modified at runtime.

# Example per-module config:
#
# @dataclass(frozen=True)
# class ScraperConfig:
#     """Configuration for the scraper module."""
#     base_url: str = "https://example.com"
#     request_timeout: int = 30
#     max_retries: int = 3

# Example top-level config:
#
# @dataclass(frozen=True)
# class AppConfig:
#     """Composes module configs. Entry point for all configuration.
#
#     Usage:
#         config = AppConfig.from_env()
#         scraper = Scraper(config.scraper)
#     """
#     scraper: ScraperConfig = field(default_factory=ScraperConfig)
#     db_path: Path = Path("data/app.db")
#     log_level: str = "INFO"
#
#     @classmethod
#     def from_env(cls) -> "AppConfig":
#         """Build config from environment variables with sensible defaults.
#
#         Only override what's set - don't require every variable to exist.
#         Reads from os.getenv which picks up ~/.env.shared and .env values
#         if loaded by the shell or a load_env_file() call.
#         """
#         return cls(
#             scraper=ScraperConfig(
#                 request_timeout=int(os.getenv("SCRAPER_TIMEOUT", "30")),
#             ),
#             db_path=Path(os.getenv("DB_PATH", "data/app.db")),
#             log_level=os.getenv("LOG_LEVEL", "INFO"),
#         )
