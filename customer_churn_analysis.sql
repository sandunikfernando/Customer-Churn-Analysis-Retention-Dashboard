CREATE DATABASE telco_churn_analysis_new;

DESCRIBE telco;

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN TotalCharges IS NULL OR TotalCharges = '' THEN 1 ELSE 0 END) AS missing_total_charges
FROM telco;

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN tenure IS NULL OR tenure = '' THEN 1 ELSE 0 END) AS missing_tenure
FROM telco;

ALTER TABLE telco
MODIFY COLUMN TotalCharges DECIMAL(10,2);

SET SQL_SAFE_UPDATES = 0;

UPDATE telco
SET OnlineSecurity = 'No'
WHERE OnlineSecurity = 'No internet service';

SELECT * FROM telco;


UPDATE telco
SET OnlineBackup = 'No'
WHERE OnlineBackup = 'No internet service';

UPDATE telco
SET DeviceProtection = 'No'
WHERE DeviceProtection = 'No internet service';

UPDATE telco
SET TechSupport = 'No'
WHERE TechSupport = 'No internet service';

UPDATE telco
SET StreamingTV = 'No'
WHERE StreamingTV = 'No internet service';

UPDATE telco
SET StreamingMovies = 'No'
WHERE StreamingMovies = 'No internet service';

UPDATE telco
SET MultipleLines = 'No'
WHERE MultipleLines = 'No phone service';

SELECT customerID, COUNT(*) 
FROM telco
GROUP BY customerID
HAVING COUNT(*) > 1;

ALTER TABLE telco ADD churn_flag INT;

UPDATE telco
SET churn_flag = CASE WHEN Churn = 'Stayed' THEN 1 ELSE 0 END;

SELECT * FROM telco;


CREATE TABLE customer_dim AS
SELECT DISTINCT
    customerID AS customer_id,
    gender,
    SeniorCitizen AS senior_citizen,
    Partner AS partner,
    Dependents AS dependents
FROM telco;

SELECT * FROM customer_dim;


CREATE TABLE subscription_dim AS
SELECT 
    customerID AS customer_id,
    tenure,
    Contract AS contract,
    PaymentMethod AS payment_method,
    MonthlyCharges AS monthly_charges,
    CAST(NULLIF(TRIM(TotalCharges),'') AS DECIMAL(10,2)) AS total_charges
FROM telco;

SELECT * FROM subscription_dim;


CREATE TABLE churn_fact AS
SELECT 
    customerID AS customer_id,
    churn_flag AS churn_flag
    -- CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS churn_flag
FROM telco;

SELECT * FROM churn_fact;


ALTER TABLE customer_dim ADD customer_dim_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE subscription_dim ADD subscription_dim_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE churn_fact ADD churn_fact_id INT AUTO_INCREMENT PRIMARY KEY;


-- Add subscription_dim_id
ALTER TABLE subscription_dim ADD subscription_dim_id INT AUTO_INCREMENT PRIMARY KEY;

-- Add subscription_dim_id to churn_fact
ALTER TABLE churn_fact ADD subscription_dim_id INT;

-- Update churn_fact with IDs
UPDATE churn_fact ch
JOIN subscription_dim s ON ch.customer_id = s.customer_id
SET ch.subscription_dim_id = s.subscription_dim_id;

SET SQL_SAFE_UPDATES = 0;




-- EDA

-- Overall Churn Rate
-- Business Question: How many customers are leaving overall?
-- Insight: Gives total customers, churned customers, and overall churn %.

SELECT 
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag)/COUNT(*)*100,2) AS churn_rate_percent
FROM churn_fact;



-- Churn by Contract Type
-- Business Question: Which contracts are riskier?
-- Insight: Month-to-month contracts usually have higher churn, 1-year and 2-year are safer.

SELECT 
    s.contract,
    COUNT(*) AS total_customers,
    SUM(c.churn_flag) AS churned_customers,
    ROUND(SUM(c.churn_flag)/COUNT(*)*100,2) AS churn_rate_percent
FROM subscription_dim s
JOIN churn_fact c ON s.customer_id = c.customer_id
GROUP BY s.contract
ORDER BY churn_rate_percent DESC;




-- Churn by Payment Method
-- Business Question: Does payment method influence churn?
-- Insight: Electronic check users often churn more than credit card users.


SELECT 
    s.payment_method,
    COUNT(*) AS total_customers,
    SUM(c.churn_flag) AS churned_customers,
    ROUND(SUM(c.churn_flag)/COUNT(*)*100,2) AS churn_rate_percent
FROM subscription_dim s
JOIN churn_fact c ON s.customer_id = c.customer_id
GROUP BY s.payment_method
ORDER BY churn_rate_percent DESC;





-- Churn by Tenure Groups
-- Business Question: Do newer customers churn more?
-- Insight: Customers in first 6 months are usually high-risk.


SELECT 
    CASE 
        WHEN s.tenure <= 6 THEN '0-6 months'
        WHEN s.tenure <= 12 THEN '7-12 months'
        WHEN s.tenure <= 24 THEN '13-24 months'
        ELSE '25+ months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(c.churn_flag) AS churned_customers,
    ROUND(SUM(c.churn_flag)/COUNT(*)*100,2) AS churn_rate_percent
FROM subscription_dim s
JOIN churn_fact c ON s.customer_id = c.customer_id
GROUP BY tenure_group
ORDER BY tenure_group;




-- Churn by Monthly Charges
-- Business Question: Do high-paying customers churn more?
-- Insight: High-paying customers ($70+) sometimes churn more — useful for retention campaigns.


SELECT 
    CASE 
        WHEN s.monthly_charges < 35 THEN '<$35'
        WHEN s.monthly_charges < 70 THEN '$35-$69'
        ELSE '$70+' 
    END AS charges_group,
    COUNT(*) AS total_customers,
    SUM(c.churn_flag) AS churned_customers,
    ROUND(SUM(c.churn_flag)/COUNT(*)*100,2) AS churn_rate_percent
FROM subscription_dim s
JOIN churn_fact c ON s.customer_id = c.customer_id
GROUP BY charges_group
ORDER BY charges_group;




-- Combine Multiple Factors – High-Risk Segment
-- Business Question: Which combination of factors identifies high-risk customers?
-- Insight: Helps target retention campaigns to the most at-risk customers


SELECT 
    s.contract,
    s.payment_method,
    CASE 
        WHEN s.tenure <= 6 THEN '0-6 months'
        WHEN s.tenure <= 12 THEN '7-12 months'
        ELSE '12+ months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(c.churn_flag) AS churned_customers,
    ROUND(SUM(c.churn_flag)/COUNT(*)*100,2) AS churn_rate_percent
FROM subscription_dim s
JOIN churn_fact c ON s.customer_id = c.customer_id
GROUP BY s.contract, s.payment_method, tenure_group
HAVING churn_rate_percent > 25
ORDER BY churn_rate_percent DESC;




-- check the values with dashbaord
SELECT 
    s.contract,
    COUNT(*) AS total_customers,
    SUM(f.churn_flag) AS churned_customers,
    ROUND(SUM(f.churn_flag) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM churn_fact f
JOIN subscription_dim s 
    ON f.subscription_dim_id = s.subscription_dim_id
GROUP BY s.contract
ORDER BY churn_rate_percent DESC;

SELECT * FROM subscription_dim;


