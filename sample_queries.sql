-- ============================================================
-- CREDIT RISK MANAGEMENT DATABASE
-- Engineering-oriented analytical queries
--
-- Design rule:
--   1) declare the intended grain,
--   2) reduce one-to-many sources before joining,
--   3) use deterministic latest-record logic,
--   4) reconcile the final grain after joins.
-- ============================================================


-- ============================================================
-- 1. Loan analytical base
-- Target grain: exactly one row per LoanID.
--
-- Why this structure:
-- Payments and Payment_Schedule are both one-to-many to Loans.
-- Joining them directly would multiply rows and overstate totals.
-- Aggregate each child source first, then join the aggregates.
-- ============================================================

WITH latest_score_ranked AS (
    SELECT
        cs.CustomerID,
        cs.ScoreDate,
        cs.CreditScore,
        ROW_NUMBER() OVER (
            PARTITION BY cs.CustomerID
            ORDER BY cs.ScoreDate DESC, cs.CreditScore DESC
        ) AS rn
    FROM Credit_Scores AS cs
),
latest_score AS (
    SELECT
        CustomerID,
        ScoreDate,
        CreditScore
    FROM latest_score_ranked
    WHERE rn = 1
),
payment_agg AS (
    SELECT
        p.LoanID,
        COUNT(*) AS PaymentCount,
        SUM(COALESCE(p.PaymentAmount, 0.0)) AS TotalPayments,
        MAX(p.PaymentDate) AS LastPaymentDate
    FROM Payments AS p
    GROUP BY p.LoanID
),
schedule_agg AS (
    SELECT
        ps.LoanID,
        COUNT(*) AS ScheduledInstallments,
        SUM(COALESCE(ps.DueAmount, 0.0)) AS TotalDue,
        SUM(COALESCE(ps.PaidAmount, 0.0)) AS TotalScheduledPaid,
        MAX(COALESCE(ps.DaysLate, 0)) AS MaxDaysLate,
        AVG(COALESCE(ps.DaysLate, 0) * 1.0) AS AvgDaysLate
    FROM Payment_Schedule AS ps
    GROUP BY ps.LoanID
),
loan_base AS (
    SELECT
        l.LoanID,
        a.CustomerID,
        c.FirstName,
        c.LastName,
        l.LoanType,
        l.Principal,
        l.InterestRate,
        l.StartDate,
        l.EndDate,
        l.Status,
        ls.CreditScore,
        ls.ScoreDate,
        COALESCE(p.PaymentCount, 0) AS PaymentCount,
        COALESCE(p.TotalPayments, 0.0) AS TotalPayments,
        p.LastPaymentDate,
        COALESCE(s.ScheduledInstallments, 0) AS ScheduledInstallments,
        COALESCE(s.TotalDue, 0.0) AS TotalDue,
        COALESCE(s.TotalScheduledPaid, 0.0) AS TotalScheduledPaid,
        COALESCE(s.MaxDaysLate, 0) AS MaxDaysLate,
        COALESCE(s.AvgDaysLate, 0.0) AS AvgDaysLate
    FROM Loans AS l
    JOIN Accounts AS a
        ON a.AccountID = l.AccountID
    JOIN Customers AS c
        ON c.CustomerID = a.CustomerID
    LEFT JOIN latest_score AS ls
        ON ls.CustomerID = a.CustomerID
    LEFT JOIN payment_agg AS p
        ON p.LoanID = l.LoanID
    LEFT JOIN schedule_agg AS s
        ON s.LoanID = l.LoanID
)
SELECT
    LoanID,
    CustomerID,
    FirstName,
    LastName,
    LoanType,
    Principal,
    InterestRate,
    Status,
    CreditScore,
    PaymentCount,
    TotalPayments,
    TotalDue,
    TotalScheduledPaid,
    TotalDue - TotalScheduledPaid AS ScheduledOutstanding,
    MaxDaysLate,
    AvgDaysLate
FROM loan_base
ORDER BY CustomerID, LoanID;


-- ============================================================
-- 2. Release gate for the loan analytical base
-- Expected result: zero rows.
--
-- If this returns rows, a join has duplicated LoanID and any
-- downstream sum of Principal / payments may be overstated.
-- ============================================================

WITH payment_agg AS (
    SELECT LoanID, SUM(COALESCE(PaymentAmount, 0.0)) AS TotalPayments
    FROM Payments
    GROUP BY LoanID
),
schedule_agg AS (
    SELECT LoanID, SUM(COALESCE(DueAmount, 0.0)) AS TotalDue
    FROM Payment_Schedule
    GROUP BY LoanID
),
loan_base AS (
    SELECT
        l.LoanID,
        a.CustomerID,
        p.TotalPayments,
        s.TotalDue
    FROM Loans AS l
    JOIN Accounts AS a
        ON a.AccountID = l.AccountID
    LEFT JOIN payment_agg AS p
        ON p.LoanID = l.LoanID
    LEFT JOIN schedule_agg AS s
        ON s.LoanID = l.LoanID
)
SELECT
    LoanID,
    COUNT(*) AS RowsAfterJoin
FROM loan_base
GROUP BY LoanID
HAVING COUNT(*) <> 1;


-- ============================================================
-- 3. Customer risk summary
-- Target grain: one row per CustomerID.
--
-- Loan data is reduced to customer grain BEFORE combining with
-- latest risk assessment and latest credit score.
-- ============================================================

WITH loan_customer AS (
    SELECT
        a.CustomerID,
        COUNT(DISTINCT l.LoanID) AS LoanCount,
        SUM(CASE WHEN l.Status = 'Active' THEN 1 ELSE 0 END) AS ActiveLoans,
        SUM(CASE WHEN l.Status = 'Defaulted' THEN 1 ELSE 0 END) AS DefaultedLoans,
        SUM(COALESCE(l.Principal, 0.0)) AS TotalPrincipal,
        SUM(CASE WHEN l.Status = 'Active' THEN COALESCE(l.Principal, 0.0) ELSE 0.0 END) AS ActivePrincipal
    FROM Accounts AS a
    JOIN Loans AS l
        ON l.AccountID = a.AccountID
    GROUP BY a.CustomerID
),
risk_ranked AS (
    SELECT
        ra.CustomerID,
        ra.AssessmentDate,
        ra.RiskLevel,
        ROW_NUMBER() OVER (
            PARTITION BY ra.CustomerID
            ORDER BY ra.AssessmentDate DESC, ra.RiskLevel DESC
        ) AS rn
    FROM Risk_Assessment AS ra
),
latest_risk AS (
    SELECT CustomerID, AssessmentDate, RiskLevel
    FROM risk_ranked
    WHERE rn = 1
),
score_ranked AS (
    SELECT
        cs.CustomerID,
        cs.ScoreDate,
        cs.CreditScore,
        ROW_NUMBER() OVER (
            PARTITION BY cs.CustomerID
            ORDER BY cs.ScoreDate DESC, cs.CreditScore DESC
        ) AS rn
    FROM Credit_Scores AS cs
),
latest_score AS (
    SELECT CustomerID, ScoreDate, CreditScore
    FROM score_ranked
    WHERE rn = 1
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COALESCE(lc.LoanCount, 0) AS LoanCount,
    COALESCE(lc.ActiveLoans, 0) AS ActiveLoans,
    COALESCE(lc.DefaultedLoans, 0) AS DefaultedLoans,
    COALESCE(lc.TotalPrincipal, 0.0) AS TotalPrincipal,
    COALESCE(lc.ActivePrincipal, 0.0) AS ActivePrincipal,
    lr.RiskLevel,
    lr.AssessmentDate,
    ls.CreditScore,
    ls.ScoreDate
FROM Customers AS c
LEFT JOIN loan_customer AS lc
    ON lc.CustomerID = c.CustomerID
LEFT JOIN latest_risk AS lr
    ON lr.CustomerID = c.CustomerID
LEFT JOIN latest_score AS ls
    ON ls.CustomerID = c.CustomerID
ORDER BY COALESCE(lc.ActivePrincipal, 0.0) DESC, c.CustomerID;


-- ============================================================
-- 4. Delinquency summary by customer
-- Target grain: one row per CustomerID.
--
-- Payment schedules are first reduced to LoanID, then loan-level
-- delinquency is reduced to CustomerID. This prevents customers
-- with more schedule rows from being overweighted.
-- ============================================================

WITH loan_delinquency AS (
    SELECT
        ps.LoanID,
        MAX(COALESCE(ps.DaysLate, 0)) AS MaxDaysLate,
        AVG(COALESCE(ps.DaysLate, 0) * 1.0) AS AvgDaysLate,
        SUM(CASE WHEN COALESCE(ps.DaysLate, 0) > 0 THEN 1 ELSE 0 END) AS LateInstallments
    FROM Payment_Schedule AS ps
    GROUP BY ps.LoanID
),
customer_delinquency AS (
    SELECT
        a.CustomerID,
        COUNT(DISTINCT l.LoanID) AS LoansWithSchedule,
        MAX(COALESCE(ld.MaxDaysLate, 0)) AS MaxDaysLate,
        AVG(COALESCE(ld.AvgDaysLate, 0.0)) AS AvgLoanDaysLate,
        SUM(COALESCE(ld.LateInstallments, 0)) AS LateInstallments
    FROM Accounts AS a
    JOIN Loans AS l
        ON l.AccountID = a.AccountID
    LEFT JOIN loan_delinquency AS ld
        ON ld.LoanID = l.LoanID
    GROUP BY a.CustomerID
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    d.LoansWithSchedule,
    d.MaxDaysLate,
    ROUND(d.AvgLoanDaysLate, 2) AS AvgLoanDaysLate,
    d.LateInstallments
FROM customer_delinquency AS d
JOIN Customers AS c
    ON c.CustomerID = d.CustomerID
WHERE d.MaxDaysLate > 0
ORDER BY d.MaxDaysLate DESC, d.LateInstallments DESC, c.CustomerID;


-- ============================================================
-- 5. Credit-score movement using consecutive observations
-- Target grain: one row per CustomerID after classification.
--
-- MIN/MAX does not tell direction. LAG compares each observation
-- with the immediately previous score, while first/last ranks
-- establish the net movement across the available history.
-- ============================================================

WITH score_history AS (
    SELECT
        cs.CustomerID,
        cs.ScoreDate,
        cs.CreditScore,
        LAG(cs.CreditScore) OVER (
            PARTITION BY cs.CustomerID
            ORDER BY cs.ScoreDate
        ) AS PreviousScore,
        ROW_NUMBER() OVER (
            PARTITION BY cs.CustomerID
            ORDER BY cs.ScoreDate
        ) AS rn_first,
        ROW_NUMBER() OVER (
            PARTITION BY cs.CustomerID
            ORDER BY cs.ScoreDate DESC
        ) AS rn_last
    FROM Credit_Scores AS cs
),
score_rollup AS (
    SELECT
        CustomerID,
        MAX(CASE WHEN rn_first = 1 THEN CreditScore END) AS FirstScore,
        MAX(CASE WHEN rn_last = 1 THEN CreditScore END) AS LatestScore,
        MAX(CASE WHEN rn_last = 1 THEN ScoreDate END) AS LatestScoreDate,
        SUM(CASE
                WHEN PreviousScore IS NOT NULL AND CreditScore > PreviousScore THEN 1
                ELSE 0
            END) AS ImprovingSteps,
        SUM(CASE
                WHEN PreviousScore IS NOT NULL AND CreditScore < PreviousScore THEN 1
                ELSE 0
            END) AS DecliningSteps
    FROM score_history
    GROUP BY CustomerID
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    s.FirstScore,
    s.LatestScore,
    s.LatestScore - s.FirstScore AS NetScoreChange,
    s.ImprovingSteps,
    s.DecliningSteps,
    s.LatestScoreDate,
    CASE
        WHEN s.LatestScore > s.FirstScore THEN 'Improving'
        WHEN s.LatestScore < s.FirstScore THEN 'Declining'
        ELSE 'Flat'
    END AS NetDirection
FROM score_rollup AS s
JOIN Customers AS c
    ON c.CustomerID = s.CustomerID
ORDER BY NetScoreChange DESC, c.CustomerID;


-- ============================================================
-- 6. High-risk customers with active exposure
-- Latest risk assessment only; active loans aggregated first.
-- ============================================================

WITH risk_ranked AS (
    SELECT
        ra.CustomerID,
        ra.AssessmentDate,
        ra.RiskLevel,
        ROW_NUMBER() OVER (
            PARTITION BY ra.CustomerID
            ORDER BY ra.AssessmentDate DESC, ra.RiskLevel DESC
        ) AS rn
    FROM Risk_Assessment AS ra
),
latest_risk AS (
    SELECT CustomerID, AssessmentDate, RiskLevel
    FROM risk_ranked
    WHERE rn = 1
),
active_exposure AS (
    SELECT
        a.CustomerID,
        COUNT(DISTINCT l.LoanID) AS ActiveLoans,
        SUM(COALESCE(l.Principal, 0.0)) AS ActivePrincipal
    FROM Accounts AS a
    JOIN Loans AS l
        ON l.AccountID = a.AccountID
    WHERE l.Status = 'Active'
    GROUP BY a.CustomerID
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    r.RiskLevel,
    r.AssessmentDate,
    e.ActiveLoans,
    e.ActivePrincipal
FROM latest_risk AS r
JOIN active_exposure AS e
    ON e.CustomerID = r.CustomerID
JOIN Customers AS c
    ON c.CustomerID = r.CustomerID
WHERE r.RiskLevel = 'High'
ORDER BY e.ActivePrincipal DESC, c.CustomerID;


-- ============================================================
-- 7. Payment performance by loan
-- Target grain: one row per LoanID.
-- ============================================================

WITH schedule_agg AS (
    SELECT
        LoanID,
        SUM(COALESCE(DueAmount, 0.0)) AS TotalDue,
        SUM(COALESCE(PaidAmount, 0.0)) AS TotalPaid,
        MAX(COALESCE(DaysLate, 0)) AS MaxDaysLate
    FROM Payment_Schedule
    GROUP BY LoanID
)
SELECT
    l.LoanID,
    l.Status,
    l.Principal,
    COALESCE(s.TotalDue, 0.0) AS TotalDue,
    COALESCE(s.TotalPaid, 0.0) AS TotalPaid,
    COALESCE(s.TotalDue, 0.0) - COALESCE(s.TotalPaid, 0.0) AS ScheduledOutstanding,
    COALESCE(s.MaxDaysLate, 0) AS MaxDaysLate
FROM Loans AS l
LEFT JOIN schedule_agg AS s
    ON s.LoanID = l.LoanID
ORDER BY ScheduledOutstanding DESC, l.LoanID;


-- ============================================================
-- 8. Customers with multiple active loans
-- COUNT(DISTINCT LoanID) protects the result if the query is
-- later extended with additional one-to-many detail.
-- ============================================================

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(DISTINCT l.LoanID) AS ActiveLoans,
    SUM(COALESCE(l.Principal, 0.0)) AS ActivePrincipal
FROM Customers AS c
JOIN Accounts AS a
    ON a.CustomerID = c.CustomerID
JOIN Loans AS l
    ON l.AccountID = a.AccountID
WHERE l.Status = 'Active'
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(DISTINCT l.LoanID) > 1
ORDER BY ActivePrincipal DESC, c.CustomerID;


-- ============================================================
-- 9. Loan application funnel
-- Target grain: one row per application status.
-- ============================================================

SELECT
    Status,
    COUNT(*) AS Applications,
    ROUND(AVG(COALESCE(RequestedAmount, 0.0)), 2) AS AvgRequestedAmount,
    SUM(COALESCE(RequestedAmount, 0.0)) AS TotalRequestedAmount
FROM Loan_Applications
GROUP BY Status
ORDER BY Applications DESC, Status;


-- ============================================================
-- 10. Source reconciliation pack
-- These are diagnostic controls, not business KPIs.
-- Any returned row should be investigated before trusting a mart.
-- ============================================================

-- 10A. Duplicate primary/business keys: expected zero rows.
SELECT CustomerID, COUNT(*) AS RowCount
FROM Customers
GROUP BY CustomerID
HAVING COUNT(*) <> 1;

SELECT AccountID, COUNT(*) AS RowCount
FROM Accounts
GROUP BY AccountID
HAVING COUNT(*) <> 1;

SELECT LoanID, COUNT(*) AS RowCount
FROM Loans
GROUP BY LoanID
HAVING COUNT(*) <> 1;

-- 10B. Orphan checks: expected zero rows.
SELECT
    a.AccountID,
    a.CustomerID
FROM Accounts AS a
LEFT JOIN Customers AS c
    ON c.CustomerID = a.CustomerID
WHERE c.CustomerID IS NULL;

SELECT
    l.LoanID,
    l.AccountID
FROM Loans AS l
LEFT JOIN Accounts AS a
    ON a.AccountID = l.AccountID
WHERE a.AccountID IS NULL;

SELECT
    p.PaymentID,
    p.LoanID
FROM Payments AS p
LEFT JOIN Loans AS l
    ON l.LoanID = p.LoanID
WHERE l.LoanID IS NULL;

SELECT
    ps.ScheduleID,
    ps.LoanID
FROM Payment_Schedule AS ps
LEFT JOIN Loans AS l
    ON l.LoanID = ps.LoanID
WHERE l.LoanID IS NULL;

-- 10C. Amount / date quality controls.
SELECT
    LoanID,
    StartDate,
    EndDate
FROM Loans
WHERE EndDate < StartDate;

SELECT
    ScheduleID,
    LoanID,
    DueAmount,
    PaidAmount,
    DaysLate
FROM Payment_Schedule
WHERE DueAmount IS NULL
   OR COALESCE(DueAmount, 0.0) < 0
   OR COALESCE(PaidAmount, 0.0) < 0
   OR COALESCE(DaysLate, 0) < 0;
