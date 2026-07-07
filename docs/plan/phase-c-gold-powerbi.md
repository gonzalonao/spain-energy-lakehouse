# Phase C — Gold star schema + Power BI

**Objective:** business-ready dimensional layer and the Power BI report that closes the
"built the whole platform" story — from API to executive dashboard. This phase converts
Gonzalo's proven Power BI strength into evidence that the *upstream* engineering is his
too.

**Reusable branch:** `feat/lakehouse`

## Prerequisites

- [ ] Phase B green ≥ 1 week (Silver stable).

## Tasks

1. **Model the star** (document the model diagram in `docs/architecture.md`):
   - `gold.fact_energy_hourly` — grain: 1 row per hour × zone × measure set (PVPC
     price, demand MW, CO₂ intensity); FKs to dims; no raw identifiers.
   - `gold.fact_generation_hourly` — grain: hour × technology × zone, MW + share.
   - `gold.dim_date` (calendar incl. Spanish holidays — nice analytical touch),
     `gold.dim_technology` (renewable flag, dispatchable flag), `gold.dim_zone`.
   - SCD stance: dims here are effectively static → SCD1; *write down* how SCD2 would
     be added (interview drill), don't build it artificially.
2. **Build Gold notebooks** (`databricks/gold/`): Silver → Gold as `MERGE`/full
   refresh per table (justify per table); same thin-notebook + tested-transforms
   pattern as Phase B.
3. **Serving decision (ADR)**: Power BI connection —
   - default: **import mode** from Delta via Databricks SQL warehouse serverless
     (watch cost) or from Parquet export;
   - document why DirectLake wasn't used (that's Fabric — already demonstrated in the
     TFM; avoid duplicate evidence) and what DirectQuery would cost.
4. **Power BI report** (`powerbi/` new dir; commit the `.pbip`/PBIR source format, not
   binary `.pbix`, so diffs are reviewable):
   - pages: price trends (PVPC hourly/daily, rolling averages), demand vs generation
     mix (stacked area by technology), renewables share KPI, CO₂ intensity;
   - DAX time intelligence (YTD, rolling 12 m, prior-period deltas) — his PL-300
     muscle, visible in a DE project;
   - RLS example (e.g. zone-restricted role) to show governance awareness.
5. **Refresh path**: scheduled refresh in Power BI Service post-Gold-job; document the
   trigger chain end to end (ADF → Databricks → PBI refresh via REST or schedule).
6. **README**: add dashboard screenshot + a "data flow in one picture" section.

## Deliverables

- `databricks/gold/` notebooks + tested transforms.
- `powerbi/` report source (PBIR) + screenshot in README.
- Star-schema diagram + serving ADR.

## Done criteria

- A business question ("¿cuál fue la hora más cara de ayer y qué generaba en ese
  momento?") answerable in the report with data that arrived through the full
  pipeline unattended.
- Refresh chain runs end-to-end on schedule for ≥ 1 week.
- Can explain without notes: star vs snowflake trade-offs; fact grain decisions;
  SCD1/2; import vs DirectQuery vs DirectLake; why Gold is the only BI-visible layer.

## Cost estimate

Databricks SQL serverless is the only material risk — prefer import-from-export if the
warehouse idles > pennies. Target **< $5/month**.
