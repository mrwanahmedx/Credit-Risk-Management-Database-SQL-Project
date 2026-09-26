# Changelog

## 2026-09-26 — privacy and repository-hygiene pass

- Replaced realistic-looking synthetic customer identifiers with deterministic fictional placeholders while preserving keys and analytical behavior.
- Added `PUBLIC_DATA_BOUNDARY.md` as a hard clean-room rule for future contributions.
- Moved the superseded data-cleaning script to `archive/`; `data_quality_checks.sql` remains the canonical release gate.


## 2026-09-26 — data contract and release-gate pass

### Added

- Canonical `data_quality_checks.sql` release-gate entry point.
- Explicit source-grain and join contract in `docs/DATA_CONTRACT.md`.
- Architecture documentation for grain-safe risk-data engineering.
- Hard-versus-soft reconciliation standard.

### Changed

- CI now executes the canonical data-quality file.
- README now leads with engineering controls and an explicit clean-room confidentiality boundary.
- The historical `-- data_cleaning_exploration.sql` file is retained as a legacy predecessor rather than deleted.

## 2026-09-26

### Fixed

- Corrected the `Payment_Schedule` insert column from `LateDays` to the schema-defined `DaysLate`.
- Corrected `Loan_Applications.Amount` in seed inserts to the schema-defined `RequestedAmount`.
- Corrected `Credit_Scores.Date` / `Score` in seed inserts to `ScoreDate` / `CreditScore`.

### Changed

- Rebuilt the sample analysis around explicit customer and loan grain instead of direct one-to-many joins.
- Added deterministic latest-credit-score and latest-risk-assessment logic with `ROW_NUMBER()`.
- Pre-aggregated `Payments` and `Payment_Schedule` before joining to loans to prevent fan-out and duplicated monetary totals.
- Replaced the original MIN/MAX credit-score “movement” query with chronological score movement using `LAG` plus first/latest observations.
- Added loan-grain duplicate release gates, primary-key diagnostics, orphan checks, amount/date quality checks, and reconciliation queries.
- Replaced `SELECT *` data-quality checks with explicit diagnostic columns.

The project remains a simulated learning database. These changes improve analytical correctness and engineering discipline; they do not turn the dataset into a production underwriting system.
