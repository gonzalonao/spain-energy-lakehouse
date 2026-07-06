# Streaming extension (Phase E1)

Real-time layer over the same lakehouse: REE publishes national electricity demand at
10-minute cadence, which this extension moves through a Kafka topic into a streaming
Delta table.

Planned components:

- `producer/` — Python producer polling REE real-time demand → Kafka topic
  `energy.demand.realtime` (Avro, schema registry).
- `docker-compose.yml` — local Redpanda (Kafka-compatible) + console for development.
- `spark/` — Spark Structured Streaming job: topic → Bronze streaming Delta table,
  merged into the Silver model shared with the batch pipeline.
- `docs/event-hubs-mapping.md` — how the local Kafka setup maps 1:1 to Azure Event Hubs'
  Kafka endpoint for a cloud deployment (bounded demo window per cost strategy).

This directory is a placeholder until Phases A–C of the batch platform are complete.
