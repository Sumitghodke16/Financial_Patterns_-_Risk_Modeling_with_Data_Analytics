select * from [dbo].[personal_finance]
-----------------------------------------------------
-- 1. What is the average monthly income vs. average monthly expense?
-----------------------------------------------------
SELECT 
    AVG(monthly_income_usd) AS avg_income,
    AVG(monthly_expenses_usd) AS avg_expense
FROM personal_finance;

-----------------------------------------------------
-- 2. Which category of expenses consumes the highest % of income?

-----------------------------------------------------
SELECT TOP 1 
    job_title,
    SUM(monthly_expenses_usd) * 100.0 / SUM(monthly_income_usd) AS expense_pct_of_income
FROM personal_finance
GROUP BY job_title
ORDER BY expense_pct_of_income DESC;

-----------------------------------------------------
-- 3. How many people are living paycheck to paycheck (expenses ≥ income)?
-----------------------------------------------------
SELECT COUNT(*) AS paycheck_to_paycheck
FROM personal_finance
WHERE monthly_expenses_usd >= monthly_income_usd;

-----------------------------------------------------
-- 4. What is the total savings generated across all customers?
-----------------------------------------------------
SELECT SUM(CAST(savings_usd AS DECIMAL(18, 2))) AS total_savings
FROM personal_finance;

-----------------------------------------------------
-- 5. Rank top 10 customers with highest monthly surplus (income – expense).
-----------------------------------------------------
SELECT TOP 10 
    user_id,
    (monthly_income_usd - monthly_expenses_usd) AS monthly_surplus
FROM personal_finance
ORDER BY monthly_surplus DESC;

-----------------------------------------------------
-- 6. What is the median savings rate across all individuals?
-----------------------------------------------------
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY savings_to_income_ratio) 
    OVER () AS median_savings_rate
FROM personal_finance;

-----------------------------------------------------
-- 7. Find customers saving more than 20% of their income.
-----------------------------------------------------
SELECT user_id, monthly_income_usd, savings_usd, savings_to_income_ratio
FROM personal_finance
WHERE savings_to_income_ratio > 20;

-----------------------------------------------------
-- 8. Which investment category has the most participation?
-- 
-----------------------------------------------------
SELECT loan_type, COUNT(*) AS participation_count
FROM personal_finance
GROUP BY loan_type
ORDER BY participation_count DESC;

-----------------------------------------------------
-- 9. List top 5 customers with highest total investment amount.
--
-----------------------------------------------------
SELECT TOP 5 
    user_id, savings_usd
FROM personal_finance
ORDER BY savings_usd DESC;

-----------------------------------------------------
-- 10. Compare investment-to-income ratio across different income groups.
-----------------------------------------------------
SELECT 
    CASE 
        WHEN monthly_income_usd < 2000 THEN 'Low Income'
        WHEN monthly_income_usd BETWEEN 2000 AND 5000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS income_group,
    AVG(savings_to_income_ratio) AS avg_investment_to_income_ratio
FROM personal_finance
GROUP BY 
    CASE 
        WHEN monthly_income_usd < 2000 THEN 'Low Income'
        WHEN monthly_income_usd BETWEEN 2000 AND 5000 THEN 'Middle Income'
        ELSE 'High Income'
    END;

-----------------------------------------------------
-- 11. What percentage of people have EMI-to-Income ratio > 40%?
-----------------------------------------------------
SELECT 
    (COUNT(CASE WHEN (monthly_emi_usd * 100.0 / monthly_income_usd) > 40 THEN 1 END) * 100.0) / COUNT(*) 
    AS pct_high_emi_burden
FROM personal_finance;

-----------------------------------------------------
-- 12. What is the average outstanding loan amount per age group?
-----------------------------------------------------
SELECT 
    CASE 
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 50 THEN '30-50'
        ELSE 'Above 50'
    END AS age_group,
    AVG(loan_amount_usd) AS avg_outstanding_loan
FROM personal_finance
GROUP BY 
    CASE 
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 50 THEN '30-50'
        ELSE 'Above 50'
    END;

-----------------------------------------------------
-- 13. Which loan type has the highest default risk (based on EMI burden)?
-----------------------------------------------------
SELECT TOP 1 
    loan_type,
    AVG(monthly_emi_usd * 100.0 / monthly_income_usd) AS avg_emi_burden
FROM personal_finance
GROUP BY loan_type
ORDER BY avg_emi_burden DESC;

-----------------------------------------------------
-- 14. Which users would be denied loans under DTI > 50% and Credit Score < 650?
-----------------------------------------------------
SELECT user_id, debt_to_income_ratio, credit_score
FROM personal_finance
WHERE debt_to_income_ratio > 50 AND credit_score < 650;

-----------------------------------------------------
-- 15. Find the top 5 customers with highest EMI amounts.
-----------------------------------------------------
SELECT TOP 5 
    user_id, monthly_emi_usd
FROM personal_finance
ORDER BY monthly_emi_usd DESC;

-----------------------------------------------------
-- 16. Do married people save more than single people?
-----------------------------------------------------
SELECT 
    employment_status, 
    ROUND(AVG(CAST(savings_usd AS DECIMAL(18, 2))), 2) AS avg_savings
FROM 
    personal_finance
GROUP BY 
    employment_status;   

-----------------------------------------------------
-- 17. Is there a gender difference in average income?
-----------------------------------------------------
SELECT gender, AVG(monthly_income_usd) AS avg_income
FROM personal_finance
GROUP BY gender;

-----------------------------------------------------
-- 18. Which profession has the highest savings-to-income ratio?
-----------------------------------------------------
SELECT TOP 1 
    job_title,
    AVG(savings_to_income_ratio) AS avg_ratio
FROM personal_finance
GROUP BY job_title
ORDER BY avg_ratio DESC;

-----------------------------------------------------
-- 19. What are the top 3 expense categories by age group?

-----------------------------------------------------
SELECT age_group, job_title, total_expenses
FROM (
    SELECT 
        CASE 
            WHEN age < 30 THEN 'Under 30'
            WHEN age BETWEEN 30 AND 50 THEN '30-50'
            ELSE 'Above 50'
        END AS age_group,
        job_title,
        SUM(monthly_expenses_usd) AS total_expenses,
        RANK() OVER (PARTITION BY 
            CASE 
                WHEN age < 30 THEN 'Under 30'
                WHEN age BETWEEN 30 AND 50 THEN '30-50'
                ELSE 'Above 50'
            END ORDER BY SUM(monthly_expenses_usd) DESC) AS rnk
    FROM personal_finance
    GROUP BY 
        CASE 
            WHEN age < 30 THEN 'Under 30'
            WHEN age BETWEEN 30 AND 50 THEN '30-50'
            ELSE 'Above 50'
        END,
        job_title
) t
WHERE rnk <= 3;

-----------------------------------------------------
-- 20. Which region/city has the highest average income?
-----------------------------------------------------
SELECT TOP 1 
    region, AVG(monthly_income_usd) AS avg_income
FROM personal_finance
GROUP BY region
ORDER BY avg_income DESC;

-----------------------------------------------------
-- 21. Classify customers into Low / Medium / High Risk based on EMI-to-Income thresholds.
-----------------------------------------------------
SELECT 
    user_id,
    CASE 
        WHEN (monthly_emi_usd * 100.0 / monthly_income_usd) < 20 THEN 'Low Risk'
        WHEN (monthly_emi_usd * 100.0 / monthly_income_usd) BETWEEN 20 AND 40 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_bucket
FROM personal_finance;

-----------------------------------------------------
-- 22. How many qualify for tax rebate if savings >20% of income?
-----------------------------------------------------
SELECT COUNT(*) AS rebate_qualifiers
FROM personal_finance
WHERE savings_to_income_ratio > 20;

-----------------------------------------------------
-- 23. How many fall below poverty line if income drops by 15%?
-----------------------------------------------------
SELECT COUNT(*) AS below_poverty_after_drop
FROM personal_finance
WHERE (monthly_income_usd * 0.85) < 1000;

-- 24. List customers whose expenses exceed income after 10% inflation rise.
-----------------------------------------------------
SELECT user_id, monthly_income_usd, monthly_expenses_usd
FROM personal_finance
WHERE (monthly_expenses_usd * 1.1) > monthly_income_usd;
-----------------------------------------------------

-- 25. Identify customers most at risk (low savings + high EMI + high debt).
SELECT user_id, savings_usd, monthly_emi_usd, debt_to_income_ratio
FROM personal_finance
WHERE savings_usd < 500 
  AND (monthly_emi_usd * 100.0 / monthly_income_usd) > 40
  AND debt_to_income_ratio > 50;
