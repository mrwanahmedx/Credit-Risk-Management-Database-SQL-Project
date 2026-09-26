# Changelog

## 2026-09-26

### Fixed

- Corrected the `Payment_Schedule` insert column from `LateDays` to the schema-defined `DaysLate`.

### Changed

- Rebuilt the sample analysis around explicit customer and loan grain instead of direct one-to-many joins.
- Added deterministic latest-credit-score and latest-risk-assessment logic with `ROW_NUMBER()`.
- Pre-aggregated `Payments` and `Payment_Schedule` before joining to loans to prevent fan-out and duplicated monetary totals.
- Replaced the original MIN/MAX credit-score “movement” query with chronological score movement using `LAG` plus first/latest observations.
- Added loan-grain duplicate release gates, primary-key diagnostics, orphan checks, amount/date quality checks, and reconciliation queries.
- Replaced `SELECT *` data-quality checks with explicit diagnostic columns.

The project remains a simulated learning database. These changes improve analytical correctness and engineering discipline; they do not turn the dataset into a production underwriting system.
