# Reconciliation Standard

The repository treats reconciliation as part of the analytical design, not as an afterthought.

## Hard gates

These should return zero exceptions:

- duplicate customer/account/loan keys,
- orphan relationships,
- invalid loan dates,
- negative scheduled amounts,
- negative payments,
- negative days-past-due values,
- duplicate rows after a loan-grain or customer-grain mart is assembled.

## Soft reconciliations

These are reviewed rather than expected to be zero:

- loan counts and principal by status,
- loan counts and principal by product,
- credit-score observation coverage,
- delinquency distribution,
- application-status totals.

## Why this matters

A query can be syntactically correct and still be analytically wrong. The most common example in this project is fan-out: joining multiple one-to-many tables before aggregation can overstate balances or payment totals without raising a SQL error.

The release pattern is therefore:

`source checks -> reduce to intended grain -> join -> uniqueness check -> analytical output`.
