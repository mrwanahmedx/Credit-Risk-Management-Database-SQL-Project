# Data Contract

This repository uses a fully simulated banking-style dataset. No employer or real customer data is used.

## Core grains

| Object | Intended grain | Primary/business key |
| --- | --- | --- |
| Customers | one row per borrower | `CustomerID` |
| Accounts | one row per account | `AccountID` |
| Loans | one row per facility | `LoanID` |
| Payments | one row per payment event | `PaymentID` |
| Payment_Schedule | one row per scheduled installment | `ScheduleID` |
| Credit_Scores | one score observation per borrower/date | `CustomerID, ScoreDate` |
| Risk_Assessment | one assessment per borrower/date | `CustomerID, AssessmentDate` |
| Loan_Applications | one row per application | `ApplicationID` |

## Join rules

1. Never join two one-to-many child tables directly to the same parent before reducing them to the target grain.
2. Select latest state deterministically with `ROW_NUMBER()`.
3. Aggregate payments and schedules to `LoanID` before joining them to loans.
4. Aggregate loans to `CustomerID` before combining them with customer-level latest state.
5. Every analytical mart must include a post-join uniqueness check at its declared grain.

## Release conditions

A mart is not considered valid if any of the following occur:

- duplicate rows at the declared grain,
- orphan foreign keys,
- impossible loan date ranges,
- negative payment/due amounts,
- negative delinquency values,
- silent row-count expansion after joins.

These controls are educational engineering examples, not regulatory policy.
