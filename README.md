# Customer-Churn-Analysis-Retention-Dashboard
Domain - Telcom


🔹 Project Overview

Customer churn is a critical business problem in subscription-based industries such as telecom. Retaining existing customers is significantly more cost-effective than acquiring new ones. This project analyzes customer churn behavior using SQL and visualizes key insights through an interactive Power BI dashboard.

The project follows an industry-level data analytics workflow, including data modeling (star schema), SQL-based exploratory data analysis (EDA), and dashboard development.


**🎯 Business Objectives**

* Measure overall customer churn rate
* Identify high-risk customer segments
* Analyze churn patterns by contract type, payment method, tenure, and demographics
* Provide actionable insights for customer retention strategies


 **🗂 Dataset**

* Source: Telco Customer Churn Dataset (https://github.com/nikhilsthorat03/Telco-Customer-Churn/blob/main/telco.csv)
* Format: CSV
* Records: 7032 customers
* Description: Customer demographics, subscription details, payment information, and churn status


**🏗 Data Modeling (Star Schema)**

**Fact Table**

churn_fact

* churn_fact_id (PK)
* customer_id (FK)
* subscription_dim_id (FK)
* churn_flag (1 = churned, 0 = active)

**Dimension Tables**

customer_dim

* customer_id (PK)
* gender
* senior_citizen
* partner
* dependents

subscription_dim

* subscription_dim_id (PK)
* customer_id
* tenure
* contract
* payment_method
* monthly_charges
* total_charges

✔ This structure follows industry-standard star schema modeling for BI and analytics.


**🧹 Data Preparation & Cleaning**

* Converted raw CSV data into normalized dimension and fact tables
* Created surrogate keys for dimensions
* Ensured correct data types for numerical analysis
* Validated referential integrity between tables


**🔍 SQL Exploratory Data Analysis (EDA)**

Key analyses performed using MySQL:

* Overall churn rate calculation
* Churn by contract type
* Churn by payment method
* Churn by tenure 
* Churn by customer demographics
* Identification of high-risk customer segments

✔ All Power BI metrics were validated against SQL queries to ensure accuracy.


**📈 Power BI Dashboard**

Dashboard Features

* KPI card showing overall churn rate
* Churn analysis by contract type
* Churn distribution by payment method
* Churn trends by customer tenure
* High-risk customer segment table
* Interactive slicers (gender, senior citizen, partner, dependents)


**🛠 Tools & Technologies**

* SQL: MySQL (EDA, joins, aggregations)
* BI Tool: Power BI
* Data Modeling: Star Schema
* Version Control: GitHub


**📌 Key Business Insights**

* Two-year contracts have the highest churn rate
* Customers using electronic check payments churn more rarely
* New customers (0–6 months tenure) are at highest risk
* Combining tenure, contract, and payment method identifies high-risk segments for retention campaigns


**📎 Project Structure**

Customer-Churn-Analysis/
│
├── data/
│   └── telco.csv
├── sql/
│   ├── table_creation.sql
│   ├── data_cleaning.sql
│   └── churn_eda.sql
├── powerbi/
│   └── churn_dashboard.pbix
├── images/
│   └── dashboard_screenshots.png
└── README.md


**🚀 Outcomes**

* Built an end-to-end analytics solution from raw data to insights
* Applied industry best practices in data modeling and BI


