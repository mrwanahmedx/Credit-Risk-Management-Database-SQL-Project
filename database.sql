-- Tables & Basic data


-- Drop tables if they exist

DROP TABLE IF EXISTS Payment_Schedule;
DROP TABLE IF EXISTS Loan_Applications;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Risk_Assessment;
DROP TABLE IF EXISTS Credit_Scores;
DROP TABLE IF EXISTS Accounts;
DROP TABLE IF EXISTS Customers;


-- Creating the Tables

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DOB DATE,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255)
);

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType VARCHAR(50),
    Balance DECIMAL(12,2),
    OpenDate DATE,
    Status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    AccountID INT,
    LoanType VARCHAR(50),
    Principal DECIMAL(10,2),
    InterestRate DECIMAL(5,2),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(20), -- Active, Paid, Defaulted, Late
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    LoanID INT,
    PaymentDate DATE,
    PaymentAmount DECIMAL(12,2),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

CREATE TABLE Payment_Schedule (
    ScheduleID INT PRIMARY KEY,
    LoanID INT,
    DueDate DATE,
    DueAmount DECIMAL(12,2),
    PaidDate DATE,
    PaidAmount DECIMAL(12,2),
    DaysLate INT DEFAULT 0,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

CREATE TABLE Loan_Applications (
    ApplicationID INT PRIMARY KEY,
    CustomerID INT,
    ApplicationDate DATE,
    LoanType VARCHAR(50),
    RequestedAmount DECIMAL(10,2),
    Status VARCHAR(20), -- Approved, Rejected, Pending
    RejectionReason VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Credit_Scores (
    CustomerID INT,
    ScoreDate DATE,
    CreditScore INT,
    PRIMARY KEY (CustomerID, ScoreDate),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Risk_Assessment (
    CustomerID INT,
    AssessmentDate DATE,
    RiskLevel VARCHAR(10), -- Low, Medium, High
    Notes VARCHAR(255),
    PRIMARY KEY (CustomerID, AssessmentDate),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Inserting sample data


INSERT INTO Customers (CustomerID, FirstName, LastName, DOB, Email, Phone, Address) VALUES
(1, 'Synthetic', 'Borrower001', '1985-06-15', 'borrower001@example.invalid', 'SYNTH-001', 'Synthetic City'),
(2, 'Synthetic', 'Borrower002', '1990-11-02', 'borrower002@example.invalid', 'SYNTH-002', 'Synthetic City'),
(3, 'Synthetic', 'Borrower003', '1978-03-21', 'borrower003@example.invalid', 'SYNTH-003', 'Synthetic City'),
(4, 'Synthetic', 'Borrower004', '1995-07-10', 'borrower004@example.invalid', 'SYNTH-004', 'Synthetic City'),
(5, 'Synthetic', 'Borrower005', '1982-12-05', 'borrower005@example.invalid', 'SYNTH-005', 'Synthetic City'),
(6, 'Synthetic', 'Borrower006', '1988-04-18', 'borrower006@example.invalid', 'SYNTH-006', 'Synthetic City'),
(7, 'Synthetic', 'Borrower007', '1975-09-12', 'borrower007@example.invalid', 'SYNTH-007', 'Synthetic City'),
(8, 'Synthetic', 'Borrower008', '1992-01-25', 'borrower008@example.invalid', 'SYNTH-008', 'Synthetic City'),
(9, 'Synthetic', 'Borrower009', '1980-08-30', 'borrower009@example.invalid', 'SYNTH-009', 'Synthetic City'),
(10, 'Synthetic', 'Borrower010', '1993-05-17', 'borrower010@example.invalid', 'SYNTH-010', 'Synthetic City'),
(11, 'Synthetic', 'Borrower011', '1984-02-11', 'borrower011@example.invalid', 'SYNTH-011', 'Synthetic City'),
(12, 'Synthetic', 'Borrower012', '1991-10-22', 'borrower012@example.invalid', 'SYNTH-012', 'Synthetic City'),
(13, 'Synthetic', 'Borrower013', '1979-06-08', 'borrower013@example.invalid', 'SYNTH-013', 'Synthetic City'),
(14, 'Synthetic', 'Borrower014', '1994-12-18', 'borrower014@example.invalid', 'SYNTH-014', 'Synthetic City'),
(15, 'Synthetic', 'Borrower015', '1983-08-30', 'borrower015@example.invalid', 'SYNTH-015', 'Synthetic City'),
(16, 'Synthetic', 'Borrower016', '1990-03-15', 'borrower016@example.invalid', 'SYNTH-016', 'Synthetic City'),
(17, 'Synthetic', 'Borrower017', '1981-07-21', 'borrower017@example.invalid', 'SYNTH-017', 'Synthetic City'),
(18, 'Synthetic', 'Borrower018', '1992-09-12', 'borrower018@example.invalid', 'SYNTH-018', 'Synthetic City'),
(19, 'Synthetic', 'Borrower019', '1985-01-30', 'borrower019@example.invalid', 'SYNTH-019', 'Synthetic City'),
(20, 'Synthetic', 'Borrower020', '1993-05-02', 'borrower020@example.invalid', 'SYNTH-020', 'Synthetic City'),
(21, 'Synthetic', 'Borrower021', '1977-11-14', 'borrower021@example.invalid', 'SYNTH-021', 'Synthetic City'),
(22, 'Synthetic', 'Borrower022', '1995-07-07', 'borrower022@example.invalid', 'SYNTH-022', 'Synthetic City'),
(23, 'Synthetic', 'Borrower023', '1980-12-25', 'borrower023@example.invalid', 'SYNTH-023', 'Synthetic City'),
(24, 'Synthetic', 'Borrower024', '1992-06-05', 'borrower024@example.invalid', 'SYNTH-024', 'Synthetic City'),
(25, 'Synthetic', 'Borrower025', '1987-03-11', 'borrower025@example.invalid', 'SYNTH-025', 'Synthetic City'),
(26, 'Synthetic', 'Borrower026', '1982-09-20', 'borrower026@example.invalid', 'SYNTH-026', 'Synthetic City'),
(27, 'Synthetic', 'Borrower027', '1991-04-01', 'borrower027@example.invalid', 'SYNTH-027', 'Synthetic City'),
(28, 'Synthetic', 'Borrower028', '1978-10-28', 'borrower028@example.invalid', 'SYNTH-028', 'Synthetic City'),
(29, 'Synthetic', 'Borrower029', '1990-08-17', 'borrower029@example.invalid', 'SYNTH-029', 'Synthetic City'),
(30, 'Synthetic', 'Borrower030', '1983-05-25', 'borrower030@example.invalid', 'SYNTH-030', 'Synthetic City'),
(31, 'Synthetic', 'Borrower031', '1992-12-12', 'borrower031@example.invalid', 'SYNTH-031', 'Synthetic City'),
(32, 'Synthetic', 'Borrower032', '1984-07-19', 'borrower032@example.invalid', 'SYNTH-032', 'Synthetic City'),
(33, 'Synthetic', 'Borrower033', '1988-01-05', 'borrower033@example.invalid', 'SYNTH-033', 'Synthetic City'),
(34, 'Synthetic', 'Borrower034', '1979-09-09', 'borrower034@example.invalid', 'SYNTH-034', 'Synthetic City'),
(35, 'Synthetic', 'Borrower035', '1993-02-21', 'borrower035@example.invalid', 'SYNTH-035', 'Synthetic City'),
(36, 'Synthetic', 'Borrower036', '1981-06-30', 'borrower036@example.invalid', 'SYNTH-036', 'Synthetic City'),
(37, 'Synthetic', 'Borrower037', '1990-11-11', 'borrower037@example.invalid', 'SYNTH-037', 'Synthetic City'),
(38, 'Synthetic', 'Borrower038', '1985-03-03', 'borrower038@example.invalid', 'SYNTH-038', 'Synthetic City'),
(39, 'Synthetic', 'Borrower039', '1992-08-18', 'borrower039@example.invalid', 'SYNTH-039', 'Synthetic City'),
(40, 'Synthetic', 'Borrower040', '1986-05-07', 'borrower040@example.invalid', 'SYNTH-040', 'Synthetic City'),
(41, 'Synthetic', 'Borrower041', '1991-09-12', 'borrower041@example.invalid', 'SYNTH-041', 'Synthetic City'),
(42, 'Synthetic', 'Borrower042', '1980-12-01', 'borrower042@example.invalid', 'SYNTH-042', 'Synthetic City'),
(43, 'Synthetic', 'Borrower043', '1989-04-04', 'borrower043@example.invalid', 'SYNTH-043', 'Synthetic City'),
(44, 'Synthetic', 'Borrower044', '1982-06-15', 'borrower044@example.invalid', 'SYNTH-044', 'Synthetic City'),
(45, 'Synthetic', 'Borrower045', '1994-10-10', 'borrower045@example.invalid', 'SYNTH-045', 'Synthetic City'),
(46, 'Synthetic', 'Borrower046', '1983-01-01', 'borrower046@example.invalid', 'SYNTH-046', 'Synthetic City'),
(47, 'Synthetic', 'Borrower047', '1992-03-14', 'borrower047@example.invalid', 'SYNTH-047', 'Synthetic City'),
(48, 'Synthetic', 'Borrower048', '1985-07-23', 'borrower048@example.invalid', 'SYNTH-048', 'Synthetic City'),
(49, 'Synthetic', 'Borrower049', '1981-11-30', 'borrower049@example.invalid', 'SYNTH-049', 'Synthetic City'),
(50, 'Synthetic', 'Borrower050', '1990-02-28', 'borrower050@example.invalid', 'SYNTH-050', 'Synthetic City');

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, OpenDate, Status) VALUES
(1, 1, 'Checking', 12000.50, '2018-03-15', 'Active'),
(2, 1, 'Savings', 5000.00, '2019-05-20', 'Active'),
(3, 2, 'Checking', 3000.75, '2020-01-10', 'Active'),
(4, 2, 'Loan', -15000.00, '2021-02-15', 'Active'),
(5, 3, 'Checking', 7000.25, '2017-07-05', 'Active'),
(6, 3, 'Loan', -5000.00, '2018-11-12', 'Closed'),
(7, 4, 'Savings', 1200.00, '2019-09-30', 'Active'),
(8, 5, 'Checking', 2500.50, '2020-04-01', 'Active'),
(9, 6, 'Loan', -12000.00, '2021-06-18', 'Active'),
(10, 7, 'Checking', 9000.00, '2016-12-20', 'Active'),
(11, 8, 'Checking', 3500.00, '2019-05-10', 'Active'),
(12, 8, 'Savings', 1500.00, '2020-06-12', 'Active'),
(13, 9, 'Loan', -8000.00, '2021-07-01', 'Active'),
(14, 10, 'Checking', 4000.00, '2018-02-15', 'Active'),
(15, 11, 'Checking', 5500.00, '2017-08-20', 'Active'),
(16, 12, 'Savings', 2000.00, '2019-03-30', 'Active'),
(17, 13, 'Loan', -10000.00, '2020-05-05', 'Active'),
(18, 14, 'Checking', 3000.00, '2021-01-15', 'Active'),
(19, 15, 'Loan', -6000.00, '2019-12-10', 'Active'),
(20, 16, 'Checking', 4500.00, '2018-11-22', 'Active'),
(21, 17, 'Checking', 5200.00, '2019-07-14', 'Active'),
(22, 18, 'Savings', 1800.00, '2020-03-25', 'Active'),
(23, 19, 'Loan', -9000.00, '2021-01-30', 'Active'),
(24, 20, 'Checking', 4700.00, '2018-08-11', 'Active'),
(25, 21, 'Checking', 6000.00, '2017-05-09', 'Active'),
(26, 22, 'Savings', 2200.00, '2019-12-17', 'Active'),
(27, 23, 'Loan', -11000.00, '2020-06-22', 'Active'),
(28, 24, 'Checking', 3300.00, '2021-02-05', 'Active'),
(29, 25, 'Loan', -7500.00, '2019-09-14', 'Active'),
(30, 26, 'Checking', 4900.00, '2018-10-20', 'Active'),
(31, 27, 'Checking', 3500.00, '2019-06-08', 'Active'),
(32, 28, 'Savings', 2000.00, '2020-01-19', 'Active'),
(33, 29, 'Loan', -12000.00, '2021-03-25', 'Active'),
(34, 30, 'Checking', 4100.00, '2018-09-07', 'Active'),
(35, 31, 'Checking', 5300.00, '2017-11-12', 'Active'),
(36, 32, 'Savings', 2500.00, '2019-04-28', 'Active'),
(37, 33, 'Loan', -8000.00, '2020-08-03', 'Active'),
(38, 34, 'Checking', 4700.00, '2021-05-15', 'Active'),
(39, 35, 'Checking', 3600.00, '2018-06-21', 'Active'),
(40, 36, 'Savings', 1900.00, '2020-02-11', 'Active'),
(41, 37, 'Loan', -9500.00, '2021-07-08', 'Active'),
(42, 38, 'Checking', 5200.00, '2017-12-01', 'Active'),
(43, 39, 'Checking', 4400.00, '2019-03-05', 'Active'),
(44, 40, 'Savings', 2300.00, '2020-05-10', 'Active'),
(45, 41, 'Loan', -10500.00, '2021-01-22', 'Active'),
(46, 42, 'Checking', 3900.00, '2018-07-14', 'Active'),
(47, 43, 'Checking', 4800.00, '2017-09-30', 'Active'),
(48, 44, 'Savings', 2100.00, '2019-11-18', 'Active'),
(49, 45, 'Loan', -7000.00, '2020-12-05', 'Active'),
(50, 46, 'Checking', 5500.00, '2018-10-28', 'Active');

INSERT INTO Loans (LoanID, AccountID, LoanType, Principal, InterestRate, StartDate, EndDate, Status) VALUES
(1, 4, 'Personal', 15000.00, 12.5, '2021-02-15', '2024-02-15', 'Active'),
(2, 6, 'Car', 5000.00, 10.0, '2018-11-12', '2023-11-12', 'Paid'),
(3, 9, 'Home', 12000.00, 8.5, '2021-06-18', '2031-06-18', 'Late'),
(4, 13, 'Personal', 10000.00, 11.5, '2020-05-05', '2023-05-05', 'Paid'),
(5, 19, 'Car', 6000.00, 10.0, '2019-12-10', '2024-12-10', 'Active'),
(6, 17, 'Home', 25000.00, 9.5, '2019-07-14', '2034-07-14', 'Active'),
(7, 23, 'Personal', 8000.00, 12.0, '2021-01-30', '2024-01-30', 'Late'),
(8, 27, 'Car', 7000.00, 10.5, '2020-06-22', '2025-06-22', 'Active'),
(9, 37, 'Home', 20000.00, 8.5, '2020-08-03', '2030-08-03', 'Active'),
(10, 29, 'Personal', 9000.00, 11.0, '2021-03-25', '2024-03-25', 'Defaulted'),
(11, 33, 'Car', 5000.00, 10.0, '2020-01-19', '2025-01-19', 'Active'),
(12, 37, 'Home', 15000.00, 9.0, '2021-07-08', '2031-07-08', 'Active'),
(13, 41, 'Personal', 12000.00, 12.5, '2021-01-22', '2024-01-22', 'Active'),
(14, 45, 'Car', 8000.00, 11.0, '2020-12-05', '2025-12-05', 'Late'),
(15, 49, 'Personal', 3500.00, 13.0, '2021-08-15', '2024-08-15', 'Active');

INSERT INTO Payments (PaymentID, LoanID, PaymentDate, PaymentAmount) VALUES
(1, 1, '2021-03-15', 500.00),
(2, 1, '2021-04-15', 500.00),
(3, 1, '2021-05-15', 500.00),
(4, 1, '2021-06-15', 500.00),
(5, 2, '2019-01-12', 200.00),
(6, 2, '2019-02-12', 200.00),
(7, 2, '2019-03-12', 200.00),
(8, 3, '2021-07-18', 800.00),
(9, 3, '2021-08-18', 800.00),
(10, 5, '2020-01-10', 250.00),
(11, 5, '2020-02-10', 250.00),
(12, 6, '2019-08-14', 1200.00),
(13, 6, '2019-09-14', 1200.00),
(14, 8, '2020-07-22', 300.00),
(15, 8, '2020-08-22', 300.00),
(16, 9, '2020-09-03', 1000.00),
(17, 11, '2020-02-19', 200.00),
(18, 13, '2021-02-22', 500.00),
(19, 15, '2021-09-15', 150.00);

INSERT INTO Payment_Schedule (ScheduleID, LoanID, DueDate, DueAmount, PaidDate, PaidAmount, DaysLate) VALUES
(1, 1, '2021-03-15', 500.00, '2021-03-15', 500.00, 0),
(2, 1, '2021-04-15', 500.00, '2021-04-15', 500.00, 0),
(3, 1, '2021-05-15', 500.00, '2021-05-17', 500.00, 2),
(4, 3, '2021-07-18', 800.00, '2021-07-18', 800.00, 0),
(5, 3, '2021-08-18', 800.00, '2021-09-05', 800.00, 18),
(6, 3, '2021-09-18', 800.00, NULL, 0.00, 30),
(7, 7, '2021-02-28', 350.00, '2021-03-15', 350.00, 15),
(8, 7, '2021-03-30', 350.00, NULL, 0.00, 45),
(9, 10, '2021-04-25', 400.00, NULL, 0.00, 60),
(10, 10, '2021-05-25', 400.00, NULL, 0.00, 90),
(11, 14, '2021-01-05', 350.00, '2021-01-20', 350.00, 15),
(12, 14, '2021-02-05', 350.00, NULL, 0.00, 50);

INSERT INTO Loan_Applications (ApplicationID, CustomerID, ApplicationDate, LoanType, RequestedAmount, Status, RejectionReason) VALUES
(1, 1, '2021-01-10', 'Personal', 15000.00, 'Approved', NULL),
(2, 2, '2021-01-15', 'Car', 8000.00, 'Approved', NULL),
(3, 3, '2020-12-20', 'Personal', 20000.00, 'Rejected', 'Low credit score'),
(4, 4, '2021-02-05', 'Home', 50000.00, 'Rejected', 'Insufficient income'),
(5, 5, '2020-08-10', 'Personal', 3000.00, 'Approved', NULL),
(6, 15, '2019-11-20', 'Car', 6000.00, 'Approved', NULL),
(7, 17, '2019-06-10', 'Home', 25000.00, 'Approved', NULL),
(8, 22, '2021-03-15', 'Personal', 5000.00, 'Pending', NULL),
(9, 25, '2019-08-05', 'Car', 9000.00, 'Rejected', 'Unstable employment'),
(10, 28, '2020-12-20', 'Personal', 4000.00, 'Rejected', 'High debt-to-income ratio');

INSERT INTO Credit_Scores (CustomerID, ScoreDate, CreditScore) VALUES
(1, '2020-01-01', 720),
(1, '2021-01-01', 735),
(1, '2022-01-01', 750),
(2, '2020-01-01', 680),
(2, '2021-01-01', 690),
(2, '2022-01-01', 695),
(3, '2020-01-01', 550),
(3, '2021-01-01', 540),
(3, '2022-01-01', 530),
(4, '2020-01-01', 620),
(5, '2020-01-01', 590),
(5, '2021-01-01', 570),
(6, '2020-01-01', 710),
(6, '2021-01-01', 720),
(7, '2020-01-01', 780),
(8, '2020-01-01', 650),
(9, '2020-01-01', 700),
(10, '2020-01-01', 640),
(11, '2020-01-01', 730),
(12, '2020-01-01', 680),
(13, '2020-01-01', 610),
(14, '2020-01-01', 720),
(15, '2020-01-01', 670),
(16, '2020-01-01', 740),
(17, '2020-01-01', 790),
(18, '2020-01-01', 660),
(19, '2020-01-01', 600),
(20, '2020-01-01', 710),
(21, '2020-01-01', 750),
(22, '2020-01-01', 630),
(23, '2020-01-01', 580),
(23, '2021-01-01', 560),
(24, '2020-01-01', 690),
(25, '2020-01-01', 540),
(26, '2020-01-01', 720),
(27, '2020-01-01', 680),
(28, '2020-01-01', 610),
(29, '2020-01-01', 700),
(30, '2020-01-01', 730);

INSERT INTO Risk_Assessment (CustomerID, AssessmentDate, RiskLevel, Notes) VALUES
(1, '2022-01-15', 'Low', 'Excellent payment history, improving credit'),
(2, '2022-01-15', 'Low', 'Stable income, good credit'),
(3, '2022-01-15', 'High', 'Declining credit score, late payments'),
(4, '2022-01-15', 'Medium', 'Limited credit history'),
(5, '2022-01-15', 'Medium', 'Declining credit score'),
(6, '2022-01-15', 'Low', 'Strong credit, multiple accounts'),
(7, '2022-01-15', 'Low', 'Excellent credit score'),
(8, '2022-01-15', 'Medium', 'Average credit profile'),
(9, '2022-01-15', 'Low', 'Good payment history'),
(10, '2022-01-15', 'Medium', 'Average credit score'),
(15, '2022-01-15', 'Medium', 'Active loan, moderate risk'),
(17, '2022-01-15', 'Low', 'Excellent credit, large home loan'),
(19, '2022-01-15', 'Medium', 'Lower credit score'),
(23, '2022-01-15', 'High', 'Late payments, declining credit'),
(25, '2022-01-15', 'High', 'Defaulted loan, very high risk'),
(29, '2022-01-15', 'Low', 'Good credit profile');
