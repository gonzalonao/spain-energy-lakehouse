# Phase E2 — ML price forecasting on Gold

**Objective:** a disciplined forecasting model over the Gold layer — connects the DE
platform to Gonzalo's ML strengths (PyTorch, eval rigor from boe-rag) without turning
the repo into an ML project. Scope: small, honest, well-evaluated.

**Reusable branch:** `feat/lakehouse` (or `feat/forecasting` if it grows)

## Tasks

1. **Frame the problem**: predict next-24 h hourly PVPC from Gold features (lagged
   prices, demand, generation mix, calendar/dim_date incl. holidays). Write the
   framing + leakage rules (no future info, walk-forward splits) in a short design
   note before any training.
2. **Baselines first**: naive (t-24), seasonal-naive (t-168), then gradient boosting
   (LightGBM/XGBoost) on tabular features. A neural model only if it beats GBM
   honestly — the boe-rag "measured, didn't ship" pattern is the portfolio story.
3. **Evaluation**: MAE/RMSE + pinball loss if quantiles; walk-forward over ≥ 2 months;
   bootstrap CIs on the improvement vs baseline (reuse the statistical-rigor approach
   from boe-rag `eval/stats.py`).
4. **Productionize lightly**: daily batch inference notebook/job writing
   `gold.fact_price_forecast` (forecast + generated_at + model version); Power BI
   forecast-vs-actual page with error tracking over time.
5. **Track experiments**: MLflow (built into Databricks, incl. Free Edition) — params,
   metrics, model registry; this is the Databricks-native MLOps evidence.

## Deliverables

- Design note (framing, leakage rules, split scheme).
- Training + inference code under `src/energy_lakehouse/forecasting/` with tests;
  notebooks thin as usual.
- `gold.fact_price_forecast` refreshed daily; Power BI forecast page.
- Honest results write-up (`reports/forecasting.md`): baselines vs model, CIs.

## Done criteria

- Forecast lands daily unattended; dashboard shows rolling forecast error.
- The write-up states clearly whether the ML model earns its keep vs seasonal-naive.
- Can explain without notes: leakage traps in time series; walk-forward CV; why
  seasonal-naive is a hard baseline for electricity prices; MLflow model registry flow.

## Cost estimate

Training on local GPU / Free Edition: $0. Daily inference rides the existing job
cluster: negligible.
