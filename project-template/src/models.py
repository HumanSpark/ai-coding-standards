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

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum


# TODO: Replace these examples with your project's actual data structures.
# Keep frozen=True unless you have a specific reason for mutability.

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
