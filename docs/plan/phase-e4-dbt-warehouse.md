# Phase E4 — dbt over the warehouse layer

**Objective:** bring dbt discipline (tested, documented, lineage-visible SQL models) to
this platform's serving layer, complementing the steam-toolkit dbt work with the
Databricks adapter flavor consultancies actually deploy.

**Reusable branch:** `feat/lakehouse`

## Prerequisites

- [ ] Phase C shipped (Gold exists).
- [ ] steam-toolkit dbt phases done (learn dbt fundamentals there first — this phase
      is the "same skill, consultancy platform" second rep).

## Tasks

1. **Scope decision (ADR)**: dbt owns Silver→Gold (replacing the Gold notebooks) —
   the honest consultancy pattern — vs dbt as a semantic/test layer on top. Default:
   migrate Silver→Gold into dbt models (`dbt-databricks` adapter, SQL warehouse or
   cluster), keeping Bronze→Silver in PySpark where expectations/quarantine live.
2. **Project** (`dbt/`): sources = Silver tables (with freshness checks — dbt source
   freshness replaces the hand-rolled freshness check at this layer); staging views;
   marts = the Phase C star. Incremental models where grain allows (hourly facts →
   `incremental` with `unique_key`, insert_overwrite by date partition).
3. **Tests + docs**: not_null/unique/relationships/accepted_values on keys and dims;
   `dbt docs generate` published (GitHub Pages of this repo or artifact) — lineage
   graph is the recruiter-visible payoff.
4. **CI**: dbt build against a dev schema on PRs touching `dbt/` (needs a reachable
   warehouse — if cost forbids, run `dbt build` in the dev CD step instead and
   `dbt parse`+`dbt compile` in CI; document the trade-off).
5. **Retire** the replaced Gold notebooks (delete, don't leave dead code — repo
   hygiene rule).

## Deliverables

- `dbt/` project on `dbt-databricks`; Gold produced by `dbt build`.
- Published dbt docs/lineage; CI/CD integration per the recorded trade-off.

## Done criteria

- `dbt build` is the only path that produces Gold; tests gate it.
- Can explain without notes: incremental model strategies on Databricks; source
  freshness; dbt on lakehouse vs warehouse; ref() DAG vs Airflow-style orchestration
  (and why both exist in real stacks).

## Cost estimate

dbt Core: $0. Warehouse compute for runs: minutes/day on existing budget posture.
