#!/usr/bin/env bash
# Day 1 bootstrap for medrecords-mcp. Run from the repo root (Git Bash / WSL / macOS / Linux).
set -euo pipefail

# ---------- folders ----------
mkdir -p src/medrecords/{db,vocab,synth,extraction/prompts,ingestion,query,mcp_server}
mkdir -p tests/{unit,integration,regression} eval samples docs frontend .github/workflows

for d in db vocab synth extraction ingestion query mcp_server; do
  touch "src/medrecords/$d/__init__.py"
done
touch src/medrecords/__init__.py tests/__init__.py tests/unit/__init__.py
touch docs/.gitkeep eval/.gitkeep samples/.gitkeep frontend/.gitkeep
touch tests/integration/.gitkeep tests/regression/.gitkeep

# ---------- .gitignore ----------
cat > .gitignore <<'EOF'
__pycache__/
*.pyc
.venv/
.env
data/
*.egg-info/
.pytest_cache/
.ruff_cache/
.idea/
.vscode/
node_modules/
# Never commit real reports. Synthetic PDFs under samples/ are allowed.
*.pdf
!samples/**/*.pdf
EOF

# ---------- pyproject.toml ----------
cat > pyproject.toml <<'EOF'
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "medrecords-mcp"
version = "0.0.1"
description = "MCP server over structured lab reports extracted with OCR and LLMs"
requires-python = ">=3.11"
dependencies = [
    "pydantic-settings>=2.2",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "ruff>=0.5",
    "pre-commit>=3.7",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.ruff]
line-length = 100
src = ["src", "tests"]

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF

# ---------- .env.example ----------
cat > .env.example <<'EOF'
# Copy to .env (never commit .env)
MEDREC_DATABASE_URL=sqlite:///data/medrecords.db
MEDREC_DATA_DIR=data
EOF

# ---------- config ----------
cat > src/medrecords/config.py <<'EOF'
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """App settings, overridable via MEDREC_* environment variables or a .env file."""

    model_config = SettingsConfigDict(env_file=".env", env_prefix="MEDREC_")

    database_url: str = "sqlite:///data/medrecords.db"
    data_dir: Path = Path("data")


settings = Settings()
EOF

# ---------- smoke test ----------
cat > tests/unit/test_config.py <<'EOF'
from medrecords.config import Settings


def test_defaults_to_sqlite(monkeypatch):
    monkeypatch.delenv("MEDREC_DATABASE_URL", raising=False)
    assert Settings(_env_file=None).database_url.startswith("sqlite")


def test_database_url_can_be_overridden(monkeypatch):
    monkeypatch.setenv("MEDREC_DATABASE_URL", "postgresql://u:p@localhost/db")
    assert Settings(_env_file=None).database_url.startswith("postgresql")
EOF

# ---------- pre-commit ----------
cat > .pre-commit-config.yaml <<'EOF'
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: end-of-file-fixer
      - id: trailing-whitespace
      - id: check-added-large-files
EOF

# ---------- CI ----------
cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: pip
      - run: pip install -e ".[dev]"
      - run: ruff check .
      - run: ruff format --check .
      - run: pytest
EOF

# ---------- README ----------
cat > README.md <<'EOF'
# MedRecords MCP

An MCP server that lets AI assistants query structured lab report data.
Reports are ingested through an OCR + LLM extraction pipeline, validated, and stored locally.

**Status:** in development (Day 1: project skeleton).

> Uses synthetic data only. Do not commit real patient reports.

## Setup

```bash
python -m venv .venv
source .venv/bin/activate        # Windows (PowerShell): .venv\Scripts\Activate.ps1
pip install -e ".[dev]"
pre-commit install
pytest
```
EOF

echo "Day 1 skeleton created."
