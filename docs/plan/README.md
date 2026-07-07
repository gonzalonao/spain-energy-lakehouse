# Project plan — phase index

One file per phase; each defines objective, prerequisites, tasks, deliverables, done
criteria and cost impact. Work phases in order — later phases assume earlier
infrastructure. Update the status table below whenever a phase advances.

| Phase | File | Scope | Status |
|---|---|---|---|
| A | [phase-a-adf-ingestion.md](phase-a-adf-ingestion.md) | ADF ingestion REE/ESIOS → ADLS raw, incremental watermarks | Not started |
| B | [phase-b-databricks-medallion.md](phase-b-databricks-medallion.md) | Databricks Bronze/Silver + data-quality gates | Not started |
| C | [phase-c-gold-powerbi.md](phase-c-gold-powerbi.md) | Gold star schema + Power BI report | Not started |
| D | [phase-d-cicd-environments.md](phase-d-cicd-environments.md) | CI/CD hardening, dev/prod separation | Not started |
| E1 | [phase-e1-streaming-kafka.md](phase-e1-streaming-kafka.md) | Kafka + Spark Structured Streaming (real-time demand) | Not started |
| E2 | [phase-e2-ml-forecasting.md](phase-e2-ml-forecasting.md) | Price forecasting on Gold | Not started |
| E3 | [phase-e3-weather-enrichment.md](phase-e3-weather-enrichment.md) | AEMET weather join | Not started |
| E4 | [phase-e4-dbt-warehouse.md](phase-e4-dbt-warehouse.md) | dbt models over the Gold layer | Not started |

**Sequencing rule:** A → B → C are the platform's spine and must ship in order. D can
start in parallel with B. E-phases are independent expansions after C; E1 is the
highest-value differentiator (streaming), E2–E4 in any order.

**Definition of done (every phase):** code merged to `develop` via its reusable branch,
CI green, done criteria checked in the phase file, `docs/cost-tracking.md` updated with
actual spend, README roadmap checkbox ticked, and a wiki learning note updated in
`workspace/wiki/learning/` (interview cheat-sheet style).
