# Credit Risk Database Project

This is a small SQL database I built to explore banking credit risk. It contains tables for customers, accounts, loans, payments, credit scores, and risk assessment.  

I used sample data from Kaggle to test queries and practice SQL.

## Tables in the database

- **Customers**: personal information (name, DOB, contact)  
- **Accounts**: types of accounts and balances  
- **Loans**: loan types, amounts, interest, and status  
- **Payments**: payments made toward loans  
- **Payment_Schedule**: detailed payment tracking  
- **Loan_Applications**: records of loan requests and their outcomes  
- **Credit_Scores**: credit scores by date  
- **Risk_Assessment**: manual risk levels for each customer  

## What you can do

- Check customers with late payments  
- Calculate total loan amount by status  
- Track improving or declining credit scores  
- Analyze interest earned by loan type  
- Find high-risk customers with active loans  
- Explore payment performance and outstanding balances  

## How to use

1. Load `database.sql` in MySQL, SQLite, or PostgreSQL.  
2. All tables and sample data are included.  
3. Run queries from `sample_queries.sql` to explore the data.  

## Quick tips

- Start with the **Data Cleaning & Exploring** section to make sure the data is consistent.  
- Then move to **Quick Data Exploring** for overview stats.  
- Finally, use **Useful Queries** to analyze credit risk trends.  
