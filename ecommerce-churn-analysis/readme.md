# E-Commerce Customer Churn Prediction: Olist Dataset

## 📌 Project Overview
This project performs an end-to-end customer churn analysis on the public Olist Brazilian E-Commerce dataset. By engineering behavioral features (RFM) in PostgreSQL and building a tuned Random Forest predictive model in Python, this project successfully identified **8,763 at-risk customers**, representing **$1,321,895.81 in potential lost revenue**. 

## 🛠 Tech Stack
* **Database:** PostgreSQL (pgAdmin 4)
* **Language:** Python 3 (Jupyter Notebooks).
* **Libraries:** pandas, scikit-learn, xgboost, matplotlib, seaborn.
* **Machine Learning:** Random Forest, XGBoost, RandomizedSearchCV.

## 🚀 Project Architecture & Workflow

### 1. Data Engineering & SQL Feature Engineering
* Processed over 100,000 raw e-commerce records into a structured relational database.
* Wrote complex Common Table Expressions (CTEs) and joins in SQL to aggregate customer behavior into **RFM metrics** (Recency, Frequency, Monetary).
* Defined the target variable (`is_churned`) as any customer with no purchases in the last >180 days.

### 2. Exploratory Data Analysis & Handling Data Leakage
* Generated correlation matrices and heatmaps to inspect feature relationships.
* **Critical Finding:** Discovered and corrected a data leakage flaw where recency features artificially inflated model accuracy. 
* **Solution:** Removed direct recency leakage from the feature matrix, forcing the model to learn churn patterns strictly from behavioral frequency and spend.

### 3. Machine Learning & Optimization
* Tested the integration of Customer Review Scores (`avg_review_score`), which revealed that single-purchase 5-star ratings introduced noise rather than predictive power (accuracy dropped to 70.25%).
* Tested an advanced **XGBoost** classifier, which achieved a 59.77% baseline on the low-dimensional dataset.
* **Final Model Selection:** Tuned a Random Forest model using `RandomizedSearchCV` (optimizing `n_estimators`, `max_depth`, `min_samples_split`, and `min_samples_leaf`) to achieve a final optimized accuracy of **74.00%**.

### 4. Business Impact & Insights
* **Feature Importance:** Visualized the Random Forest decision criteria, revealing that `monetary_total_spent` is the overwhelming driver of churn predictability in this specific single-purchase-heavy marketplace.
* **Financial Translation:** By filtering the test data for True Positives (customers who actually churned and were correctly flagged by the model), the analysis successfully isolated **8,763 at-risk customers** representing **$1,321,895.81 in at-risk revenue**. 
* **Recommendation:** Marketing teams can deploy this model to proactively target high-spend, at-risk users with customized retention campaigns *before* they cross the 180-day inactivity threshold.
