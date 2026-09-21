

````markdown
# Python – Data Cleaning & Feature Engineering

This folder contains the Python code used to clean, validate, and prepare the **DataCo Smart Supply Chain Dataset** before performing SQL analysis and building the Excel dashboard.

Python was mainly used for **data preparation and validation**. The main business analysis was later performed using PostgreSQL/SQL.

---

## 1. Why Python Was Used

The original dataset contained:

- 180,519 records
- 53 columns
- Different column naming formats
- Date columns stored as text
- Customer-related/private columns that were not required
- Some missing values
- Categorical values that required cleaning

Python with **Pandas and NumPy** was used to prepare the dataset before loading it into PostgreSQL.

### Python's role in this project

```text
Raw CSV
   ↓
Load Dataset
   ↓
Remove Unnecessary Columns
   ↓
Clean Column Names
   ↓
Handle Data Types
   ↓
Check Missing Values
   ↓
Check Duplicates
   ↓
Validate Data
   ↓
Create Features
   ↓
Clean Dataset
   ↓
PostgreSQL
````

---

# 2. Libraries Used

```python
import pandas as pd
import numpy as np
```

### Pandas

Pandas was used for:

* Reading the CSV file
* Data cleaning
* Data transformation
* Missing-value analysis
* Duplicate checking
* Feature creation
* Data validation

### NumPy

NumPy was mainly used for:

* Conditional calculations
* Numerical operations
* Creating calculated features

---

# 3. Loading the Dataset

```python
df = pd.read_csv(
    "../Dataset/DataCoSupplyChainDataset.csv",
    encoding="latin1"
)
```

### Why did we use `latin1`?

The dataset contains special characters that can sometimes cause encoding errors when using the default UTF-8 encoding.

Using:

```python
encoding="latin1"
```

allows Pandas to successfully read the dataset.

### Initial Dataset

The original dataset contained:

```text
Rows    : 180,519
Columns : 53
```

---

# 4. Removing Unnecessary Columns

The following columns were removed:

```python
columns_to_drop = [
    "Customer Email",
    "Customer Password",
    "Customer Fname",
    "Customer Lname",
    "Customer Street",
    "Product Image",
    "Product Description",
    "Order Zipcode"
]

df = df.drop(columns=columns_to_drop)
```

### Why did we remove them?

These columns were not required for the supply chain business analysis.

For example:

* Customer Email → personal information
* Customer Password → sensitive information
* Customer Fname / Lname → not required for KPI analysis
* Customer Street → not required
* Product Image → not required for SQL analysis
* Product Description → not required for KPI analysis
* Order Zipcode → not required for the dashboard

Removing unnecessary columns makes the dataset:

* Smaller
* Easier to work with
* More privacy-conscious
* More focused on business analysis

After removing these columns:

```text
Rows    : 180,519
Columns : 45
```

---

# 5. Standardizing Column Names

The original dataset used column names containing spaces and mixed capitalization.

For example:

```text
Customer ID
Purchase Amount
Order Date
```

These were converted into a consistent format such as:

```text
customer_id
purchase_amount
order_date
```

The final naming convention used:

```text
lowercase + underscores
```

### Why?

This makes the columns easier to use in:

* Python
* PostgreSQL
* SQL queries
* Power BI
* Excel

For example:

```python
df.columns = (
    df.columns
      .str.strip()
      .str.lower()
      .str.replace(" ", "_")
)
```

This creates consistent column names such as:

```text
order_id
order_date_dateorders
sales
order_profit_per_order
shipping_mode
delivery_status
```

---

# 6. Converting Date Columns

The order and shipping date columns were converted into proper datetime format.

```python
df["order_date_dateorders"] = pd.to_datetime(
    df["order_date_dateorders"]
)

df["shipping_date_dateorders"] = pd.to_datetime(
    df["shipping_date_dateorders"]
)
```

### Why?

Date columns are required for time-based analysis.

After conversion, we can calculate:

* Year
* Month
* Quarter
* Monthly revenue
* Yearly trends
* Shipping duration

For example:

```text
2017-05-15 00:00:00
```

can be used to extract:

```text
Year    → 2017
Month   → 5
Quarter → Q2
```

---

# 7. Checking Missing Values

We checked missing values using:

```python
df.isnull().sum()
```

The final dataset contained only:

```text
customer_zipcode → 3 missing values
```

The missing zipcode values were left unchanged because zipcode was not required for the analysis.

### Why check missing values?

Missing values can cause problems during:

* Calculations
* SQL analysis
* Visualization
* Statistical analysis

Therefore, missing values were identified before loading the data into PostgreSQL.

---

# 8. Checking Duplicate Records

Duplicates were checked using:

```python
df.duplicated().sum()
```

Result:

```text
0 duplicate rows
```

### Why?

Duplicate records could incorrectly increase:

* Revenue
* Profit
* Order quantities
* Order counts

Since there were no duplicate rows, no records needed to be removed.

---

# 9. Validating Numerical Columns

Important numerical columns were checked to make sure their values were reasonable.

Examples included:

```text
late_delivery_risk
order_item_quantity
order_item_discount_rate
order_item_discount
```

For example:

```python
df["late_delivery_risk"].unique()
```

was used to verify that the column contained valid binary values:

```text
0
1
```

Similarly, quantity and discount values were inspected for unexpected values.

### Why?

Validation helps identify data-quality problems before performing business analysis.

---

# 10. Cleaning Categorical Columns

Categorical columns such as:

```text
category_name
department_name
order_region
```

were checked for unwanted spaces.

Whitespace can create duplicate-looking categories.

For example:

```text
Fishing
Fishing 
```

would technically be treated as two different values.

Therefore, categorical text values were cleaned before analysis.

### Why?

This ensures that SQL `GROUP BY` operations produce accurate results.

---

# 11. Creating Shipping Delay

One of the most important features created was:

```python
df["shipping_delay"] = (
    df["days_for_shipping_real"]
    - df["days_for_shipment_scheduled"]
)
```

### Formula

```text
Shipping Delay =
Actual Shipping Days - Scheduled Shipping Days
```

Example:

```text
Actual Shipping Days      = 5
Scheduled Shipping Days   = 3

Shipping Delay = 5 - 3
               = 2 days
```

### Why?

This feature helps measure how far actual delivery performance differs from the planned schedule.

It is useful for:

* Delivery analysis
* Shipping performance
* Identifying delays
* Business recommendations

---

# 12. Creating Year

```python
df["order_year"] = (
    df["order_date_dateorders"].dt.year
)
```

### Why?

This allows us to analyze revenue and orders by year.

For example:

```text
2015
2016
2017
2018
```

The year feature can also be used in SQL and Excel.

---

# 13. Creating Month

```python
df["order_month"] = (
    df["order_date_dateorders"].dt.month
)
```

### Why?

Month numbers allow us to perform monthly analysis.

For example:

```text
1  → January
2  → February
3  → March
```

This helps identify seasonal revenue patterns.

---

# 14. Creating Month Name

```python
df["order_month_name"] = (
    df["order_date_dateorders"].dt.strftime("%b")
)
```

This converts:

```text
1 → Jan
2 → Feb
3 → Mar
```

### Why?

Month names are easier to understand in charts and dashboards.

---

# 15. Creating Quarter

```python
df["order_quarter"] = (
    df["order_date_dateorders"].dt.quarter
)
```

This creates:

```text
1 → Q1
2 → Q2
3 → Q3
4 → Q4
```

### Why?

Quarter-level analysis can help identify broader seasonal business patterns.

---

# 16. Creating Profit Margin

```python
df["profit_margin"] = np.where(
    df["sales"] != 0,
    (df["order_profit_per_order"] / df["sales"]) * 100,
    0
)
```

### Formula

```text
Profit Margin =
Profit / Sales × 100
```

Example:

```text
Sales  = $1,000
Profit = $100

Profit Margin = 100 / 1000 × 100
              = 10%
```

### Why?

Revenue alone does not show how profitable the business is.

Profit margin helps compare profitability across:

* Categories
* Regions
* Discount levels
* Products

---

# 17. Creating Order Month-Year

```python
df["order_month_year"] = (
    df["order_date_dateorders"]
    .dt.to_period("M")
    .astype(str)
)
```

This creates values such as:

```text
2015-01
2015-02
2015-03
```

### Why?

This feature is useful for monthly revenue trend analysis.

It provides a single field that combines:

```text
Year + Month
```

This makes chronological analysis easier.

---

# 18. Creating Delivery Flag

```python
df["delivery_flag"] = np.where(
    df["late_delivery_risk"] == 1,
    "Late",
    "On Time"
)
```

This converts the numerical delivery-risk field:

```text
0 → On Time
1 → Late
```

into an easier-to-understand business category.

### Why?

Instead of showing:

```text
0
1
```

the dashboard can display:

```text
On Time
Late
```

This makes the results easier for business users to understand.

---

# 19. Creating Discount Bands

The dataset contains discount rates as decimal values.

For example:

```text
0.05 = 5%
0.10 = 10%
0.20 = 20%
```

We converted the values into percentage bands:

```python
df["discount_band"] = pd.cut(
    df["order_item_discount_rate"] * 100,
    bins=[-0.01, 0, 5, 10, 20, 25],
    labels=[
        "No Discount",
        "Low (1-5%)",
        "Medium (6-10%)",
        "High (11-20%)",
        "Very High (21-25%)"
    ]
)
```

### Discount bands

| Discount Band |  Range |
| ------------- | -----: |
| No Discount   |     0% |
| Low           |   1–5% |
| Medium        |  6–10% |
| High          | 11–20% |
| Very High     | 21–25% |

### Why?

Analyzing every individual discount percentage can make the analysis difficult to interpret.

Grouping discounts into bands makes it easier to compare:

```text
Discount Level
      ↓
Revenue
Profit
Profit Margin
```

This was later used for the Excel dashboard.

---

# 20. Final Data Validation

After all transformations, the dataset was checked again.

Final dataset:

```text
Rows    : 180,519
Columns : 54
```

Validation included:

```python
df.shape
df.isnull().sum()
df.duplicated().sum()
df.dtypes
```

The final dataset had:

```text
180,519 records
54 columns
0 duplicate rows
3 missing customer_zipcode values
```

The three missing zipcode values were retained because zipcode was not required for the analysis.

---

# 21. Why Feature Engineering Was Important

The original dataset contained many raw fields, but several business metrics were not directly available.

Python created additional analytical fields:

| Feature            | Purpose                                                  |
| ------------------ | -------------------------------------------------------- |
| `shipping_delay`   | Measure difference between actual and scheduled shipping |
| `order_year`       | Yearly analysis                                          |
| `order_month`      | Monthly analysis                                         |
| `order_month_name` | Dashboard-friendly month names                           |
| `order_quarter`    | Quarterly analysis                                       |
| `profit_margin`    | Measure profitability                                    |
| `order_month_year` | Monthly trend analysis                                   |
| `delivery_flag`    | Convert delivery risk into readable labels               |
| `discount_band`    | Analyze discount levels                                  |

---

# 22. Python vs SQL vs Excel

Each tool had a different role in the project.

### Python

Used for:

* Data cleaning
* Data validation
* Date conversion
* Feature engineering
* Preparing the dataset

### PostgreSQL / SQL

Used for:

* Business analysis
* KPI calculations
* Revenue analysis
* Profit analysis
* Category analysis
* Regional analysis
* Shipping analysis
* Discount analysis

### Excel

Used for:

* PivotTables
* Charts
* KPI cards
* Interactive dashboard
* Business presentation

This separation demonstrates an end-to-end analytics workflow rather than performing the entire project in a single tool.

---

# 23. Output of Python Stage

The cleaned dataset was saved as:

```text
supply_chain_cleaned.csv
```

This cleaned dataset was then used as the input for the PostgreSQL stage.

The overall workflow was:

```text
DataCo Raw Dataset
        ↓
     Python
        ↓
Cleaning + Validation
        ↓
Feature Engineering
        ↓
supply_chain_cleaned.csv
        ↓
   PostgreSQL
        ↓
   SQL Analysis
        ↓
      Excel
        ↓
 Dashboard & Business Insights
```

---

# 24. Key Learning Outcomes

Through this Python stage, the project demonstrates practical skills in:

* Pandas
* NumPy
* Data cleaning
* Missing-value analysis
* Duplicate detection
* Data validation
* Datetime manipulation
* Feature engineering
* Business metric creation
* Preparing data for SQL analysis

The objective was not only to clean the dataset, but to create a reliable analytical foundation for the **Supply Chain Analytics project**.
