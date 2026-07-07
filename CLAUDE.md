# CLAUDE.md — spain-energy-lakehouse

> Universal git, code and Python rules live in the workspace files
> (`../../CLAUDE.md`, `../.claude/rules/python.md`). This file adds
> project-specific rules and context only.

## What this project is

End-to-end Azure lakehouse over the Spanish electricity market (REE `apidatos.ree.es`,
no token; ESIOS API, personal token via email request). Built deliberately in the shape
a technology consultancy (EY / NTT Data style) delivers a client platform: ADF
ingestion → ADLS Gen2 → Databricks Medallion (Delta) → Power BI, with Terraform IaC,
CI/CD, ADRs and cost tracking.

Portfolio context: this is the flagship Data Engineering project of the upskill plan in
`workspace/wiki/learning/data-engineer-upskill-plan.md` (P1). Its primary evidence
targets are **Azure Data Factory, Databricks/PySpark, Delta Lake, Terraform, data
quality, and (Phase E1) Kafka streaming**.

## Plans — read before building

- **`docs/plan/README.md`** — phase index, sequencing, live status table. Update the
  status table whenever a phase advances.
- One plan file per phase under `docs/plan/` (phase-a … phase-e4). Each has tasks,
  deliverables and done criteria. Do not start a phase without reading its file; do not
  mark it done until every done-criterion is met.
- Architecture contracts live in `docs/architecture.md`; decisions in `docs/adr/`
  (add a new ADR for any decision that changes architecture, tooling or cost posture).

## Branching model

develop-flow (workspace standard): `feature/*` off `develop`, merged into `develop`;
`develop` → `main` only via PR after Gonzalo's review. Reusable branches per workstream:

- `feat/ingestion` — ADF pipelines + ingestion utilities (Phase A)
- `feat/lakehouse` — Databricks notebooks bronze/silver/gold (Phases B–C)
- `feat/infra` — Terraform + CI/CD (Phase D and infra changes in any phase)
- `feat/streaming` — Kafka/Structured Streaming extension (Phase E1)

## Non-negotiable project rules

- **Nothing fake, ever.** No mocked pipeline JSON, no placeholder resources deployed,
  no screenshots of things that didn't run. If a piece is design-only, label it
  "design — not implemented". (Lesson from flight-delay's `pl_fake_ingestion.json`.)
- **Cost discipline**: every deployed resource is tagged `project=spain-energy-lakehouse`;
  update `docs/cost-tracking.md` after each phase with actual spend; job clusters only,
  auto-termination ≤ 15 min; `terraform destroy` between active periods (ADR-0002).
- **Secrets**: ESIOS token and any Azure credentials via environment / Key Vault
  references only. Never in code, ADF JSON exports, notebooks or commits.
- **Data**: no datasets in git (`data/`, `*.parquet`, `*.csv` are gitignored). Sample
  fixtures for tests must be tiny and synthetic.
- ADF artifacts are committed as exported JSON under `adf/` only after the pipeline
  exists and has run in the workspace.
- Databricks notebooks are committed as `.py` source format under `databricks/`.

## Key commands

```powershell
uv sync                                  # env + dev deps
uv run ruff format .; uv run ruff check .; uv run mypy; uv run pytest   # quality gate (same as CI)
cd infra\terraform; terraform fmt -recursive; terraform validate        # IaC gate
terraform plan -var-file="environments\dev.tfvars"
```

## Reporting changes

After completing any change, finish with a detailed numbered list of steps Gonzalo can
follow to verify it himself — exact PowerShell commands from the repo root, URLs to
open, and what a correct result looks like. Call out anything not self-verified (e.g.
cloud runs needing his credentials).
