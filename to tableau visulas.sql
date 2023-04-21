-- TO Tableau file 1--GLOBAL RATIO OF NEW CASES VS NEW DEATHS

SELECT SUM(new_cases::INT) AS new_total_cases,
    SUM(new_deaths::INT) AS new_total_deaths, 
    CASE WHEN SUM(new_cases::INT) = 0 THEN NULL
    ELSE SUM(new_deaths::INT)::FLOAT / SUM(new_cases::INT)::FLOAT * 100
    END AS mortality_rate
FROM public.coviddeaths
WHERE "public"."coviddeaths"."continent" IS NOT NULL
ORDER BY 1,2;

-- TO Tableau file 2--Continentwise death number

SELECT "public"."coviddeaths"."continent", 
MAX(total_deaths::INT) AS total_death_count
FROM "public"."coviddeaths"
WHERE "public"."coviddeaths"."continent" IS NOT NULL
GROUP BY 1
ORDER BY total_death_count DESC;