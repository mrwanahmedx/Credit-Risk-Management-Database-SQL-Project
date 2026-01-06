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
(1, 'Ahmed', 'Ali', '1985-06-15', 'ahmed.ali@email.com', '01012345678', 'Cairo, Egypt'),
(2, 'Sara', 'Hassan', '1990-11-02', 'sara.hassan@email.com', '01023456789', 'Giza, Egypt'),
(3, 'Omar', 'Mostafa', '1978-03-21', 'omar.mostafa@email.com', '01034567890', 'Alexandria, Egypt'),
(4, 'Mona', 'Fahmy', '1995-07-10', 'mona.fahmy@email.com', '01045678901', 'Cairo, Egypt'),
(5, 'Youssef', 'Khaled', '1982-12-05', 'youssef.khaled@email.com', '01056789012', 'Giza, Egypt'),
(6, 'Laila', 'Samir', '1988-04-18', 'laila.samir@email.com', '01067890123', 'Cairo, Egypt'),
(7, 'Tamer', 'Ibrahim', '1975-09-12', 'tamer.ibrahim@email.com', '01078901234', 'Alexandria, Egypt'),
(8, 'Dina', 'Mahmoud', '1992-01-25', 'dina.mahmoud@email.com', '01089012345', 'Cairo, Egypt'),
(9, 'Hany', 'Naguib', '1980-08-30', 'hany.naguib@email.com', '01090123456', 'Giza, Egypt'),
(10, 'Rania', 'Said', '1993-05-17', 'rania.said@email.com', '01001234567', 'Cairo, Egypt'),
(11, 'Amr', 'Fathi', '1984-02-11', 'amr.fathi@email.com', '01011223344', 'Cairo, Egypt'),
(12, 'Salma', 'Youssef', '1991-10-22', 'salma.youssef@email.com', '01022334455', 'Giza, Egypt'),
(13, 'Khaled', 'Mokhtar', '1979-06-08', 'khaled.mokhtar@email.com', '01033445566', 'Alexandria, Egypt'),
(14, 'Noha', 'Mahmoud', '1994-12-18', 'noha.mahmoud@email.com', '01044556677', 'Cairo, Egypt'),
(15, 'Fady', 'Adel', '1983-08-30', 'fady.adel@email.com', '01055667788', 'Giza, Egypt'),
(16, 'Mariam', 'Sami', '1990-03-15', 'mariam.sami@email.com', '01066778899', 'Cairo, Egypt'),
(17, 'Hassan', 'Omar', '1981-07-21', 'hassan.omar@email.com', '01077889900', 'Alexandria, Egypt'),
(18, 'Lina', 'Fouad', '1992-09-12', 'lina.fouad@email.com', '01088990011', 'Cairo, Egypt'),
(19, 'Walid', 'Ibrahim', '1985-01-30', 'walid.ibrahim@email.com', '01099001122', 'Giza, Egypt'),
(20, 'Rana', 'Sami', '1993-05-02', 'rana.sami@email.com', '01010111223', 'Cairo, Egypt'),
(21, 'Omar', 'Fawzy', '1977-11-14', 'omar.fawzy@email.com', '01012131415', 'Cairo, Egypt'),
(22, 'Heba', 'Tarek', '1995-07-07', 'heba.tarek@email.com', '01013141516', 'Giza, Egypt'),
(23, 'Karim', 'Salah', '1980-12-25', 'karim.salah@email.com', '01014151617', 'Alexandria, Egypt'),
(24, 'Mona', 'Adel', '1992-06-05', 'mona.adel@email.com', '01015161718', 'Cairo, Egypt'),
(25, 'Amira', 'Nabil', '1987-03-11', 'amira.nabil@email.com', '01016171819', 'Giza, Egypt'),
(26, 'Tamer', 'Hussein', '1982-09-20', 'tamer.hussein@email.com', '01017181920', 'Cairo, Egypt'),
(27, 'Dina', 'Youssef', '1991-04-01', 'dina.youssef@email.com', '01018192021', 'Alexandria, Egypt'),
(28, 'Adel', 'Khalil', '1978-10-28', 'adel.khalil@email.com', '01019202122', 'Cairo, Egypt'),
(29, 'Salma', 'Fathy', '1990-08-17', 'salma.fathy@email.com', '01020212223', 'Giza, Egypt'),
(30, 'Fadi', 'Mahmoud', '1983-05-25', 'fadi.mahmoud@email.com', '01021222324', 'Cairo, Egypt'),
(31, 'Rania', 'Khaled', '1992-12-12', 'rania.khaled@email.com', '01022232425', 'Alexandria, Egypt'),
(32, 'Hany', 'Sami', '1984-07-19', 'hany.sami@email.com', '01023242526', 'Cairo, Egypt'),
(33, 'Laila', 'Tamer', '1988-01-05', 'laila.tamer@email.com', '01024252627', 'Giza, Egypt'),
(34, 'Walid', 'Fouad', '1979-09-09', 'walid.fouad@email.com', '01025262728', 'Cairo, Egypt'),
(35, 'Heba', 'Omar', '1993-02-21', 'heba.omar@email.com', '01026272829', 'Alexandria, Egypt'),
(36, 'Karim', 'Sami', '1981-06-30', 'karim.sami@email.com', '01027282930', 'Cairo, Egypt'),
(37, 'Mona', 'Hassan', '1990-11-11', 'mona.hassan@email.com', '01028293031', 'Giza, Egypt'),
(38, 'Amr', 'Adel', '1985-03-03', 'amr.adel@email.com', '01029303132', 'Cairo, Egypt'),
(39, 'Dina', 'Fathy', '1992-08-18', 'dina.fathy@email.com', '01030313233', 'Alexandria, Egypt'),
(40, 'Tamer', 'Mahmoud', '1986-05-07', 'tamer.mahmoud@email.com', '01031323334', 'Cairo, Egypt'),
(41, 'Sara', 'Nabil', '1991-09-12', 'sara.nabil@email.com', '01032333435', 'Giza, Egypt'),
(42, 'Omar', 'Hassan', '1980-12-01', 'omar.hassan@email.com', '01033343536', 'Cairo, Egypt'),
(43, 'Mariam', 'Fouad', '1989-04-04', 'mariam.fouad@email.com', '01034353637', 'Alexandria, Egypt'),
(44, 'Hany', 'Khaled', '1982-06-15', 'hany.khaled@email.com', '01035363738', 'Cairo, Egypt'),
(45, 'Rania', 'Mahmoud', '1994-10-10', 'rania.mahmoud@email.com', '01036373839', 'Giza, Egypt'),
(46, 'Fady', 'Adel', '1983-01-01', 'fady.adel@email.com', '01037383940', 'Cairo, Egypt'),
(47, 'Noha', 'Sami', '1992-03-14', 'noha.sami@email.com', '01038394041', 'Alexandria, Egypt'),
(48, 'Lina', 'Tamer', '1985-07-23', 'lina.tamer@email.com', '01039404142', 'Cairo, Egypt'),
(49, 'Walid', 'Sami', '1981-11-30', 'walid.sami@email.com', '01040414243', 'Giza, Egypt'),
(50, 'Mona', 'Fouad', '1990-02-28', 'mona.fouad@email.com', '01041424344', 'Cairo, Egypt');

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

INSERT INTO Payment_Schedule (ScheduleID, LoanID, DueDate, DueAmount, PaidDate, PaidAmount, LateDays) VALUES
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

INSERT INTO Loan_Applications (ApplicationID, CustomerID, ApplicationDate, LoanType, Amount, Status, RejectionReason) VALUES
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

INSERT INTO Credit_Scores (CustomerID, Date, Score) VALUES
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
