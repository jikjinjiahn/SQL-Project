SELECT *
FROM coviddeaths_new;

SELECT *
FROM covidvaccinations_new;

-- Selecting columns that is going to be used :
SELECT 	location, date,
        total_cases, new_cases,
        total_deaths, population
FROM coviddeaths_new
ORDER BY 1, 2;


-- 1. Percentage of daily deaths among people who contract covid in the USA :
SELECT	location, date, total_cases, total_deaths,
		(total_deaths/total_cases) * 100 AS '% of_daily deaths'
FROM coviddeaths_new
WHERE location like '%states%';


-- 2. Percentage of the population infected with covid on daily base in the USA :
SELECT 	location, date, population, total_cases,
		(total_cases/population) * 100 AS '% of covid infection'
FROM coviddeaths_new
WHERE location like '%states%';


-- 3. Countries with highest infection rate compared to population :
SELECT	location, population,
		max(cast(total_cases AS UNSIGNED)) AS total_count,
        max(total_cases/population) * 100 AS '% of covid infection'
FROM coviddeaths_new
GROUP BY location, population
ORDER BY 4 DESC;


-- 4. Countries with the highest death per population :
SELECT 	location,
		max(cast(total_deaths AS UNSIGNED)) AS total_death_count
FROM coviddeaths_new
where continent IS NOT NULL AND continent <> ''
GROUP BY location
ORDER BY 2 DESC;


-- 5. Continent with the highest death count :
SELECT 	continent,
		max(cast(total_deaths as UNSIGNED)) AS total_deat_count
FROM coviddeaths_new
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY continent
ORDER BY 2 DESC;
/*
	The result of the total counts is not correct
    so WHERE clause is going to be fixed by including empty rows.
*/

SELECT 	location,
		max(cast(total_deaths as UNSIGNED)) AS total_deat_count
FROM coviddeaths_new
WHERE continent = '' OR continent IS NULL
GROUP BY location
ORDER BY 2 DESC;


-- 6. Percentage of the daily global death by date :
SELECT	date,
		sum(new_cases) AS total_cases,
        sum(new_deaths) AS total_deaths,
        sum(total_deaths)/sum(total_cases) * 100 
			AS '% of daily death'
FROM coviddeaths_new
where continent IS NOT NULL AND continent <> ''
GROUP BY date
ORDER BY 1, 2;

SELECT	sum(new_cases) AS total_cases,
        sum(new_deaths) AS total_deaths,
        sum(total_deaths)/sum(total_cases) * 100 
			AS '% of daily death'
FROM coviddeaths_new
where continent IS NOT NULL AND continent <> ''
ORDER BY 1, 2;







