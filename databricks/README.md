# Databricks

PySpark notebooks and job definitions, organized by medallion layer. Notebooks are
committed as `.py` source files (Databricks Repos format) so they diff cleanly.

```
databricks/
  bronze/    raw JSON → append-only Delta (metadata columns only)
  silver/    typed, deduplicated, quality-validated Delta (+ quarantine writes)
  gold/      star-schema marts (fact_energy_hourly, dim_date, dim_technology, dim_zone)
  jobs/      job/workflow definitions (JSON/YAML) for scheduled runs
```

Layer contracts are defined in [docs/architecture.md](../docs/architecture.md).
Development happens on Databricks Free Edition; scheduled job runs use the Azure
workspace (see [ADR-0002](../docs/adr/0002-cost-strategy-free-tiers.md)).
