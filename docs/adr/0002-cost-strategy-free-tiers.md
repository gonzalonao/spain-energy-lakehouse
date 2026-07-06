# ADR-0002: Cost strategy — free tiers first, student credit for cloud-native pieces

Date: 2026-07-07 · Status: Accepted

## Context

Budget is a $80/year Azure student credit plus free tiers. A consultancy would treat
cloud spend as a client-billable line item; this project treats the credit the same way
and documents consumption in `docs/cost-tracking.md`.

## Decision

- **Development** runs where it is free: Databricks Free Edition for notebook/PySpark
  development, local sample data, local Spark where practical.
- **Azure credit** is reserved for the pieces that only count as evidence when real:
  ADF pipelines (per-activity pricing, cents per run), ADLS Gen2 storage (GBs, cents),
  and short Databricks job-cluster runs.
- **Cost controls**: job clusters only (no always-on all-purpose clusters), auto-
  termination ≤ 15 min, budget alert at 50% of credit, every deployed resource tagged
  `project=spain-energy-lakehouse`.
- **Streaming dev** uses local Redpanda (Kafka-compatible, free); the Event Hubs Kafka
  endpoint mapping is documented but only deployed for a bounded demo window.

## Consequences

- Some screenshots/artifacts come from Free Edition rather than the Azure workspace;
  each doc states which environment produced it.
- Terraform must make the expensive pieces destroyable and re-creatable
  (`terraform destroy` safe), so the platform can be torn down between demo periods.
- `docs/cost-tracking.md` is updated with actual spend after each phase — cost awareness
  is part of the portfolio story.
