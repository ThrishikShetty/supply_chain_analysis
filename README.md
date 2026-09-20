# Supply Chain Analytics

## 📌 Project Overview

The goal of this project is to build an end-to-end supply chain analytics workflow that transforms raw transactional data into decision-ready business insights by:

- ✅ **Data Preparation & Feature Engineering (Python):** Clean, validate and transform the raw supply chain dataset.
- ✅ **Business Analysis (PostgreSQL / SQL):** Store the cleaned data and answer business questions related to revenue, profitability, delivery performance, products, regions, discounts and customers.
- ✅ **Dashboard & Visualization (Excel):** Build KPI summaries, PivotTables and charts for management reporting.
- ✅ **Report & Presentation:** Convert the analysis into business insights and actionable areas for investigation.

**Workflow:**

`Raw Data → Python/Pandas → Data Cleaning & Feature Engineering → PostgreSQL → SQL Business Analysis → Excel Dashboard → Business Insights`

------------------------------------------------------------------------

# 1. Project Overview

This project analyzes the **DataCo Smart Supply Chain Dataset**, containing **180,519 transaction records**. The objective is to understand revenue generation, profitability, delivery performance, regional performance, shipping modes, discounting, product contribution and customer-segment behavior.

The project uses three tools with distinct responsibilities:

**Python → Data Preparation → PostgreSQL/SQL → Business Analysis → Excel → Dashboard & Reporting**

The analysis is designed to convert raw supply chain transactions into structured business insights that can support operational, pricing, product and regional decisions.

------------------------------------------------------------------------

# 2. Problem Statement

The business wants to understand how its supply chain is performing across sales, profitability and delivery operations.

The key questions addressed in this project include:

- What is the overall revenue, profit and profit margin?
- How much delivery risk exists in the dataset?
- Which product categories generate the most revenue and profit?
- Which regions contribute the most revenue and profit?
- How do shipping modes differ in shipping time and delivery risk?
- How does discounting relate to profit margin?
- How has revenue changed over time?
- Which individual products are major revenue contributors?
- Which regions have higher late-delivery risk?
- Which customer segments generate the most business value?
- How can these findings support operational and commercial decisions?

------------------------------------------------------------------------

# 3. Dataset Summary

## Dataset Size

| Attribute                     |               Value |
|:------------------------------|--------------------:|
| Original Rows                 |             180,519 |
| Original Columns              |                  53 |
| Removed Columns               |                   8 |
| Cleaned Columns               |                  45 |
| Engineered Columns            |                   9 |
| Final Columns                 |                  54 |
| Duplicate Rows                |                   0 |
| Missing Values After Cleaning |                   3 |
| Date Coverage                 | 2015 – January 2018 |

The dataset contains order, product, customer, sales, profit, shipping and delivery information.

### Removed Fields

The following fields were removed because they were not required for business analysis:

- `customer_email`
- `customer_password`
- `customer_fname`
- `customer_lname`
- `customer_street`
- `product_image`
- `product_description`
- `order_zipcode`

The removal also avoids retaining unnecessary private/customer-identifying information in the analytical dataset.

------------------------------------------------------------------------

# 4. Data Structure

The dataset contains information across several business areas.

## Order & Delivery Information

- `order_id`
- `order_date_dateorders`
- `shipping_date_dateorders`
- `order_status`
- `delivery_status`
- `late_delivery_risk`
- `days_for_shipping_real`
- `days_for_shipment_scheduled`
- `shipping_mode`

## Product Information

- `product_name`
- `product_price`
- `product_status`
- `category_name`
- `category_id`
- `product_category_id`
- `product_card_id`
- `order_item_cardprod_id`

## Customer Information

- `customer_id`
- `customer_city`
- `customer_country`
- `customer_state`
- `customer_zipcode`
- `customer_segment`
- `order_customer_id`

## Sales & Profitability

- `sales`
- `sales_per_customer`
- `order_item_quantity`
- `order_item_product_price`
- `order_item_discount`
- `order_item_discount_rate`
- `order_item_profit_ratio`
- `order_profit_per_order`
- `benefit_per_order`

## Geography

- `market`
- `order_city`
- `order_country`
- `order_region`
- `order_state`
- `latitude`
- `longitude`

## Engineered Features

- `shipping_delay`
- `order_year`
- `order_month`
- `order_month_name`
- `order_quarter`
- `order_month_year`
- `profit_margin`
- `delivery_flag`
- `discount_band`

------------------------------------------------------------------------

# 5. Data Exploration Using Python

Python and Pandas were used for initial inspection, cleaning and feature engineering.

The initial dataset contained:

- **180,519 rows**
- **53 columns**

The data was inspected for:

- Missing values
- Duplicate records
- Data types
- Numerical ranges
- Categorical consistency
- Date fields
- Potential outliers and invalid values

The cleaned dataset was then prepared for PostgreSQL and Excel analysis.

------------------------------------------------------------------------

# 6. Data Cleaning

## 6.1 Removing Irrelevant Fields

Eight fields were removed because they were not required for the analytical objectives.

This reduced the dataset from:

**53 columns → 45 columns**

while keeping all 180,519 records.

------------------------------------------------------------------------

## 6.2 Column Standardization

Column names were converted into lowercase `snake_case`.

Examples:

- `Days for shipping (real)` → `days_for_shipping_real`
- `Category Name` → `category_name`
- `Order Date (DateOrders)` → `order_date_dateorders`
- `Order Profit Per Order` → `order_profit_per_order`
- `Shipping Mode` → `shipping_mode`

Standardized column names make the dataset easier to use across Python, PostgreSQL and Excel.

------------------------------------------------------------------------

## 6.3 Date Conversion

The following columns were converted to datetime:

- `order_date_dateorders`
- `shipping_date_dateorders`

This enabled time-based analysis such as:

- Yearly revenue
- Monthly revenue
- Quarterly analysis
- Monthly trend analysis

------------------------------------------------------------------------

## 6.4 Missing Value Check

After cleaning, only **3 missing values** remained, all in:

`customer_zipcode`

These were retained because zipcode was not required for the core business analysis.

------------------------------------------------------------------------

## 6.5 Duplicate Check

The dataset contained:

**0 duplicate rows**

Therefore, no duplicate records were removed.

------------------------------------------------------------------------

## 6.6 Data Consistency Checks

Additional checks were performed on:

- `late_delivery_risk`
- `order_item_quantity`
- `order_item_discount_rate`
- Discount amounts
- Negative profit values
- Categorical whitespace

The checks confirmed that the observed ranges were consistent with the dataset and that negative profit values were retained because they can represent legitimate loss-making transactions.

------------------------------------------------------------------------

# 7. Feature Engineering

Feature engineering was performed to create variables that support business-focused analysis.

## 7.1 Shipping Delay

A new field was created:

``` python
df["shipping_delay"] = (
    df["days_for_shipping_real"]
    - df["days_for_shipment_scheduled"]
)
```

This measures the difference between actual and scheduled shipping time.

Interpretation:

- `0` → actual shipping time matched the scheduled time
- Positive value → actual shipping took longer than scheduled
- Negative value → actual shipping was faster than scheduled

------------------------------------------------------------------------

## 7.2 Order Date Features

The following time features were created:

- `order_year`
- `order_month`
- `order_month_name`
- `order_quarter`
- `order_month_year`

These fields support annual, monthly and quarterly trend analysis.

------------------------------------------------------------------------

## 7.3 Profit Margin

A transaction-level profit margin field was created:

``` python
df["profit_margin"] = np.where(
    df["sales"] != 0,
    (df["order_profit_per_order"] / df["sales"]) * 100,
    0
)
```

This provides a percentage-based view of profitability.

------------------------------------------------------------------------

## 7.4 Delivery Flag

A simple delivery classification was created:

``` python
df["delivery_flag"] = np.where(
    df["late_delivery_risk"] == 1,
    "Late",
    "On Time"
)
```

This makes delivery-risk analysis easier in Excel and SQL.

------------------------------------------------------------------------

## 7.5 Discount Band

Discount rates were grouped into business-friendly bands:

| Discount Band |  Range |
|:--------------|-------:|
| No Discount   |     0% |
| Low           |   1–5% |
| Medium        |  6–10% |
| High          | 11–20% |
| Very High     | 21–25% |

This feature supports comparison of discounting and profitability.

------------------------------------------------------------------------

# 8. PostgreSQL Database Integration

After cleaning and feature engineering, the final dataset was loaded into PostgreSQL.

### Database Details

- **Database:** `supply_chain_db`
- **Table:** `supply_chain`
- **Database:** PostgreSQL
- **Client:** pgAdmin / PostgreSQL
- **Records loaded:** 180,519

The cleaned UTF-8 CSV was imported into the PostgreSQL table and validated using SQL.

Example validation:

``` sql
SELECT COUNT(*)
FROM supply_chain;
```

Result:

``` text
180519
```

------------------------------------------------------------------------

# 9. Overall Business Performance

## Business Question

**What is the overall performance of the supply chain business?**

### SQL Result

| KPI                 |          Result |
|:--------------------|----------------:|
| Total Orders        |          65,752 |
| Total Revenue       | \$36,784,735.01 |
| Total Profit        |  \$3,966,902.97 |
| Total Units Sold    |         384,079 |
| Average Order Value |        \$559.45 |
| Profit Margin       |          10.78% |

### Insight

The dataset contains **65,752 distinct orders** generating approximately **\$36.78M in revenue** and **\$3.97M in profit**.

The overall profit margin is **10.78%**, while the average order value is approximately **\$559.45**.

------------------------------------------------------------------------

# 10. Delivery Performance

## Business Question

**What is the overall delivery risk and shipping performance?**

### SQL Result

| Metric                          |    Result |
|:--------------------------------|----------:|
| Total Orders                    |    65,752 |
| Late-Risk Orders                |    98,977 |
| Late-Delivery Risk Rate         |    54.83% |
| Average Actual Shipping Time    | 3.50 days |
| Average Scheduled Shipping Time | 2.93 days |
| Average Shipping Delay          | 0.57 days |

### Insight

The dataset shows a **54.83% late-delivery-risk rate**.

Average actual shipping time is **3.50 days**, compared with **2.93 scheduled days**, resulting in an average calculated shipping delay of approximately **0.57 days**.

The late-delivery-risk field is a dataset-defined indicator and should not be interpreted as proof of causation.

------------------------------------------------------------------------

# 11. Category Performance

## Business Question

**Which product categories generate the most revenue and profit?**

### Top Categories

| Category             | Revenue |    Profit | Margin |
|:---------------------|--------:|----------:|-------:|
| Fishing              | \$6.93M | \$756.22K | 10.91% |
| Cleats               | \$4.43M | \$494.64K | 11.16% |
| Camping & Hiking     | \$4.12M | \$427.46K | 10.38% |
| Cardio Equipment     | \$3.69M | \$383.01K | 10.37% |
| Women’s Apparel      | \$3.15M | \$350.42K | 11.13% |
| Water Sports         | \$3.11M | \$325.15K | 10.44% |
| Men’s Footwear       | \$2.89M | \$311.90K | 10.79% |
| Indoor/Outdoor Games | \$2.89M | \$318.45K | 11.02% |
| Shop By Sport        | \$1.31M | \$129.81K |  9.91% |
| Computers            |  \$663K |  \$69.66K | 10.51% |

### Insight

**Fishing** is the largest category in the analysis, generating **\$6.93M revenue and \$756K profit**.

Cleats is the next major contributor with **\$4.43M revenue and \$495K profit**.

The leading categories contribute substantially to both sales and absolute profit.

------------------------------------------------------------------------

# 12. Regional Performance

## Business Question

**Which regions generate the most revenue and profit?**

### Results

| Region          | Orders | Revenue |    Profit | Margin |
|:----------------|-------:|--------:|----------:|-------:|
| Western Europe  | 10,010 | \$5.89M | \$625.45K | 10.61% |
| Central America |  9,396 | \$5.67M | \$616.34K | 10.88% |
| South America   |  4,979 | \$2.96M | \$335.15K | 11.32% |
| Northern Europe |  3,716 | \$2.16M | \$233.45K | 10.83% |
| Southern Europe |  3,543 | \$2.05M | \$230.83K | 11.27% |

### Insight

Western Europe and Central America are the largest regional contributors, generating **\$5.89M** and **\$5.67M** in revenue respectively.

South America generated **\$2.96M revenue** with an **11.32% profit margin**.

Average shipping delays across the major regions were relatively close, generally around 0.52–0.60 days.

------------------------------------------------------------------------

# 13. Shipping Mode Performance

## Business Question

**How do shipping modes differ in shipping time, delay and late-delivery risk?**

### Results

| Shipping Mode  | Orders |  Revenue |    Profit | Avg. Shipping | Avg. Delay | Late Risk |
|:---------------|-------:|---------:|----------:|--------------:|------------|----------:|
| Standard Class | 39,324 | \$22.02M |   \$2.37M |     4.00 days | 0.00 days  |    38.07% |
| Second Class   | 12,778 |  \$7.15M | \$750.31K |     3.99 days | 1.99 days  |    76.63% |
| First Class    | 10,079 |  \$5.67M | \$643.12K |     2.00 days | 1.00 day   |    95.32% |
| Same Day       |  3,571 |  \$1.94M | \$203.02K |     0.48 days | 0.48 days  |    45.74% |

### Insight

Standard Class has the largest volume, with **39,324 orders and \$22.02M revenue**.

Same Day has the shortest average shipping time at **0.48 days**.

First Class shows a **95.32% dataset-defined late-delivery-risk rate**, while Standard Class shows 38.07%.

These results describe differences in the dataset; they do not establish that a particular shipping mode causes late deliveries.

------------------------------------------------------------------------

# 14. Discount Impact

## Business Question

**How does discount level relate to revenue and profit margin?**

### Results

| Discount Band      | Orders |  Revenue |    Profit | Margin |
|:-------------------|-------:|---------:|----------:|-------:|
| No Discount        |  9,400 |  \$2.04M | \$267.41K | 13.09% |
| Low (1–5%)         | 29,741 |  \$8.17M | \$933.21K | 11.42% |
| Medium (6–10%)     | 29,592 |  \$8.17M | \$943.06K | 11.54% |
| High (11–20%)      | 43,309 | \$14.31M |   \$1.45M | 10.16% |
| Very High (21–25%) | 17,152 |  \$4.09M | \$369.21K |  9.03% |

### Insight

High-discount transactions generated the highest revenue and absolute profit, but the profit margin was lower than the no-discount group.

The **Very High discount band had the lowest margin at 9.03%**, compared with **13.09% without discounts**.

The data therefore shows an association between deeper discounting and lower profit margins.

------------------------------------------------------------------------

# 15. Revenue Trend

## Business Question

**How has revenue changed over time?**

### Annual Results

| Year   |  Revenue |   Profit | Orders |
|:-------|---------:|---------:|-------:|
| 2015   | \$12.41M |  \$1.32M | 20,904 |
| 2016   | \$12.31M |  \$1.31M | 20,859 |
| 2017   | \$11.81M |  \$1.30M | 21,866 |
| 2018\* |  \$0.33M | \$33.84K |  2,123 |

`* 2018 contains only January.`

### Insight

Revenue remained relatively stable between **2015 and 2017**, moving from \$12.41M to \$11.81M.

Order volume also remained around 21K orders per full year.

The 2018 result should not be interpreted as an annual decline because the available data covers only **January 2018**.

------------------------------------------------------------------------

# 16. Product Performance

## Business Question

**Which individual products are major revenue contributors?**

### Top Products

| Product                                     | Orders | Revenue |    Profit |
|:--------------------------------------------|-------:|--------:|----------:|
| Field & Stream Sportsman 16 Gun Fire Safe   | 15,164 | \$6.93M | \$756.22K |
| Perfect Fitness Perfect Rip Deck            | 20,359 | \$4.24M | \$498.24K |
| Diamondback Women’s Serene Classic Comfort… | 12,299 | \$4.12M | \$427.46K |
| Nike Men’s Free 5.0+ Running Shoe           | 11,092 | \$3.67M | \$379.92K |
| Nike Men’s Dri-FIT Victory Golf Polo        | 17,869 | \$3.15M | \$350.42K |
| Pelican Sunstream 100 Kayak                 | 13,727 | \$3.10M | \$324.08K |
| Nike Men’s CJ Elite 2 TD Football Cleat     | 18,783 | \$2.89M | \$311.90K |
| O’Brien Men’s Neoprene Life Vest            | 16,623 | \$2.89M | \$318.45K |
| Under Armour Girls’ Toddler Spine Surge…    |  9,825 | \$1.27M | \$126.28K |
| Dell Laptop                                 |    442 |  \$663K |  \$69.66K |

### Insight

The **Field & Stream Sportsman 16 Gun Fire Safe** generated the highest revenue and profit among the displayed products.

The **Perfect Fitness Perfect Rip Deck** recorded the highest order count among the displayed products, with 20,359 orders.

------------------------------------------------------------------------

# 17. Regional Delivery Risk

## Business Question

**Where is late-delivery risk highest?**

### Results

| Region         | Orders | Late Risk | Avg. Delay |
|:---------------|-------:|----------:|-----------:|
| Central Africa |    556 |    57.96% |  0.64 days |
| South Asia     |  3,335 |    56.27% |  0.60 days |
| East Africa    |    613 |    55.94% |  0.57 days |
| Western Europe | 10,010 |    55.85% |  0.60 days |
| South of USA   |  1,345 |    55.77% |  0.58 days |
| East of USA    |  2,323 |    55.66% |  0.58 days |
| Eastern Europe |  1,292 |    55.66% |  0.58 days |
| Southeast Asia |  4,356 |    55.53% |  0.56 days |
| West Asia      |  2,022 |    55.28% |  0.57 days |
| US Center      |  1,935 |    55.24% |  0.59 days |

### Insight

Central Africa records the highest late-delivery-risk rate among the displayed regions at **57.96%**, but it has only 556 orders.

South Asia and Western Europe combine relatively high risk rates with larger order volumes, making them useful areas for further operational investigation.

------------------------------------------------------------------------

# 18. Customer Segment Performance

## Business Question

**Which customer segments generate the most business value?**

### Results

| Customer Segment | Orders |  Revenue |    Profit | Average Order Value |
|:-----------------|-------:|---------:|----------:|--------------------:|
| Consumer         | 34,119 | \$19.06M |   \$2.07M |            \$559.68 |
| Corporate        | 19,856 | \$11.17M |   \$1.20M |            \$562.47 |
| Home Office      | 11,777 |  \$6.52M | \$690.84K |            \$553.67 |

### Insight

Consumer customers represent the largest segment, generating **\$19.06M revenue and \$2.07M profit**.

Corporate customers have the highest average order value at **\$562.47**.

The differences between customer segments are driven more by order volume than by average order value.

------------------------------------------------------------------------

# 19. Excel Dashboard

The cleaned and analyzed data was presented through an Excel dashboard.

The dashboard contains KPI cards and analytical charts covering:

- Total Orders
- Total Revenue
- Total Profit
- Profit Margin
- Late-Delivery Risk
- Top 10 Categories by Revenue
- Revenue by Region
- Late-Delivery Risk by Shipping Mode
- Monthly Revenue Trend
- Profit Margin by Discount Band

### Dashboard KPIs

| KPI                 |    Value |
|:--------------------|---------:|
| Total Orders        |   65,752 |
| Total Revenue       | \$36.78M |
| Total Profit        |  \$3.97M |
| Total Units Sold    |  384,079 |
| Average Order Value | \$559.45 |
| Profit Margin       |   10.78% |
| Late-Delivery Risk  |   54.83% |

The dashboard is designed as a management-level summary while the PostgreSQL queries provide the detailed analytical layer.

------------------------------------------------------------------------

# 20. Key Business Insights

## 1. Strong Contribution from Major Categories

Fishing is the largest category by revenue and profit, followed by Cleats and Camping & Hiking.

## 2. Regional Revenue Concentration

Western Europe and Central America are the largest regional contributors by revenue and absolute profit.

## 3. Delivery Risk Requires Investigation

The overall late-delivery-risk rate is **54.83%**, with substantial differences across shipping modes.

## 4. Deeper Discounts Are Associated with Lower Margins

The Very High discount band has a **9.03% margin**, compared with **13.09% for no discount**.

## 5. Standard Class Drives the Largest Volume

Standard Class accounts for the highest order volume and revenue in the dataset.

## 6. Consumer Customers Drive the Largest Revenue

Consumer customers generate the largest revenue and profit because of their larger order volume.

## 7. 2018 Must Be Interpreted Carefully

Only January 2018 is available, so it should not be compared with complete years.

------------------------------------------------------------------------

# 21. Business Recommendations

## 1. Review Discount Strategy

Evaluate whether high and very-high discount levels generate enough incremental sales to justify their lower margins.

## 2. Investigate Delivery Risk

Review shipping processes, regional operations and scheduling assumptions for areas and shipping modes with higher late-delivery-risk rates.

## 3. Protect High-Value Categories

Monitor inventory, pricing and fulfillment for major revenue contributors such as Fishing and Cleats.

## 4. Monitor High-Volume Regions

Western Europe and Central America contribute substantial revenue and profit and can be included in regular operational monitoring.

## 5. Track Shipping Mode Performance

Compare actual shipping time, scheduled time and late-risk indicators regularly by shipping mode.

## 6. Use Complete Time Periods for Trend Decisions

Use monthly and full-year periods consistently and avoid treating partial 2018 data as a complete annual result.

------------------------------------------------------------------------

# 22. Technology Stack

| Technology     | Purpose                                             |
|:---------------|:----------------------------------------------------|
| **Python**     | Data cleaning, validation and feature engineering   |
| **Pandas**     | Data transformation and preprocessing               |
| **NumPy**      | Numerical calculations                              |
| **PostgreSQL** | Data storage and structured analysis                |
| **pgAdmin**    | PostgreSQL database management and SQL execution    |
| **SQL**        | Business analysis, aggregation and KPI calculations |
| **Excel**      | PivotTables, charts, KPI summary and dashboard      |

------------------------------------------------------------------------

# 23. End-to-End Project Workflow

``` text
Raw Data
    ↓
Python / Pandas
    ↓
Data Exploration
    ↓
Remove Irrelevant Fields
    ↓
Missing Value & Duplicate Checks
    ↓
Column Standardization
    ↓
Date Conversion
    ↓
Feature Engineering
    ↓
Clean UTF-8 CSV
    ↓
PostgreSQL
    ↓
SQL Business Analysis
    ↓
Business Questions & Insights
    ↓
Excel PivotTables
    ↓
Excel Charts & KPI Dashboard
    ↓
Business Recommendations
    ↓
Report & Presentation
```

------------------------------------------------------------------------

# 24. Project Outcome

This project demonstrates a complete **supply chain analytics workflow** from raw transactional data to business-ready insights.

The project combines:

- **Python** for data preparation and feature engineering
- **PostgreSQL / SQL** for structured business analysis
- **Excel** for dashboard development and visualization
- **Business analysis** for translating analytical results into practical areas for investigation

The final analysis provides a consolidated view of:

- Revenue
- Profit
- Profit Margin
- Product and category performance
- Regional performance
- Shipping mode performance
- Delivery risk
- Discount impact
- Customer segment contribution
- Revenue trends

------------------------------------------------------------------------

# 25. Important Metrics at a Glance

| Metric                        |          Result |
|:------------------------------|----------------:|
| Total Records                 |         180,519 |
| Final Columns                 |              54 |
| Duplicate Rows                |               0 |
| Remaining Missing Values      |               3 |
| Total Orders                  |          65,752 |
| Total Revenue                 | \$36,784,735.01 |
| Total Profit                  |  \$3,966,902.97 |
| Total Units Sold              |         384,079 |
| Average Order Value           |        \$559.45 |
| Overall Profit Margin         |          10.78% |
| Late-Delivery Risk            |          54.83% |
| Avg. Actual Shipping Time     |       3.50 days |
| Avg. Scheduled Shipping Time  |       2.93 days |
| Avg. Shipping Delay           |       0.57 days |
| Highest Revenue Category      |         Fishing |
| Fishing Revenue               |         \$6.93M |
| Highest Revenue Region        |  Western Europe |
| Western Europe Revenue        |         \$5.89M |
| Highest Revenue Shipping Mode |  Standard Class |
| Standard Class Revenue        |        \$22.02M |
| Lowest Discount-Band Margin   |           9.03% |
| Highest Discount-Band Margin  |          13.09% |
| Largest Customer Segment      |        Consumer |
| Consumer Revenue              |        \$19.06M |

------------------------------------------------------------------------

# 26. Conclusion

The Supply Chain Analytics project identifies clear patterns across revenue, profitability, product categories, regions, shipping modes, discounting and customer segments.

The analysis shows that major categories and regions contribute a large share of business value, while delivery-risk indicators vary considerably across shipping modes and regions. Discount analysis also shows an association between deeper discounts and lower profit margins.

The combination of **Python, PostgreSQL/SQL and Excel** provides an end-to-end framework for transforming raw supply-chain transactions into structured business analysis, dashboard reporting and actionable areas for further investigation.
