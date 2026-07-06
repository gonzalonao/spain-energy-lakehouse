# Cost tracking

Cloud spend is tracked per phase against the $80/year Azure student credit, the way a
consultancy tracks billable cloud consumption for a client. Strategy: [ADR-0002](adr/0002-cost-strategy-free-tiers.md).

| Date | Phase | Resource | Action | Est. cost | Actual (credit used) |
|---|---|---|---|---|---|
| 2026-07-07 | Scaffold | — | Repo + design only, no cloud resources | $0.00 | $0.00 |

## Budget guardrails

- Azure budget alert at $40 (50% of credit).
- All resources tagged `project=spain-energy-lakehouse`; costs filtered by tag in Cost
  Management.
- Job clusters with auto-termination ≤ 15 min; no always-on compute.
- `terraform destroy` between active development periods.
