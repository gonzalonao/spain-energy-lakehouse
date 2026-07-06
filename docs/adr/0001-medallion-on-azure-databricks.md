# ADR-0001: Medallion architecture on Azure Databricks

Date: 2026-07-07 · Status: Accepted

## Context

The platform needs a processing architecture for hourly Spanish electricity-market data
(REE/ESIOS APIs) that scales from a portfolio demo to a realistic client-grade delivery,
and that matches the stack most demanded by consultancies operating in Spain
(Azure + Databricks + ADF).

## Decision

Adopt a Medallion (Bronze/Silver/Gold) lakehouse on Azure Databricks with Delta Lake on
ADLS Gen2, ingested by Azure Data Factory.

## Alternatives considered

- **Synapse/Fabric pipelines end-to-end** — already demonstrated in the
  flight-delay-propagation project (Fabric Lakehouse + DirectLake); repeating it adds no
  new evidence.
- **All-Databricks ingestion (Auto Loader only, no ADF)** — simpler, but ADF Copy
  pipelines with linked services/datasets/triggers are a specific consultancy skill worth
  demonstrating; Auto Loader remains an option for the streaming extension.
- **Warehouse-first (Snowflake + dbt)** — covered separately by the steam-toolkit
  retrofit; Spanish consultancy demand favours Databricks.

## Consequences

- Bronze/Silver/Gold layer contracts must be documented and enforced (see
  `docs/architecture.md`).
- Compute is decoupled from storage: dev work can run on Databricks Free Edition against
  sample data, while Azure jobs run on the student subscription.
- Power BI consumes only Gold — no BI coupling to raw structures.
