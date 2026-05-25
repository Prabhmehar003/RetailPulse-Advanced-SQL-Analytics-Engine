# 🛒 RetailPulse — Advanced SQL Analytics Engine
### End-to-End Retail Sales Intelligence with PostgreSQL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange?style=for-the-badge&logo=databricks&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

---

## 📌 Project Overview

**RetailPulse** is a production-grade SQL analytics project built entirely in PostgreSQL. It goes far beyond basic queries — covering the full data lifecycle from schema design and data quality enforcement, through exploratory analysis, to boardroom-ready business intelligence using advanced window functions, CTEs, and customer segmentation.

> Built to demonstrate real-world analytical thinking — not just syntax.

---

## 🎯 Business Questions Answered

| # | Question | Technique |
|---|----------|-----------|
| 1 | Which product categories drive the most revenue? | `GROUP BY`, `SUM`, window `OVER()` |
| 2 | What is the best-selling month per year? | `RANK()` window function |
| 3 | Who are the top 5 customers by lifetime spend? | Aggregation + `LIMIT` |
| 4 | How does revenue grow month-over-month? | `LAG()` window function |
| 5 | Which customer segments should be prioritised? | RFM Segmentation + `NTILE()` |
| 6 | What is the gross profit margin per category? | COGS vs Revenue analysis |
| 7 | How do sales distribute across Morning / Afternoon / Evening? | `CASE` + `EXTRACT(HOUR)` |
| 8 | Which category ranks highest in revenue each month? | `DENSE_RANK()` |

---

## 🗂️ Project Structure

```
retail-sql-analytics/
│
├── retail_sales_analysis.sql     ← Main project file (all 7 sections)
├── README.md                     ← You are here
└── dataset/
    └── retail_sales.csv          ← Source dataset (import before running)
```

---

## 🔧 Database Schema

```sql
CREATE TABLE retail_sales (
    transactions_id   INT PRIMARY KEY,
    sale_date         DATE          NOT NULL,
    sale_time         TIME          NOT NULL,
    customer_id       INT           NOT NULL,
    gender            VARCHAR(15),
    age               INT           CHECK (age BETWEEN 0 AND 120),
    category          VARCHAR(20),
    quantity          INT           CHECK (quantity > 0),
    price_per_unit    NUMERIC(10,2),
    cogs              NUMERIC(10,2),
    total_sale        NUMERIC(10,2)
);
```

---

## 🚀 Getting Started

### Prerequisites
- PostgreSQL 13 or higher
- pgAdmin 4 / DBeaver / psql CLI

### Setup

```bash
# 1. Clone this repository
git clone https://github.com/your-username/retailpulse-sql-analytics.git
cd retailpulse-sql-analytics

# 2. Create the database
psql -U postgres -c "CREATE DATABASE retail_db;"

# 3. Connect and run the script
psql -U postgres -d retail_db -f retail_sales_analysis.sql
```

> **💡 Tip:** Import `dataset/retail_sales.csv` via pgAdmin's Import/Export tool or using `\COPY` in psql before running analysis sections.

---

## 📊 What's Inside — Section by Section

### Section 1 — Schema Design
Carefully typed schema with data integrity constraints (`PRIMARY KEY`, `CHECK`, `NOT NULL`) applied at the database level — not just in application code.

### Section 2 — Data Quality & Cleaning
A rigorous 5-step cleaning pipeline:
- NULL detection across all columns
- Duplicate transaction ID validation
- **Logical consistency check** — verifies `total_sale = quantity × price_per_unit`
- **Statistical outlier detection** using the IQR method
- Safe deletion of dirty records

### Section 3 — Exploratory Data Analysis (EDA)
Dataset profiling: date range, revenue totals, unique customer count, gender distribution per category, and revenue share percentages using `SUM() OVER()`.

### Section 4 — Core Business Analytics
10 targeted business queries covering date filters, category performance, age demographics, high-value transactions, and time-shift analysis.

### Section 5 — Advanced Analytics ⭐
The standout section — techniques used by professional data analysts:

| Analysis | Window Function Used |
|----------|---------------------|
| Month-over-Month Revenue Growth | `LAG()` |
| Year-to-Date Cumulative Revenue | `SUM() OVER(PARTITION BY year ORDER BY date)` |
| Customer RFM Segmentation | `NTILE(4)` |
| Category Revenue Ranking per Month | `DENSE_RANK()` |
| Gross Profit Margin by Category | COGS-based calculation with `NULLIF` guard |

### Section 6 — Reporting Views
Two reusable SQL views for dashboarding and BI tools:
- `vw_category_kpi` — category-level KPI rollup
- `vw_daily_revenue` — daily sales with YTD running total

### Section 7 — Performance Optimisation
Four production-ready indexes including a **partial index** on high-value transactions and a **composite index** for customer LTV queries.

---

## 💡 Key SQL Concepts Demonstrated

- **Window Functions:** `RANK()`, `DENSE_RANK()`, `LAG()`, `NTILE()`, `SUM() OVER()`
- **CTEs:** Multi-level `WITH` clauses for readable, layered logic
- **Statistical Methods:** IQR-based outlier detection
- **Customer Analytics:** Full RFM (Recency, Frequency, Monetary) segmentation
- **Data Integrity:** Constraint-level validation + logical consistency checks
- **Performance Tuning:** Partial indexes, composite indexes
- **Reusability:** SQL Views for reporting layer abstraction

---

## 📈 Sample Insight — RFM Segmentation Output

| Customer ID | Frequency | Monetary | Segment |
|-------------|-----------|----------|---------|
| C1042 | 18 | ₹48,230 | 🏆 Champion |
| C1089 | 12 | ₹31,500 | 💛 Loyal Customer |
| C1003 | 6 | ₹14,800 | 🌱 Potential Loyalist |
| C1071 | 2 | ₹3,200 | 🆕 New Customer |
| C1055 | 1 | ₹890 | ⚠️ At Risk |

---

## 👤 Author

**Prabhmehar Dhalio**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=flat&logo=linkedin)](https://linkedin.com/in/prabhmehar-dhalio/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat&logo=github)](https://github.com/Prabhmehar003)

---

## 📄 License

This project is licensed under the MIT License — feel free to use, adapt, and build on it.

---

> *"Data is only as valuable as the questions you ask of it."*
