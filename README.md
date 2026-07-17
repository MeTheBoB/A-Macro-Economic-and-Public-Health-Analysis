# A-Macro-Economic-and-Public-Health-Analysis


## 1. Project Overview
This analysis leverages global socio-economic and public health data to quantify modernization velocity, evaluate the efficacy of public investment, and mathematically segment global markets. The objective is to transition raw, volatile datasets into curated insights that enable data-driven strategic planning and resource allocation.

## 2. Business Questions
* **Targeting Markets:** Which countries represent the "sweet spot" for emerging market investment, defined by specific GDP and hygiene infrastructure thresholds?'
* **Modernization Velocity:** Which nations are modernizing fastest in terms of GDP growth and infrastructure investment?'
* **Investment Efficacy:** Does increased government expenditure on education act as a strong driver for reducing under-five mortality rates?'
* **Development Segmentation:** Can we move beyond individual country reporting to group the global economy into four distinct, strategically actionable "Development Tiers"?'
* **Comparative Performance:** Is a specific target nation (e.g., Bangladesh) improving its key health indicators faster than the broader regional or global average?'

## 3. Technical & Analytical Implementation

### 3.1 Data Pipeline & Integration
* **SQL Server ETL Pipeline:** Engineered a robust data ingestion pipeline using `SQLAlchemy` and `pyodbc` to programmatically transfer processed datasets from Python to a SQL Server database.
* **Schema Definition:** Implemented strict data typing (Float, String, Integer, BigInteger) during the migration process to maintain data integrity and optimize query performance.
* **Efficient Data Handling:** Employed chunking methods (`chunksize=100`) and multi-row inserts (`method='multi'`) to ensure stable and memory-efficient data migration for large datasets.

### 3.2 Data Curation & Engineering (SQL Layer)
* **Market Identification:** Automated filtering to define "Target Emerging Markets," identifying nations where GDP per capita is < $15,000 and basic hygiene access falls between 40% and 80%'.
* **Growth Velocity Modeling:** Application of window functions to calculate Year-over-Year (YoY) percentage changes in GDP per capita and public-private partnership infrastructure commitments'.
* **Trend Smoothing:** Development of 5-year rolling averages for infrastructure investment flows to mitigate annual volatility and distinguish long-term secular trends from noise'.
* **Benchmarking:** Design of dynamic window functions to compute global and regional annual averages, providing a stable baseline for comparing individual country performance'.

### 3.3 Analytical Intelligence & Machine Learning (Python Layer)
* **Statistical Relationship Modeling:** Utilization of Pearson Correlation analysis to test the hypothesis that increased government education expenditure drives reduced under-five mortality rates'.
* **Market Segmentation (Unsupervised Learning):** Deployment of a K-Means Clustering model to classify countries into four distinct “Development Tiers” based on economic and health-based features'.
* **Model Optimization:** Implementation of the Elbow Method to determine the optimal number of clusters ($k$), ensuring the mathematical validity of the resulting segments'.
* **Standardization Pipeline:** Application of feature scaling (StandardScaler) to ensure diverse features (e.g., currency vs. percentages) contribute proportionally to cluster distance calculations'.

### 3.4 Reporting & Synthesis
* **Multi-Dimensional Analysis:** Preparation of consolidated “analytics-ready” tables that join demographic, economic, and infrastructure datasets, optimized for trend reporting'.
* **Comparative Performance Framework:** Execution of relative difference calculations (country-specific vs. cohort average) to provide an immediate diagnostic of country-level performance'.

---
*Authored by: Mahathir Islam*
*Date: 17/07/2026*
