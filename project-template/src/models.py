# File: src/projectname/models.py
# Purpose: Shared data structures that flow between modules.
# Project: {ProjectName} | Date: {YYYY-MM-DD}
#
# Overview: Defines the typed data structures (dataclasses) that form the
# contract between modules. All inter-module data flows through types
# defined here. Use frozen dataclasses for immutability - modules receive
# data, they don't modify it. If you need a modified version, create a
# new instance.
#
# Use Pydantic models at validation boundaries only (API responses,
# config file parsing, user input). For internal data flow, dataclasses
# are lighter and have no external dependencies.
#
# If this file approaches 300 lines, split by domain area into a
# models/ package with per-domain files.

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum


# --- Base exception with mandatory hint ---
# All project exceptions should inherit from this. The hint field forces
# you to write a human-friendly suggestion at every raise site.

class HintedError(Exception):
    """Base exception requiring a human-friendly hint.

    Usage:
        raise ServiceError(
            "gws returned exit code 1 (stderr: 'token expired')",
            hint="Try running 'gws auth login' to refresh your credentials"
        )

    Output:
        [gdrive] push failed: gws returned exit code 1 (stderr: "token expired")
          → Try running 'gws auth login' to refresh your Google credentials
    """

    def __init__(self, message: str, *, hint: str) -> None:
        super().__init__(message)
        self.hint = hint

    def __str__(self) -> str:
        return f"{super().__str__()}\n  → {self.hint}"


# TODO: Replace these examples with your project's actual data structures
# and exception types. Keep frozen=True unless you have a specific reason
# for mutability.

# Example project exception (inherits HintedError):
#
# class FetchError(HintedError):
#     """Raised when an external resource cannot be fetched."""
#     pass

# Example enum for status tracking:
#
# class ItemStatus(Enum):
#     NEW = "new"
#     PROCESSED = "processed"
#     FAILED = "failed"

# Example frozen dataclass:
#
# @dataclass(frozen=True)
# class Item:
#     """A single item flowing through the pipeline.
#
#     Frozen so modules can't modify shared state. If a module needs
#     to add information (e.g. a score), define a new dataclass that
#     wraps this one (e.g. ScoredItem with an Item field).
#     """
#     id: str
#     title: str
#     content: str
#     created: datetime
#     url: str = ""
