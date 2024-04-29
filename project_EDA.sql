-- Exploratory Data Analysis

SELECT 	max(total_laid_off),
		max(percentage_laid_off)
FROM layoffs_staging2
;

SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1 
ORDER BY total_laid_off DESC
;    # 116 companies have laid off all their employees

SELECT company, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company ORDER BY 2 DESC
;

SELECT min(`date`), max(`date`)
FROM layoffs_staging2
;    # total_laid_off period

SELECT industry, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY industry ORDER BY 2 DESC
;

SELECT country, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY country ORDER BY 2 DESC
;

SELECT year(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY year(`date`) ORDER BY 1 DESC
;

SELECT stage, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY stage ORDER BY 2 DESC
;

SELECT 	substring(`date`, 1, 7) AS `Month`,
		sum(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY `Month` ORDER BY 1
;    # total_laid_off by month

WITH cte_rolling_total AS(
	SELECT 	substring(`date`, 1, 7) AS `Month`,
			sum(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE substring(`date`, 1, 7) IS NOT NULL
	GROUP BY `Month` ORDER BY 1
)
SELECT 	`Month`,
		total_off,
		sum(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM cte_rolling_total
;

SELECT	company, year(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year(`date`) ORDER BY 3 DESC
;

WITH cte_company_year(company, years, total_laid_off) AS(
	SELECT	company, year(`date`), sum(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, year(`date`)
), 
cte_company_year_rank AS(
	SELECT	*,
			DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM cte_company_year
	WHERE years IS NOT NULL
)
SELECT * FROM cte_company_year_rank
WHERE ranking <= 5
;


