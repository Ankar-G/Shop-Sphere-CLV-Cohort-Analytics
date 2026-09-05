# 🛍️ Shop Sphere — Customer Lifetime Value & Cohort Analytics

> An end-to-end SQL + Power BI project analyzing customer value, retention, and acquisition performance for an e-commerce business.

---

## 📌 Table of Contents

* [Project Overview](#project-overview)
* [Problem Statement](#problem-statement)
* [Business Objectives](#business-objectives)
* [Project Workflow](#project-workflow)
* [SQL Analysis](#sql-analysis)
* [Customer Analysis](#customer-analysis)
* [RFM Segmentation](#rfm-segmentation)
* [Cohort & Retention Analysis](#cohort--retention-analysis)
* [CLV & Customer Value Analysis](#clv--customer-value-analysis)
* [Acquisition Analysis](#acquisition-analysis)
* [Business KPIs](#business-kpis)
* [Power BI Dashboard](#power-bi-dashboard)
* [Key Insights](#key-insights)
* [Tech Stack](#tech-stack)
* [Project Structure](#project-structure)
* [How to Run](#how-to-run)
* [Dashboard Preview](#dashboard-preview)
* [Connect With Me](#connect-with-me)

---

## 📖 Project Overview

Shop Sphere is an end-to-end data analytics project built to help an e-commerce business understand the value of its customer base. Using SQL for data preparation and business analysis, and Power BI for interactive reporting, the project brings together customer transactions, product data, and returns into a single analytical view of **customer lifetime value, retention behaviour, and acquisition performance**.

Rather than treating every customer the same, this project segments the customer base by value and behaviour, tracks how customers from different signup cohorts are retained over time, and evaluates which acquisition channels and campaigns are actually bringing in valuable, repeat customers. The result is a dashboard suite that a marketing or growth team could realistically use to prioritize retention efforts and reallocate acquisition budget.

---

## ❓ Problem Statement

The company has a large customer base but lacks a clear understanding of:

* Which customers are most valuable to the business
* How customer retention changes over time and across signup cohorts
* What purchasing behaviours (frequency, repeat orders) are linked to higher customer value
* Which acquisition channels and campaigns bring in high-value, long-term customers

---

## 🎯 Business Objectives

| Objective                | Description |
| ------------------------ | ----------- |
| Customer Value Analysis  | Quantify historical customer value and identify which customers drive the most revenue. |
| RFM Segmentation         | Segment customers by Recency, Frequency, and Monetary value to identify Champions, Loyal Customers, Potential Loyalists, At Risk, and Lost Customers. |
| Retention Analysis       | Measure overall customer retention rate and repeat purchase behaviour. |
| Cohort Analysis          | Track how customers from each signup cohort continue purchasing over subsequent months. |
| Purchase Behaviour       | Understand how order frequency relates to customer value. |
| Acquisition Analysis     | Evaluate which acquisition channels and campaigns generate the highest-value customers. |
| Business Intelligence    | Deliver an interactive, decision-ready Power BI dashboard for stakeholders. |

---

## 🔄 Project Workflow

```text
Raw Data
   ↓
Data Validation & Cleaning
   ↓
SQL Analysis
   ↓
Customer & RFM Analysis
   ↓
Cohort & Retention Analysis
   ↓
CLV / Customer Value Analysis
   ↓
Acquisition Analysis
   ↓
Power BI Dashboard
   ↓
Business Insights
```

---

## 🔍 SQL Analysis

All core analysis for this project was performed in SQL before being loaded into Power BI for visualization. The SQL work was organized into seven structured areas:

1. **Data Validation** — checking for missing values, duplicate records, and inconsistent order/return statuses across the Customers, Orders, Order_Items, Products, and Returns tables.
2. **Customer Analysis** — customer-level aggregation of orders, revenue, and purchase patterns.
3. **RFM Segmentation** — scoring customers on Recency, Frequency, and Monetary value and grouping them into segments.
4. **Cohort Retention** — grouping customers by signup month and tracking their purchasing activity in the months that followed.
5. **CLV Analysis** — calculating historical customer value based on delivered order value.
6. **Profitability Analysis** — reviewing revenue and cost data at the product/order level to support value-based analysis.
7. **Acquisition Analysis** — evaluating customer value and revenue by acquisition channel and campaign.

Only `order_status = 'Delivered'` orders were treated as valid, completed purchases for the customer value and behavioural analysis.

---

## 👥 Customer Analysis

Customer-level analysis brought together order history, revenue contribution, and acquisition source to build a complete picture of each customer. Key dimensions analyzed include:

* Customer value (historical CLV)
* Order frequency and purchase count per customer
* Revenue contribution per customer
* Acquisition channel and campaign at signup

This customer-level view forms the foundation for both the RFM segmentation and the CLV analysis.

---

## 📊 RFM Segmentation

Customers were scored and grouped using an **RFM (Recency, Frequency, Monetary)** framework, then classified into value-based segments: **High Value, Medium Value, and Low Value**, as well as behavioural RFM segments such as Champions, Loyal Customers, Potential Loyalists, At Risk, and Lost Customers.

Based on the dashboard, the customer base (50K customers total) breaks down across RFM segments as follows:

| RFM Segment          | Customers |
| --------------------- | --------- |
| Potential Loyalists    | 15.0K     |
| Lost Customers         | 12.0K     |
| Loyal Customers        | 11.5K     |
| Champions              | 10.7K     |
| At Risk                | 0.9K      |

While Champions make up only about 21% of the customer base, they contribute disproportionately to revenue (see [Key Insights](#key-insights)).

---

## 📅 Cohort & Retention Analysis

Customers were grouped into cohorts by **signup year**, and their purchasing activity was tracked across the months following signup (month 0 through month 35). The Cohort Retention Analysis matrix shows the share of each cohort still active in each subsequent month.

Overall retention metrics from the dashboard:

* **Customer Retention Rate:** 95.68%
* **Repeat Customer Rate:** 58.78%

Cohort-level patterns:

* The **2023 cohort** shows the most complete lifecycle in the data, with retention rising from 0.10 at month 0 to a peak around 0.23–0.24 near months 23–24, before decaying to 0.02 by month 35.
* The **2024 cohort** peaks earlier (around 0.21–0.24 in months 1–13) and declines to 0.02 by month 23, the latest month tracked for this cohort.
* The **2025 cohort** (the newest, with the shortest tracking window) starts at 0.13 in month 0 and has already declined to 0.02 by month 12, showing a faster early drop-off than the older cohorts at the same point in their lifecycle.

This pattern indicates that while the business retains a strong core of repeat customers overall, individual cohort engagement decays steadily over time and newer cohorts appear to be churning slightly faster in their early months.

---

## 💰 CLV & Customer Value Analysis

The CLV metric in this project represents **historical customer value**, calculated from each customer's total delivered order value — it is **not** a predictive or modeled CLV.

Key figures from the Executive CLV Overview:

* **Total Customers:** 50.00K
* **Total Orders:** 249.72K
* **Total (Historical) CLV:** 2bn
* **Average CLV:** 46.59K
* **Average Orders per Customer:** 4.10

Revenue by customer value segment:

| Value Segment  | Revenue |
| -------------- | ------- |
| High Value     | 1.96bn  |
| Medium Value   | 0.24bn  |
| Low Value      | 0.13bn  |

**High Value customers generate the overwhelming majority of total revenue**, confirming that a relatively small group of customers drives most of the business's historical value. The top 10 customers by CLV each individually contribute between roughly 1.28M and 1.51M.

---

## 📣 Acquisition Analysis

The Acquisition & Customer Value dashboard evaluates which channels and campaigns bring in the most valuable customers, across **8 acquisition channels**.

CLV by acquisition channel (total):

| Channel          | Total CLV |
| ---------------- | --------- |
| Organic Search    | 0.60bn    |
| Direct            | 0.41bn    |
| Referral          | 0.33bn    |
| Paid Search       | 0.28bn    |
| Email Marketing   | 0.24bn    |
| Social Media Ads  | 0.20bn    |
| Affiliate         | 0.16bn    |
| Marketplace Ads   | 0.11bn    |

Average CLV by acquisition channel tells a different story than total CLV:

| Channel          | Avg CLV |
| ---------------- | ------- |
| Referral          | 95K     |
| Direct            | 69K     |
| Organic Search    | 63K     |
| Email Marketing   | 59K     |
| Paid Search       | 39K     |
| Affiliate         | 32K     |
| Marketplace Ads   | 24K     |
| Social Media Ads  | 20K     |

Revenue by acquisition campaign shows the top campaigns are **Organic-Brand** (0.25bn), **Organic-YouTube-Reviews** (0.24bn), and **Organic-Blog-SEO** (0.23bn), followed closely by **Referral-FriendInvite** and **Referral-CashbackProgram** (0.20bn each).

CLV by purchase frequency shows a clear relationship between order count and value: customers with **10+ orders** account for **1.39bn** in CLV — far ahead of the **0.47bn** generated by customers with 6–10 orders.

---

## 📊 Business KPIs

| KPI                        | Value    |
| -------------------------- | -------- |
| Total Customers             | 50.00K   |
| Total Orders                 | 249.72K  |
| Total Historical CLV         | 2bn      |
| Average CLV                  | 46.59K   |
| Average Orders per Customer  | 4.10     |
| Customer Retention Rate      | 95.68%   |
| Repeat Customer Rate         | 58.78%   |
| Number of Acquisition Channels | 8      |

---

## 📈 Power BI Dashboard

The project includes **3 interactive Power BI dashboard pages**:

### Page 1 — Executive CLV Overview

Gives leadership a high-level view of total customers, total orders, total and average CLV, and average orders per customer. It breaks down revenue by customer value segment (High/Medium/Low), shows the customer distribution and revenue contribution across RFM segments, and ranks the top 10 customers by CLV — making it immediately clear which customer segments and individuals matter most to the business.

### Page 2 — Retention & Customer Behaviour

Focuses on how well the business retains and re-engages customers. It surfaces the overall customer retention rate and repeat customer rate, a month-by-month cohort retention matrix by signup year, the distribution of customers across RFM segments, and how customers are distributed by number of orders placed — helping management see where retention efforts are working and where they are falling off.

### Page 3 — Acquisition & Customer Value

Connects acquisition spend to customer value outcomes. It shows total customers and average CLV alongside the number of acquisition channels in use, then breaks down total and average CLV by channel, customer distribution by channel, revenue by acquisition campaign, and CLV by purchase frequency — giving marketing teams a basis for reallocating budget toward channels and campaigns that bring in genuinely valuable customers rather than just high volume.

---

## 💡 Key Insights

1. **A small segment drives almost all revenue.** High Value customers generate 1.96bn of the 2bn total historical CLV, while Medium and Low Value customers together contribute only about 0.37bn — confirming that customer value is heavily concentrated at the top of the base.

2. **Champions are the real revenue engine, not just the largest segment.** Champions make up only 10.7K of 50K customers (about 21%), yet they contribute 2.26bn in revenue contribution by RFM segment — far more than Loyal Customers (0.42bn) or Potential Loyalists (0.12bn), showing that retaining this relatively small group should be a top priority.

3. **Retention is strong overall, but decays cohort by cohort.** With a 95.68% customer retention rate and 58.78% repeat customer rate, the business has a solid loyal base — but the cohort retention matrix shows every cohort (2023, 2024, 2025) declining from its peak down to roughly 0.02 by the end of its tracked lifecycle, meaning long-term re-engagement is where the business is losing the most ground.

4. **Newer cohorts show faster early drop-off.** The 2025 cohort falls from 0.13 at month 0 to 0.02 by month 12, a faster decline than the 2023 and 2024 cohorts experienced over a comparable early window — a signal worth investigating in onboarding or early lifecycle marketing.

5. **Purchase frequency is strongly tied to customer value.** Customers with 10+ orders account for 1.39bn in CLV — nearly three times the 0.47bn generated by the 6–10 order group — reinforcing that driving repeat purchases is one of the clearest levers for increasing customer value.

6. **Referral is the highest-quality acquisition channel, not the largest.** Referral produces the highest average CLV per customer at 95K, well above Direct (69K) and Organic Search (63K), even though Organic Search leads in total CLV (0.60bn) simply by volume — meaning Referral customers are individually far more valuable.

7. **Social Media Ads bring in volume, not value.** Social Media Ads account for one of the largest shares of acquired customers but produce the lowest average CLV of any channel at just 20K, well below every other acquisition source — indicating a real opportunity to reallocate acquisition spend toward higher-yielding channels like Referral and Organic Search.

8. **Organic campaigns outperform paid campaigns on revenue.** The top three campaigns by revenue — Organic-Brand (0.25bn), Organic-YouTube-Reviews (0.24bn), and Organic-Blog-SEO (0.23bn) — are all organic, ahead of paid search campaigns such as Bing-Search-Ads and GoogleAds-Generic-Search (0.09bn each), suggesting organic content and brand search are currently the strongest drivers of acquisition revenue.

---

## 🛠️ Tech Stack

| Tool     | Purpose                                  |
| -------- | ----------------------------------------- |
| MySQL    | Data querying and analysis                |
| SQL      | Data validation and business analysis     |
| Power BI | Interactive dashboard and reporting       |
| DAX      | KPI calculations and analytical measures  |

---

## 📁 Project Structure

```text
shop-sphere-clv-analytics/
│
├── SQL/
│   ├── 01_Data_Validation.sql
│   ├── 02_Customer_Analysis.sql
│   ├── 03_RFM_Segmentation.sql
│   ├── 04_Cohort_Retention.sql
│   ├── 05_CLV_Analysis.sql
│   ├── 06_Profitability.sql
│   └── 07_Acquisition_Analysis.sql
│
├── PowerBI/
│   └── Shop_Sphere_CLV_Analytics.pbix
│
├── Screenshots/
│   ├── page_1_executive_overview.png
│   ├── page_2_retention_behaviour.png
│   └── page_3_acquisition_customer_value.png
│
└── README.md
```

---

## ▶️ How to Run

1. Clone this repository to your local machine.
2. Open the SQL scripts in the `SQL/` folder — they are numbered in the order they should be run (01 through 07).
3. Load the source tables (Customers, Orders, Order_Items, Products, Returns) into MySQL.
4. Run the SQL scripts in order to reproduce the validation, customer, RFM, cohort, CLV, profitability, and acquisition analysis.
5. Open `Shop_Sphere_CLV_Analytics.pbix` in Power BI Desktop.
6. Update the data source connection to point to your local MySQL database, then refresh the report to load the latest data.

---

## 🖼️ Dashboard Preview

| Page                           | Preview                                                                            |
| ------------------------------- | ----------------------------------------------------------------------------------- |
| Executive CLV Overview          | ![Executive Overview](https://github.com/Ankar-G/Shop-Sphere-CLV-Cohort-Analytics/blob/main/ScreenShots/Screenshot%202026-09-05%20123609.png)                    |
| Retention & Customer Behaviour  | ![Retention & Behaviour](Screenshots/page_2_retention_behaviour.png)                |
| Acquisition & Customer Value    | ![Acquisition & Customer Value](Screenshots/page_3_acquisition_customer_value.png)  |

---

* **LinkedIn:** [Add your LinkedIn URL here]
* **Email:** [Add your email here]

---

> ⭐ If you found this project useful, please give it a star — it helps others discover it!
