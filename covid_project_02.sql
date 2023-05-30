SELECT *
FROM coviddeaths_new AS dea
JOIN covidvaccinations_new AS vac
ON dea.location = vac.location AND dea.date = vac.date;
    

-- 1. Population who vaccinated on daily base :
SELECT 	dea.continent, dea.location, 
		dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths_new AS dea
JOIN covidvaccinations_new as vac  
ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL AND dea.continent <> ''
ORDER BY 2, 3;


-- 2. Rolling counts of new vaccination on the location base :
SELECT 	dea.continent, dea.location, 
		dea.date, dea.population, vac.new_vaccinations,
		sum(vac.new_vaccinations)
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
        AS accumulated_vaccinations
        -- 'partition-by' only gives total, 'order by' shows daily accumulated counts. 
FROM coviddeaths_new AS dea
JOIN covidvaccinations_new as vac 
ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL AND dea.continent <> ''
ORDER BY 2, 3;


-- 3. Calculate the percentage of new vaccination over population through CTE :
WITH pop_vs_vac(
	continent, location, date, population,
    new_vaccinations, accumulated_vaccinations) 
AS(
	SELECT 	dea.continent, dea.location, 
			dea.date, dea.population, vac.new_vaccinations,
			sum(vac.new_vaccinations)
			OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
			AS accumulated_vaccinations
	FROM coviddeaths_new AS dea
	JOIN covidvaccinations_new as vac 
	ON dea.location = vac.location AND dea.date = vac.date
	where dea.continent IS NOT NULL AND dea.continent <> ''
)
SELECT 	*, 
		(accumulated_vaccinations/population) * 100 AS '% of vaccination'
FROM pop_vs_vac;


-- 4. Calculate the percentage of new vaccination over population through Temporary Table :
CREATE TEMPORARY TABLE temp_pop_vs_vac(
	continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population VARCHAR(255),
    new_vaccinations VARCHAR(255),
    accumulated_vaccinations VARCHAR(255)
);

INSERT INTO temp_pop_vs_vac
	SELECT 	dea.continent, dea.location, 
			dea.date, dea.population, vac.new_vaccinations,
			sum(vac.new_vaccinations)
			OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
			AS accumulated_vaccinations
	FROM coviddeaths_new AS dea
	JOIN covidvaccinations_new as vac 
	ON dea.location = vac.location AND dea.date = vac.date;
	-- where dea.continent IS NOT NULL AND dea.continent <> '';
    
SELECT 	*, 
		(accumulated_vaccinations/population) * 100 AS '% of vaccinations'
FROM temp_pop_vs_vac;

drop TABLE temp_pop_vs_vac;


