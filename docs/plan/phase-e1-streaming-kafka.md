# Phase E1 — Streaming: Kafka + Spark Structured Streaming

**Objective:** the differentiator — a real-time layer over the same lakehouse. REE
publishes national demand at ~10-minute cadence; move it through a Kafka topic into a
streaming Delta table that merges into the same Silver model as batch (lambda-style
unification). Kafka is the top junior-DE differentiator in the Spanish market scan.

**Reusable branch:** `feat/streaming`

## Prerequisites

- [ ] Phases A–C shipped (the streaming story lands on top of a working batch spine).

## Tasks

1. **Local Kafka dev stack** (`streaming/docker-compose.yml`): Redpanda (Kafka-API
   compatible, single binary) + Redpanda Console. Topic `energy.demand.realtime`,
   keyed by zone, **Avro** schema + schema registry (Redpanda's) — schema evolution is
   the interview topic, don't skip it for JSON convenience.
2. **Producer** (`streaming/producer/`, typed Python in `src/energy_lakehouse/`):
   polls REE real-time demand every 10 min, publishes one event per interval;
   idempotent keys (zone + interval start) so re-polls don't create logical dupes;
   unit-tested with a fake producer.
3. **Consumer — Spark Structured Streaming** (`streaming/spark/`): topic → Bronze
   streaming Delta table (`bronze.demand_stream`), checkpointed; then `foreachBatch`
   MERGE into the same `silver.demand` used by batch — **document the batch/stream
   reconciliation rule** (stream is provisional, nightly batch is authoritative —
   or last-writer-wins; decide and write it down, this is the design conversation
   that matters).
4. **Delivery semantics note** (`streaming/docs/`): where this setup sits —
   at-least-once from the poller, effectively-once in Delta via MERGE keys +
   checkpoints; what exactly-once would require. Honest and precise beats buzzwords.
5. **Cloud mapping** (`streaming/docs/event-hubs-mapping.md`): how the local stack
   maps 1:1 to Azure Event Hubs' Kafka endpoint (connection string as SASL, no code
   change), with cost estimate; deploy for one bounded demo window only if credit
   allows (ADR-0002), capture evidence, tear down.
6. **Dashboard hook** (optional): a "current demand vs forecast" tile fed by the
   streaming Silver — closes the loop visibly.

## Deliverables

- Working local pipeline: poll → Kafka (Avro) → Structured Streaming → Delta MERGE.
- Schema registry with ≥ 2 schema versions (do one deliberate evolution).
- Delivery-semantics + batch/stream reconciliation docs.
- Event Hubs mapping doc (+ optional bounded cloud demo).

## Done criteria

- Kill and restart the Spark job mid-stream: no data loss, no duplicates in Silver
  (checkpoint + MERGE proof).
- Evolve the Avro schema (add optional field): producer and consumer keep running.
- Can explain without notes: partitions/consumer groups/offsets; keyed compaction;
  at-least/at-most/exactly-once; how Structured Streaming checkpoints work; Event
  Hubs vs Kafka trade-offs.

## Cost estimate

Local: $0. Optional Event Hubs demo: Basic tier ~$0.4/day — bound it to a week max.
