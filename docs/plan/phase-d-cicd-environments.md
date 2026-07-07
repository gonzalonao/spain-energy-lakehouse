# Phase D — CI/CD hardening + dev/prod environments

**Objective:** turn "it runs" into "it deploys" — the engineering-practice layer that
reads consultancy-grade: environment separation, gated releases, IaC as the only path
to change. Can start in parallel with Phase B.

**Reusable branch:** `feat/infra`

## Tasks

1. **Terraform workspaces/environments**: make `dev` and `prod` cleanly separable
   (already parameterized via `environments/*.tfvars`); decide state backend — local
   state is fine for a solo project but **document** what a team setup would use
   (azurerm backend + state locking) in an ADR.
2. **CI (already scaffolded — harden)**:
   - keep quality + terraform jobs; add `terraform plan` output as PR comment
     (dev vars) using a read-only service principal — **only if** credential handling
     is clean; otherwise document the manual plan-review flow.
3. **CD**:
   - merge to `develop` → deploy to dev: apply Terraform (manual approval environment
     gate in GitHub Actions), publish ADF artifacts (adf/ JSON via
     `az datafactory` or ADF's own git-integration — decide, ADR; ADF git-mode is the
     consultancy-standard answer), deploy Databricks job configs;
   - tag `v*` on `main` → prod deploy, same steps, prod vars.
4. **Secrets**: GitHub environments (`dev`, `prod`) with OIDC federated credentials to
   Azure (no long-lived client secrets) — this is a strong senior-reading detail and
   free.
5. **Observability minimum**: pipeline-failure alerting — ADF alert rule or a GitHub
   Actions scheduled canary that checks yesterday's partitions exist and opens an
   issue on gaps (pattern proven in boe-rag-assistant's refresh workflow).
6. **Docs**: `docs/deployment.md` — how a change travels from branch to prod; include
   the rollback story (`terraform` state + Delta time travel + ADF publish rollback).

## Deliverables

- Working dev CD from `develop`; tag-gated prod path (may stay dormant until Phase C
  is prod-worthy).
- OIDC auth, no stored cloud secrets.
- `docs/deployment.md` + ADRs (state backend, ADF deployment mode).
- Failure alerting proven by one forced failure.

## Done criteria

- A one-line change lands in dev with zero console clicks.
- Can explain without notes: Terraform state & locking; OIDC vs client secrets; ADF
  git-integration publish flow; environment-gated deployments in GitHub Actions.

## Cost estimate

$0 (GitHub Actions free tier; alert rules pennies).
