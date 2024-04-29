DROP DATABASE IF EXISTS `world_layoffs`;
CREATE DATABASE world_layoffs;
USE world_layoffs;


# creating the same table to keep the raw data in staging
CREATE TABLE layoffs_staging
LIKE layoffs
;
INSERT layoffs_staging 
SELECT * FROM layoffs
;
SELECT * FROM layoffs_staging;


# 1. removing duplicates by using row_number()
WITH cte_duplicate AS(
	SELECT	*,
			ROW_NUMBER() OVER(PARTITION BY
				company, location, industry, total_laid_off, percentage_laid_off, 
				`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging)
SELECT * FROM cte_duplicate
WHERE row_num > 1
;	# here, duplicates results(row_number = 2) are produced.

# to delete duplicates, make another staging table and delete actual column from it
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
	SELECT	*,
			ROW_NUMBER() OVER(PARTITION BY
				company, location, industry, total_laid_off, percentage_laid_off, 
				`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
;

DELETE FROM layoffs_staging2
WHERE row_num > 1
;
SELECT * FROM layoffs_staging2
WHERE row_num > 1
;

# 2. standardizing data (find issues and fix them)
UPDATE layoffs_staging2
SET company = trim(company)
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;
SELECT DISTINCT industry FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = trim(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;
SELECT DISTINCT country FROM layoffs_staging2;

# changing date format
SELECT 	`date`,
		str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y')
;

# casting date column datatype
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE
;
SELECT * FROM layoffs_staging2;


# 3. dealing with null or blank values
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL
;
SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry = ''
;

# populate and update columns
SELECT t1.industry, t2.industry 
FROM layoffs_staging2 t1 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL
;

UPDATE layoffs_staging2    # change blank into NULL value
SET industry = NULL
WHERE industry = ''
;

UPDATE layoffs_staging2 t1 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL
;


# 4. delete rows
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL
;
SELECT * FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;




















