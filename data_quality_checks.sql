-- ============================================================
-- DATA QUALITY / RECONCILIATION RELEASE GATES
-- Synthetic Credit Risk Management Database
--
-- Public portfolio code only. No employer/customer data.
-- Every query is diagnostic and should return either zero rows
-- for hard failures or a clearly interpretable reconciliation.
-- ============================================================

-- 1. Duplicate customer keys: expected zero rows.
SELECT CustomerID, COUNT(*) AS RowCount
FROM Customers
GROUP BY CustomerID
HAVING COUNT(*) <> 1;

-- 2. Duplicate account keys: expected zero rows.
SELECT AccountID, COUNT(*) AS RowCount
FROM Accounts
GROUP BY AccountID
HAVING COUNT(*) <> 1;

-- 3. Duplicate loan keys: expected zero rows.
SELECT LoanID, COUNT(*) AS RowCount
FROM Loans
GROUP BY LoanID
HAVING COUNT(*) <> 1;

-- 4. Missing customer contact fields.
SELECT CustomerID, FirstName, LastName, Email, Phone
FROM Customers
WHERE Email IS NULL OR Phone IS NULL;

-- 5. Negative balances outside loan accounts.
SELECT AccountID, CustomerID, AccountType, Balance, Status
FROM Accounts
WHERE Balance < 0
  AND AccountType <> 'Loan';

-- 6. Invalid loan dates.
SELECT LoanID, AccountID, StartDate, EndDate, Status
FROM Loans
WHERE EndDate < StartDate;

-- 7. Orphan account -> customer references: expected zero rows.
SELECT a.AccountID, a.CustomerID
FROM Accounts a
LEFT JOIN Customers c ON c.CustomerID = a.CustomerID
WHERE c.CustomerID IS NULL;

-- 8. Orphan loan -> account references: expected zero rows.
SELECT l.LoanID, l.AccountID
FROM Loans l
LEFT JOIN Accounts a ON a.AccountID = l.AccountID
WHERE a.AccountID IS NULL;

-- 9. Orphan payment -> loan references: expected zero rows.
SELECT p.PaymentID, p.LoanID, p.PaymentDate, p.PaymentAmount
FROM Payments p
LEFT JOIN Loans l ON l.LoanID = p.LoanID
WHERE l.LoanID IS NULL;

-- 10. Orphan schedule -> loan references: expected zero rows.
SELECT ps.ScheduleID, ps.LoanID, ps.DueDate, ps.DueAmount
FROM Payment_Schedule ps
LEFT JOIN Loans l ON l.LoanID = ps.LoanID
WHERE l.LoanID IS NULL;

-- 11. Invalid schedule amounts / delinquency values.
SELECT ScheduleID, LoanID, DueDate, DueAmount, PaidDate, PaidAmount, DaysLate
FROM Payment_Schedule
WHERE DueAmount IS NULL
   OR COALESCE(DueAmount,0) < 0
   OR COALESCE(PaidAmount,0) < 0
   OR COALESCE(DaysLate,0) < 0;

-- 12. Credit-score history coverage reconciliation.
SELECT CustomerID,
       COUNT(*) AS ScoreObservations,
       MIN(ScoreDate) AS FirstScoreDate,
       MAX(ScoreDate) AS LatestScoreDate,
       MIN(CreditScore) AS MinScore,
       MAX(CreditScore) AS MaxScore,
       ROUND(AVG(CreditScore * 1.0),2) AS AvgScore
FROM Credit_Scores
GROUP BY CustomerID
ORDER BY CustomerID;

-- 13. Latest risk assessment per customer.
WITH risk_ranked AS (
    SELECT CustomerID, AssessmentDate, RiskLevel, Notes,
           ROW_NUMBER() OVER (
               PARTITION BY CustomerID
               ORDER BY AssessmentDate DESC, RiskLevel DESC
           ) AS rn
    FROM Risk_Assessment
)
SELECT CustomerID, AssessmentDate, RiskLevel, Notes
FROM risk_ranked
WHERE rn = 1
ORDER BY CustomerID;

-- 14. Loan-status reconciliation.
SELECT Status,
       COUNT(*) AS LoanCount,
       SUM(COALESCE(Principal,0)) AS Principal
FROM Loans
GROUP BY Status
ORDER BY Status;

-- 15. Loan-type reconciliation.
SELECT LoanType,
       COUNT(*) AS LoanCount,
       SUM(COALESCE(Principal,0)) AS Principal
FROM Loans
GROUP BY LoanType
ORDER BY LoanType;

-- 16. Customer delinquency after reducing schedule rows to LoanID.
WITH loan_delinquency AS (
    SELECT LoanID,
           MAX(COALESCE(DaysLate,0)) AS MaxDaysLate,
           AVG(COALESCE(DaysLate,0) * 1.0) AS AvgDaysLate,
           SUM(CASE WHEN COALESCE(DaysLate,0) > 0 THEN 1 ELSE 0 END) AS LateInstallments
    FROM Payment_Schedule
    GROUP BY LoanID
),
customer_delinquency AS (
    SELECT a.CustomerID,
           COUNT(DISTINCT l.LoanID) AS LoanCount,
           MAX(COALESCE(d.MaxDaysLate,0)) AS MaxDaysLate,
           ROUND(AVG(COALESCE(d.AvgDaysLate,0)),2) AS AvgLoanDaysLate,
           SUM(COALESCE(d.LateInstallments,0)) AS LateInstallments
    FROM Accounts a
    JOIN Loans l ON l.AccountID = a.AccountID
    LEFT JOIN loan_delinquency d ON d.LoanID = l.LoanID
    GROUP BY a.CustomerID
)
SELECT c.CustomerID, c.FirstName, c.LastName,
       d.LoanCount, d.MaxDaysLate, d.AvgLoanDaysLate, d.LateInstallments
FROM customer_delinquency d
JOIN Customers c ON c.CustomerID = d.CustomerID
WHERE d.MaxDaysLate > 0
ORDER BY d.MaxDaysLate DESC, c.CustomerID;
