# Phase B — Databricks Medallion (Bronze/Silver + data quality)

**Objective:** PySpark + Delta Lake processing on Databricks implementing the
Bronze → Silver layers with enforced data-quality expectations and quarantine —
the core Databricks evidence of the whole portfolio.

**Reusable branch:** `feat/lakehouse`

## Prerequisites

- [ ] Phase A running (raw data accumulating in ADLS).
- [ ] Databricks Free Edition account for development.
- [ ] Decision recorded (new ADR): Azure Databricks workspace deployed via Terraform
      (uncomment `azurerm_databricks_workspace`) for job runs, vs staying on Free
      Edition + local sample data until Phase C. Default: deploy late, destroy often.

## Tasks

1. **Bronze** (`databricks/bronze/`): notebook/job `bronze_ingest` — Auto Loader
   (`cloudFiles`) or batch `read.json` over `raw/{source}/{feed}/`, append to Delta
   `bronze.{feed}` adding `_ingested_at`, `_source_file`. No transformations. Schema
   hints only where the API JSON is ambiguous; let schema evolution be explicit
   (`mergeSchema` off — fail loudly, then decide).
2. **Silver** (`databricks/silver/`): per feed —
   - explicit typed schema (timestamps to UTC + a `local_date`/`local_hour` derived in
     Europe/Madrid; document the DST handling — interview favourite);
   - dedup on natural key (feed, interval start, zone/technology);
   - `MERGE INTO` upsert so replayed Bronze batches are idempotent;
   - **quality expectations**: prices ≥ 0 (PVPC can't be checked for negativity blindly
     — wholesale can go negative; document which feed allows what), demand within
     physical bounds, generation-mix shares ∈ [0,1] and sum ≈ 1, freshness within
     publication lag;
   - failures land in `silver.quarantine_{feed}` with reason + payload; run FAILS if
     rejection ratio > threshold (config, default 5%).
   Implement expectations either with Delta constraints + explicit checks or Great
   Expectations — pick one, record an ADR, and be able to defend it vs DLT
   expectations.
3. **Shared code**: pure transformation functions in `src/energy_lakehouse/transforms/`
   (typed, unit-tested with `pyspark` local session or `pytest` + chispa), imported by
   the notebooks — notebooks stay thin orchestration shells.
4. **Jobs** (`databricks/jobs/`): job definition (JSON/YAML) chaining bronze → silver
   per feed on a **job cluster** (not all-purpose), smallest node, auto-terminate.
   Schedule daily (batch layer); ADF hourly keeps landing raw regardless.
5. **Orchestration seam**: document (ADR or architecture note) how ADF and Databricks
   jobs relate — either ADF triggers the Databricks job (Databricks notebook activity;
   most consultancy-realistic) or independent schedules. Prefer ADF-triggered: it
   demonstrates the ADF↔Databricks integration interviewers ask about.
6. **Terraform**: uncomment/deploy the Databricks workspace when moving from Free
   Edition; add job + cluster config as code if practical (databricks provider —
   optional stretch).

## Deliverables

- `databricks/bronze/` + `databricks/silver/` notebooks (.py source format).
- `src/energy_lakehouse/transforms/` with unit tests (CI-runnable, no cluster).
- Quarantine tables populated by at least one deliberately-injected bad batch (test
  the gate honestly; document the experiment).
- Job definition in `databricks/jobs/` + screenshot/run-URL of a green scheduled run.

## Done criteria

- End-to-end: new raw file → Bronze append → Silver merge visible in table history,
  unattended, ≥ 1 week of green scheduled runs.
- Replaying a full day of Bronze produces zero Silver duplicates (MERGE proof).
- A poisoned batch lands in quarantine and (above threshold) fails the run.
- Can explain without notes: Delta transaction log + time travel; MERGE semantics;
  job vs all-purpose clusters and cost; Auto Loader vs batch reads; partitioning
  choice for these tables; why `.collect()` is dangerous.

## Cost estimate

Free Edition: $0 during development. Azure job runs: smallest job cluster ~minutes/day
→ expect **< $5/month**; destroy the workspace between active periods.
