# Public Data & Confidentiality Boundary

This repository is a clean-room public portfolio project. Its schema, seed data and analytical logic are illustrative and must remain separate from employment work.

## Allowed

- deterministic synthetic data created for this repository,
- public methods and generic relational-design patterns,
- generic credit-risk concepts used only for educational engineering examples.

## Never publish

- employer or customer data,
- internal schemas, table or column names, SQL, screenshots or reports,
- proprietary thresholds, model parameters, approval logic or monitoring outputs,
- credentials, account identifiers or personal financial information,
- restricted or licensed datasets that cannot be redistributed.

## Clean-room rule

Renaming a private field is not enough. Public code must be independently designed from public concepts or synthetic data. If provenance is uncertain, do not publish.

The customer names, emails, phone values and addresses in `database.sql` are deterministic fictional placeholders such as `Synthetic Borrower001` and `borrower001@example.invalid`.
