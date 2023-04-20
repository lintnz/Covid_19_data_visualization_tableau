SELECT *  FROM coviddeaths;
SELECT *  FROM covidvaccination;

-- data used in the analysis
SELECT "public"."coviddeaths"."date", "location",population, total_cases, total_deaths
FROM coviddeaths
ORDER BY 1;

-- total cases vs total deaths
SELECT "public"."coviddeaths"."date", "location",population, total_cases, total_deaths, 
  (total_deaths::FLOAT / total_cases::FLOAT) * 100 AS mortality_rate
FROM public.coviddeaths
GROUP BY 1,2,3,4,5
ORDER BY 2;
--  likelihood of dying in New Zealand

SELECT date(date_trunc('month', date::date)) AS MONTH, LOCATION, 
       MAX(total_deaths) AS max_deaths, MAX(total_cases) AS max_cases, 
       (MAX(total_deaths)::FLOAT / MAX(total_cases)::FLOAT) * 100 AS death_percentage
FROM public.coviddeaths
WHERE LOCATION = 'New Zealand'
GROUP BY 1, 2
ORDER BY 1;

-- infection vs population in New Zealand

SELECT "public"."coviddeaths"."date", "location",population, total_cases, ( total_cases::FLOAT/"public"."coviddeaths"."population"::FLOAT) * 100 AS nz_mortality_rate
FROM coviddeaths
WHERE LOCATION = 'New Zealand'
ORDER BY 1;

-- infection vs population in World
SELECT "public"."coviddeaths"."date", "location",population, total_cases, ( total_cases::FLOAT/"public"."coviddeaths"."population"::FLOAT) * 100 AS nz_mortality_rate
FROM coviddeaths
WHERE LOCATION = 'World'
ORDER BY 1;

--countries with higest infection rate per population by country

SELECT "public"."coviddeaths"."location", "public"."coviddeaths"."population", MAX(total_cases) AS infection_count,MAX(((total_cases:: FLOAT /"public"."coviddeaths"."population" ::FLOAT)*100))
AS high_infection_rate
FROM "public"."coviddeaths"
WHERE LOCATION NOT IN ('Asia', 'Africa','Europe','World','Lower middle income', 'Upper middle income','Low income', 'High income' ) 
GROUP BY 1,2
ORDER BY high_infection_rate DESC;

--casualities with highest per population in country

SELECT "public"."coviddeaths"."location", "public"."coviddeaths"."population", MAX(total_deaths),MAX(((total_deaths:: FLOAT /"public"."coviddeaths"."population"::FLOAT)*100))
AS highest_mortality_rate
FROM "public"."coviddeaths"
-- WHERE "public"."coviddeaths"."continent" is NULL
WHERE LOCATION NOT IN ('Asia', 'Africa','Europe','World','Lower middle income', 'Upper middle income','Low income', 'High income' ) 
GROUP BY 1,2
ORDER BY highest_mortality_rate DESC;

--highest death count all continents and incomelevels

SELECT "public"."coviddeaths"."location", MAX(total_deaths) AS total_death_count
FROM "public"."coviddeaths"
WHERE "public"."coviddeaths"."continent" IS NULL 
GROUP BY 1
ORDER BY total_death_count DESC;

--highest death count BY INCOME LEVEL

SELECT "public"."coviddeaths"."location", MAX(new_deaths) AS total_death_count
FROM "public"."coviddeaths"
WHERE "public"."coviddeaths"."location" IN ('High income', 'Upper middle income','Lower middle income', 'Low income' ) 
GROUP BY 1
ORDER BY total_death_count DESC;

--highest death count BY CONTINENTS
SELECT "public"."coviddeaths"."continent", MAX(total_deaths) AS total_death_count
FROM "public"."coviddeaths"
WHERE "public"."coviddeaths"."continent" IS NOT NULL 
GROUP BY 1
ORDER BY total_death_count DESC;


--GLOBAL NUMBERS-------------------

--GLOBAL NUMBER AND RATIO OF NEW CASES VS NEW DEATHS

SELECT SUM(new_cases::INT) AS new_total_cases,
    SUM(new_deaths::INT) AS new_total_deaths, 
    CASE WHEN SUM(new_cases::INT) = 0 THEN NULL
    ELSE SUM(new_deaths::INT)::FLOAT / SUM(new_cases::INT)::FLOAT * 100
    END AS mortality_rate
FROM public.coviddeaths
WHERE "public"."coviddeaths"."continent" IS NOT NULL
ORDER BY 1;

--GLOBAL NUMBERS AND RATIOS OF NEW CASES VS NEW DEATHS 


SELECT "public"."coviddeaths"."date",    
    SUM(new_cases::INT) AS new_total_cases,
    SUM(new_deaths::INT) AS new_total_deaths, 
    CASE WHEN SUM(new_cases::INT) = 0 THEN NULL
    ELSE SUM(new_deaths::INT)::FLOAT / SUM(new_cases::INT)::FLOAT * 100
    END AS mortality_rate
FROM public.coviddeaths
WHERE "public"."coviddeaths"."continent" IS NOT NULL
GROUP BY "public"."coviddeaths"."date","public"."coviddeaths"."new_cases",new_deaths
ORDER BY 1,2;

--------------------VACCINATION DATA----------------------

WITH popu_vs_vaccination (continent,"location", date, population, new_vaccinations, rolling_num_vaccinated)
AS
(
SELECT cds.continent,cds.location, cds.date, cds.population, cvn.new_vaccinations, SUM(cvn."new_vaccinations" :: INT) OVER (PARTITION BY cds.location ORDER BY cds.location, cds.date) AS rolling_num_vaccinated
FROM public.coviddeaths cds
JOIN public.covidvaccination cvn
ON cds.location = cvn.location
AND cds.date = cvn.date 
WHERE cds.continent IS NOT NULL
)
SELECT * ,(rolling_num_vaccinated /population)*100
FROM popu_vs_vaccination;

-------------
-- TEMP TABLE---- 
----------------------

CREATE TABLE percent_population_vaccinated 
(
continent TEXT,
location_vacci  TEXT,
date_vacci date,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_num_vaccinated NUMERIC
)
DROP IF EXISTS percent_population_vaccinated;
INSERT INTO percent_population_vaccinated
SELECT cds.continent, cds.location, cds.date, cds.population, cvn.new_vaccinations, 
       SUM(cvn.new_vaccinations::INT) OVER (PARTITION BY cds.location ORDER BY cds.location, cds.date) AS rolling_num_vaccinated
FROM public.coviddeaths cds
JOIN public.covidvaccination cvn
ON cds.location = cvn.location
AND cds.date = cvn.date
WHERE cds.continent IS NOT NULL;

SELECT *, (rolling_num_vaccinated / population) * 100
FROM percent_population_vaccinated;

---------
-- VIEW FOR DATA VISULISATION--
-----------
CREATE VIEW population_vaccinated AS
SELECT cds.continent,cds.location, cds.date, cds.population, cvn.new_vaccinations, SUM(cvn."new_vaccinations" :: INT) OVER (PARTITION BY cds.location ORDER BY cds.location, cds.date) AS rolling_num_vaccinated
FROM public.coviddeaths cds
JOIN public.covidvaccination cvn
ON cds.location = cvn.location
AND cds.date = cvn.date 
WHERE cds.continent IS NOT NULL;

SELECT * FROM population_vaccinated ;
