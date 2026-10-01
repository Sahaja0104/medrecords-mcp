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
