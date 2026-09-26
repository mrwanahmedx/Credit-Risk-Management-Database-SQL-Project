-- ============================================================
-- DATA QUALITY / RECONCILIATION PACK
-- Credit Risk Management Database
--
-- These checks are designed as release gates before analytical
-- joins. They return only the columns needed to investigate an
-- exception rather than SELECT * dumps.
-- ============================================================


-- 1. Duplicate customer keys
-- Expected result: zero rows.
SELECT
    CustomerID,
    COUNT(*) AS RowCount
FROM Customers
GROUP BY CustomerID
HAVING COUNT(*) <> 1;


-- 2. Duplicate account keys
-- Expected result: zero rows.
SELECT
    AccountID,
    COUNT(*) AS RowCount
FROM Accounts
GROUP BY AccountID
HAVING COUNT(*) <> 1;


-- 3. Duplicate loan keys
-- Expected result: zero rows.
SELECT
    LoanID,
    COUNT(*) AS RowCount
FROM Loans
GROUP BY LoanID
HAVING COUNT(*) <> 1;


-- 4. Missing customer contact information
SELECT
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone
FROM Customers
WHERE Email IS NULL
   OR Phone IS NULL;


-- 5. Negative balances outside loan accounts
SELECT
    AccountID,
    CustomerID,
    AccountType,
    Balance,
    Status
FROM Accounts
WHERE Balance < 0
  AND AccountType <> 'Loan';


-- 6. Invalid loan date ranges
SELECT
    LoanID,
    AccountID,
    StartDate,
    EndDate,
    Status
FROM Loans
WHERE EndDate < StartDate;


-- 7. Orphan account -> customer references
SELECT
    a.AccountID,
    a.CustomerID
FROM Accounts AS a
LEFT JOIN Customers AS c
    ON c.CustomerID = a.CustomerID
WHERE c.CustomerID IS NULL;


-- 8. Orphan loan -> account references
SELECT
    l.LoanID,
    l.AccountID
FROM Loans AS l
LEFT JOIN Accounts AS a
    ON a.AccountID = l.AccountID
WHERE a.AccountID IS NULL;


-- 9. Orphan payment -> loan references
SELECT
    p.PaymentID,
    p.LoanID,
    p.PaymentDate,
    p.PaymentAmount
FROM Payments AS p
LEFT JOIN Loans AS l
    ON l.LoanID = p.LoanID
WHERE l.LoanID IS NULL;


-- 10. Orphan schedule -> loan references
SELECT
    ps.ScheduleID,
    ps.LoanID,
    ps.DueDate,
    ps.DueAmount
FROM Payment_Schedule AS ps
LEFT JOIN Loans AS l
    ON l.LoanID = ps.LoanID
WHERE l.LoanID IS NULL;


-- 11. Payment schedule amount / delinquency checks
SELECT
    ScheduleID,
    LoanID,
    DueDate,
    DueAmount,
    PaidDate,
    PaidAmount,
    DaysLate
FROM Payment_Schedule
WHERE DueAmount IS NULL
   OR COALESCE(DueAmount, 0.0) < 0
   OR COALESCE(PaidAmount, 0.0) < 0
   OR COALESCE(DaysLate, 0) < 0;


-- 12. Credit-score range and history coverage
SELECT
    CustomerID,
    COUNT(*) AS ScoreObservations,
    MIN(ScoreDate) AS FirstScoreDate,
    MAX(ScoreDate) AS LatestScoreDate,
    MIN(CreditScore) AS MinScore,
    MAX(CreditScore) AS MaxScore,
    ROUND(AVG(CreditScore * 1.0), 2) AS AvgScore
FROM Credit_Scores
GROUP BY CustomerID
ORDER BY CustomerID;


-- 13. Latest risk assessment per customer
-- Window ranking prevents historical assessments from multiplying
-- a customer when joined to current exposure.
WITH risk_ranked AS (
    SELECT
        CustomerID,
        AssessmentDate,
        RiskLevel,
        Notes,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID
            ORDER BY AssessmentDate DESC, RiskLevel DESC
        ) AS rn
    FROM Risk_Assessment
)
SELECT
    CustomerID,
    AssessmentDate,
    RiskLevel,
    Notes
FROM risk_ranked
WHERE rn = 1
ORDER BY CustomerID;


-- 14. Loan-status reconciliation
SELECT
    Status,
    COUNT(*) AS LoanCount,
    SUM(COALESCE(Principal, 0.0)) AS Principal
FROM Loans
GROUP BY Status
ORDER BY Status;


-- 15. Loan-type reconciliation
SELECT
    LoanType,
    COUNT(*) AS LoanCount,
    SUM(COALESCE(Principal, 0.0)) AS Principal
FROM Loans
GROUP BY LoanType
ORDER BY LoanType;


-- 16. Customer-level delinquency after pre-aggregation
-- Payment_Schedule is first reduced to LoanID to avoid weighting
-- customers with more schedule rows more heavily than intended.
WITH loan_delinquency AS (
    SELECT
        LoanID,
        MAX(COALESCE(DaysLate, 0)) AS MaxDaysLate,
        AVG(COALESCE(DaysLate, 0) * 1.0) AS AvgDaysLate,
        SUM(CASE WHEN COALESCE(DaysLate, 0) > 0 THEN 1 ELSE 0 END) AS LateInstallments
    FROM Payment_Schedule
    GROUP BY LoanID
),
customer_delinquency AS (
    SELECT
        a.CustomerID,
        COUNT(DISTINCT l.LoanID) AS LoanCount,
        MAX(COALESCE(d.MaxDaysLate, 0)) AS MaxDaysLate,
        ROUND(AVG(COALESCE(d.AvgDaysLate, 0.0)), 2) AS AvgLoanDaysLate,
        SUM(COALESCE(d.LateInstallments, 0)) AS LateInstallments
    FROM Accounts AS a
    JOIN Loans AS l
        ON l.AccountID = a.AccountID
    LEFT JOIN loan_delinquency AS d
        ON d.LoanID = l.LoanID
    GROUP BY a.CustomerID
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    d.LoanCount,
    d.MaxDaysLate,
    d.AvgLoanDaysLate,
    d.LateInstallments
FROM customer_delinquency AS d
JOIN Customers AS c
    ON c.CustomerID = d.CustomerID
WHERE d.MaxDaysLate > 0
ORDER BY d.MaxDaysLate DESC, c.CustomerID;
