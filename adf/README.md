# Azure Data Factory

Pipeline definitions exported from the ADF workspace (JSON), version-controlled here and
deployed via CI. Nothing in this directory is hand-mocked: files appear only after the
corresponding pipeline exists and has run in the workspace.

Planned pipelines (Phase A):

- `pl_ingest_ree_demand` — REE apidatos demand → ADLS `raw/ree/demand/`, incremental
  watermark, retry policy.
- `pl_ingest_ree_generation` — generation mix, same pattern.
- `pl_ingest_esios_pvpc` — ESIOS PVPC hourly prices (token auth via Key Vault-backed
  linked service).

Layout once populated:

```
adf/
  pipeline/         pipeline JSON
  dataset/          dataset JSON
  linkedService/    linked service JSON (no secrets — Key Vault references only)
  trigger/          schedule triggers
```
