CREATE DATABASE healthcare_db;
USE healthcare_db;


-- 1.Which medical conditions have the highest patient volume?
SELECT
    medical_condition,
    COUNT(*) AS patient_count
FROM healthcare
GROUP BY medical_condition
ORDER BY patient_count DESC;


-- 2-- How do Emergency, Urgent, and Elective admissions compare in patient volume, average billing, and average length of stay?
 SELECT
    admission_type,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM healthcare
GROUP BY admission_type
ORDER BY patient_count DESC;


-- 3. Which hospitals have high patient volume but also high average length of stay?

WITH hospital_stats AS (
    SELECT
        hospital,
        COUNT(*) AS patient_count,
        AVG(length_of_stay) AS avg_length_of_stay,
        AVG(billing_amount) AS avg_billing
    FROM healthcare
    GROUP BY hospital
),

ranked_hospitals AS (
    SELECT
        hospital,
        patient_count,
        ROUND(avg_length_of_stay, 2) AS avg_length_of_stay,
        ROUND(avg_billing, 2) AS avg_billing,

        NTILE(4) OVER (
            ORDER BY patient_count DESC
        ) AS volume_quartile,

        NTILE(4) OVER (
            ORDER BY avg_length_of_stay DESC
        ) AS stay_quartile

    FROM hospital_stats
)

SELECT
    hospital,
    patient_count,
    avg_length_of_stay,
    avg_billing
FROM ranked_hospitals
WHERE volume_quartile = 1
  AND stay_quartile = 1
ORDER BY
    patient_count DESC,
    avg_length_of_stay DESC;



-- 4.Which insurance providers contribute the most patients and total billing?

SELECT
    insurance_provider,
    COUNT(*) AS patient_count,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS avg_billing
FROM healthcare
GROUP BY insurance_provider
ORDER BY total_billing DESC;

-- 5.Are patient volume and billing increasing or decreasing over time?
SELECT
    YEAR(date_of_admission) AS admission_year,
    MONTH(date_of_admission) AS admission_month,
    COUNT(*) AS patient_count,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS avg_billing
FROM healthcare
GROUP BY
    YEAR(date_of_admission),
    MONTH(date_of_admission)
ORDER BY
    admission_year,
    admission_month;
    
-- 6.Which hospitals are the biggest contributors to total billing?

select hospital,round(sum(billing_amount),2) as total_billing_amount
from healthcare
group by hospital
order by total_billing_amount
limit 10;

-- 7.-- Which hospitals have average billing above the overall dataset average?
SELECT
    hospital,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing
FROM healthcare
GROUP BY hospital
HAVING AVG(billing_amount) > (
    SELECT AVG(billing_amount)
    FROM healthcare
)
ORDER BY avg_billing DESC;


-- 8.How does length of stay affect average billing?
SELECT
    CASE
        WHEN length_of_stay <= 7 THEN '1-7 Days'
        WHEN length_of_stay <= 14 THEN '8-14 Days'
        WHEN length_of_stay <= 21 THEN '15-21 Days'
        ELSE '22+ Days'
    END AS stay_group,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(SUM(billing_amount), 2) AS total_billing
FROM healthcare
GROUP BY stay_group
ORDER BY
    CASE stay_group
        WHEN '1-7 Days' THEN 1
        WHEN '8-14 Days' THEN 2
        WHEN '15-21 Days' THEN 3
        WHEN '22+ Days' THEN 4
    END;
    
    
 --  9.  Which doctors handle the highest number of patients within each hospital?
 
 WITH doctor_stats AS (
    SELECT
        hospital,
        doctor,
        COUNT(*) AS patient_count,
        ROUND(AVG(billing_amount), 2) AS avg_billing,
        ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
    FROM healthcare
    GROUP BY hospital, doctor
),

ranked_doctors AS (
    SELECT
        hospital,
        doctor,
        patient_count,
        avg_billing,
        avg_length_of_stay,
        DENSE_RANK() OVER (
            PARTITION BY hospital
            ORDER BY patient_count DESC
        ) AS doctor_rank
    FROM doctor_stats
)

SELECT
    hospital,
    doctor,
    patient_count,
    avg_billing,
    avg_length_of_stay,
    doctor_rank
FROM ranked_doctors
WHERE doctor_rank <= 3
ORDER BY hospital, doctor_rank;


-- 10.Has the dominant medical condition changed over the years?
WITH yearly_conditions AS (
    SELECT
        YEAR(date_of_admission) AS admission_year,
        medical_condition,
        COUNT(*) AS patient_count
    FROM healthcare
    GROUP BY
        YEAR(date_of_admission),
        medical_condition
),

ranked_conditions AS (
    SELECT
        admission_year,
        medical_condition,
        patient_count,
        DENSE_RANK() OVER (
            PARTITION BY admission_year
            ORDER BY patient_count DESC
        ) AS condition_rank
    FROM yearly_conditions
)

SELECT
    admission_year,
    medical_condition,
    patient_count
FROM ranked_conditions
WHERE condition_rank = 1
ORDER BY admission_year;

