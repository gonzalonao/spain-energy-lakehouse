# Phase E3 — AEMET weather enrichment

**Objective:** multi-source integration — join Spanish weather (AEMET OpenData) to the
energy model, enabling "demand vs temperature" and better forecasting features. Also
creates a natural data-sharing seam with the `aws-serverless-etl` project (same source,
different cloud — a deliberate compare-and-contrast portfolio angle).

**Reusable branch:** `feat/ingestion`

## Tasks

1. **Source**: AEMET OpenData API (free key). Feeds: daily climatological values +
   hourly observations for a fixed set of provincial-capital stations. AEMET's API is
   two-step (request → temporary data URL) and quota-limited — wrap it in a typed
   client with polite retry/backoff in `src/energy_lakehouse/sources/`.
2. **Ingest**: extend the generic ADF pipeline (Phase A pattern) or ingest via the
   Python client scheduled in Databricks — decide by cost/simplicity, record the
   choice. Land in `raw/aemet/…`, flow Bronze → Silver with its own expectations
   (temperature bounds, station-id validity).
3. **Model**: `gold.dim_station` (station → province/zone mapping) and
   `gold.fact_weather_daily`/`_hourly`; conform zones so weather joins the energy
   facts cleanly.
4. **Analytics payoff**: demand-vs-temperature curve in Power BI (the classic
   "cooling/heating degree days" view); feed features into Phase E2 if built.

## Deliverables

- AEMET client + tests; ingestion path; weather Bronze/Silver/Gold.
- Zone-conformance mapping documented.
- Power BI weather-demand page.

## Done criteria

- Weather arrives unattended alongside energy data; a join query answers "demand vs
  temperature by province" with correctly aligned local dates.
- Can explain without notes: AEMET's two-step API pattern; conforming dimensions
  across sources; handling late/missing station data.

## Cost estimate

Negligible — rides existing infrastructure.
