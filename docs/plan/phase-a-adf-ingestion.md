# Phase A — ADF ingestion (REE/ESIOS → ADLS raw)

**Objective:** real, parametrized Azure Data Factory pipelines landing hourly Spanish
electricity data in ADLS Gen2 with incremental watermark loads — the classic
consultancy Copy-pipeline pattern (linked services, datasets, parameters, triggers).

**Reusable branch:** `feat/ingestion`

## Prerequisites

- [ ] ESIOS personal token received (email to consultasios@ree.es) and stored as an
      environment secret — never committed.
- [ ] Azure student subscription active; budget alert created at $40.
- [ ] `terraform apply` of the current skeleton (RG + storage + containers + ADF)
      against `environments/dev.tfvars` — this is the first real deploy; record spend.

## Tasks

1. **Explore the APIs locally first** (no cloud cost): small typed Python client in
   `src/energy_lakehouse/sources/` for the three feeds —
   - REE `apidatos.ree.es`: `demanda/evolucion`, `generacion/estructura-generacion`
     (hourly, JSON, no auth);
   - ESIOS: indicator `1001` (PVPC) via `Authorization: Token token=...`.
   Unit-test the response parsing with recorded tiny fixtures. This client is also the
   fallback ingestion path and the future streaming producer's base.
2. **Design the raw layout** (document in `docs/architecture.md` if it deviates):
   `raw/{source}/{feed}/ingest_date=YYYY-MM-DD/part-*.json`, one file per API window.
3. **Build the watermark control**: a small Delta (or ADLS JSON) control table
   `_control/watermarks` keyed by feed, storing last-loaded interval end. Decide and
   document the rerun semantics: a rerun of a window overwrites the same path
   (idempotent), watermark advances only after success.
4. **Author ADF resources in the workspace** (dev):
   - Linked services: HTTP (REE), HTTP (ESIOS, token via Key Vault or secure string),
     ADLS Gen2 (managed identity).
   - Datasets: parametrized REST/JSON source, parametrized ADLS sink.
   - Pipeline `pl_ingest_feed` (single generic pipeline, parametrized by feed —
     the consultancy pattern — not one pipeline copy-pasted per feed): Lookup
     (watermark) → Copy (REST → ADLS, window `[watermark, now)`) → on success:
     Stored-watermark update; retry policy 3× exponential; on failure: leave watermark.
   - Schedule trigger: hourly for PVPC/demand (or every 3 h to reduce activity count —
     decide by cost).
5. **Export the JSON definitions** into `adf/` (pipeline/, dataset/, linkedService/,
   trigger/) once running. Strip/parameterize anything environment-specific; verify no
   secret material in the exports.
6. **Backfill**: run the pipeline over a 30–90 day historical window (bounded, to
   control activity-run cost) so Phase B has volume to process.
7. **Terraform**: uncomment nothing yet (Databricks comes in Phase B); add any ADF
   supporting resources (Key Vault if used) to `infra/terraform/`.

## Deliverables

- `src/energy_lakehouse/sources/` typed clients + tests.
- `adf/` exported, secret-free pipeline/dataset/linked-service/trigger JSON.
- Watermark design note (section in `docs/architecture.md` — already drafted; adjust
  to what was actually built).
- ≥ 30 days of raw data in ADLS, hourly cadence running unattended for ≥ 1 week.

## Done criteria

- A scheduled run ingests only the new window (verified from run history: window
  parameters shrink to the delta).
- Killing a run mid-copy and rerunning produces no duplicates and no gaps.
- `docs/cost-tracking.md` updated with actual ADF activity-run + storage spend.
- Can explain without notes: linked service vs dataset vs pipeline vs trigger;
  integration runtime types; how watermark loads differ from tumbling-window triggers
  (and why one was chosen).

## Cost estimate

ADF: ~$1/1000 activity runs + per-DIU copy time — at hourly cadence expect **< $3/month**.
ADLS: pennies at this volume. Well inside the $80 credit.

## Risks / notes

- ESIOS token quota/latency unknown until tested — keep the local client as fallback
  and rate-limit politely.
- REE API occasionally returns gaps for the most recent hour; the freshness check in
  Phase B must tolerate the documented publication lag, not mask real failures.
