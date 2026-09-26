# Release History

## v1.0.0 — Grain-Safe SQL Engineering Baseline — 2026-09-26

First formally versioned engineering baseline.

### Included

- corrected schema / seed column mismatches,
- explicit customer and loan grain,
- deterministic latest-record logic,
- pre-aggregation before one-to-many joins,
- anti-fan-out release gates,
- orphan and data-quality reconciliation checks,
- chronological credit-score movement,
- executable SQLite CI.

### Evidence

The CI builds the schema, loads seed data, runs the reconciliation pack, and executes the analytical queries successfully.

This is a simulated portfolio database, not a production underwriting system.
