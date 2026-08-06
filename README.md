# 🏥 Healthcare Data Analytics Project

<img width="1329" height="744" alt="Screenshot 2026-08-05 230146" src="https://github.com/user-attachments/assets/9a401438-38f1-4b66-908b-bdf633d853eb" />


## 📌 Project Overview

This is an end-to-end Healthcare Data Analytics project focused on analyzing patient records, hospital performance, medical conditions, admission patterns, billing, and length of stay.

The project follows a complete data analytics workflow:

**Raw Data → Python → MySQL → SQL → Power BI → Business Insights**

The main objective is to transform raw healthcare data into meaningful insights that can help understand patient trends, hospital workload, billing patterns, and operational performance.

---

## 🎯 Business Objectives

- Analyze patient admission trends over time.
- Identify the most common medical conditions.
- Analyze Emergency, Urgent, and Elective admissions.
- Compare billing across medical conditions.
- Identify hospitals with the highest patient volume.
- Analyze patient volume against average length of stay.
- Build an interactive dashboard for healthcare management analysis.

---

## 📊 Dataset

The dataset initially contained approximately **55,500 patient records** and **15 columns**.

### Important columns:

- Name
- Age
- Gender
- Blood Type
- Medical Condition
- Date of Admission
- Doctor
- Hospital
- Insurance Provider
- Billing Amount
- Room Number
- Admission Type
- Discharge Date
- Medication
- Test Results

During data cleaning, **534 duplicate records** were identified and removed, resulting in approximately **54,966 records** for analysis.

---

# 🔄 Project Workflow

## 1. Data Cleaning & EDA — Python

Python and Pandas were used to clean and prepare the dataset.

### Data cleaning activities:

- Checked rows and columns
- Checked data types
- Checked missing values
- Identified and removed duplicates
- Standardized column names
- Removed unnecessary spaces
- Converted date columns into datetime format
- Created Length of Stay
- Checked billing amount quality
- Identified negative billing records
- Performed categorical analysis

### Length of Stay

A new column was created:

```python
df["length_of_stay"] = (
    df["discharge_date"] - df["date_of_admission"]
).dt.days
