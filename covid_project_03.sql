-- 1. Create views for later visualization
DROP VIEW vaccinated_population;

CREATE VIEW vaccinated_population AS
SELECT	dea.continent, dea.location,
		dea.date, dea.population, vac.new_vaccinations,
        sum(vac.new_vaccinations) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
        AS accumulated_vaccinations
FROM coviddeaths_new AS dea
JOIN covidvaccinations_new AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> '';

SELECT *
FROM vaccinated_population;