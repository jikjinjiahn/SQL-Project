-- 1. select all columns for all patients
SELECT * FROM insurance_data;

-- 2. display the average claim amount for patients in each region
SELECT region, avg(claim) claim
FROM insurance_data
GROUP BY region ORDER BY region;

-- 3. select the maximum and minimum BMI values in the table
SELECT max(BMI) max_BMI, min(BMI) min_BMI from insurance_data;

-- 4. select the PatinedID, age and BMI for patients with a BMI
--    between 40 and 50
SELECT PatientID, Age, bmi FROM insurance_data
WHERE BMI BETWEEN 40 AND 50;

-- 5. select the number of smokers in each region
SELECT region, count(PatientID) smoker_cnt FROM insurance_data
WHERE smoker = 'Yes'
GROUP BY region ORDER BY region;

-- 6. what is the average claim amount for patients who are both diabetic and smokers
SELECT avg(claim) FROM insurance_data
WHERE diabetic = 'Yes' AND smoker = 'Yes';

-- 7. retrieve all patients who have a BMI greater than the average BMI
--    of patients who are smokers
SELECT PatientID, smoker, bmi FROM insurance_data
WHERE smoker = 'Yes' AND
	bmi > (SELECT avg(bmi) FROM insurance_data WHERE smoker = 'Yes');

-- 8. select the average claim amount for patients in each age group
SELECT 
	CASE
		WHEN age < 20 THEN 'under 20'
        WHEN age BETWEEN 20 AND 30 THEN '20-30'
        WHEN age BETWEEN 31 AND 50 THEN '31-50'
        ELSE 'over 50'
	END age_group,
	round(avg(claim), 2) avr_claim
FROM insurance_data
GROUP BY age_group ORDER BY age_group;

-- 9. *** retrieve the total claim amount for each patient,
--    along with the average claim amount across all patients
SELECT PatientID,
		sum(claim) OVER(PARTITION BY PatientID) total_claim,
        avg(claim) OVER() avr_claim
FROM insurance_data;

-- 10. retrieve the top 3 patients with the highest claim amount along with
--     their respective claim amount and the total claim amount for all patients
SELECT PatientID, claim, sum(claim) OVER() 'total_claim'
FROM insurance_data
ORDER BY claim DESC LIMIT 3;

-- 11. *** select the details of patients who have a claim amount
--     greater than the average claim amount for their region
SELECT * FROM insurance_data tb1
WHERE claim > 
(SELECT round(avg(claim),2) FROM insurance_data tb2 WHERE tb2.region = tb1.region);

SELECT * FROM
	(SELECT *, avg(claim) OVER(PARTITION BY region) avr_claim
     FROM insurance_data) subquery
WHERE claim > avr_claim;

-- 12. *** retrieve the rank of each patient based on their claim amount
SELECT RANK() OVER(ORDER BY claim DESC) 'rank',
	PatientID, claim 
FROM insurance_data;

-- 13. select the details of patients along with their claim amount,
--     and their rank based on claim amount within their region
SELECT *, RANK() OVER(ORDER BY claim DESC) 'rank' 
FROM insurance_data;

SELECT *, RANK() OVER(PARTITION BY region ORDER BY claim DESC) rank_by_region
FROM insurance_data;







