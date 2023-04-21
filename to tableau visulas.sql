
---New Zealand 1
SELECT SUM(new_cases::int) AS new_total_cases,
    SUM(new_deaths::int) AS new_total_deaths, 
    CASE WHEN SUM(new_cases::int) = 0 THEN NULL
    ELSE SUM(new_deaths::int)::float / SUM(new_cases::int)::float * 100
    END AS mortality_rate
FROM public.coviddeaths
WHERE LOCATION = 'New Zealand'
ORDER BY 1,2;

-- TO Tableau file 1--GLOBAL RATIO OF NEW CASES VS NEW DEATHS

SELECT SUM(new_cases::int) AS new_total_cases,
    SUM(new_deaths::int) AS new_total_deaths, 
    CASE WHEN SUM(new_cases::int) = 0 THEN NULL
    ELSE SUM(new_deaths::int)::float / SUM(new_cases::int)::float * 100
    END AS mortality_rate
FROM public.coviddeaths
WHERE "public"."coviddeaths"."continent" is NOT null
ORDER BY 1,2;

-- TO Tableau file 2--Continentwise death number

SELECT "public"."coviddeaths"."continent", 
MAX(total_deaths::INT) AS total_death_count
FROM "public"."coviddeaths"
WHERE "public"."coviddeaths"."continent" is not null
GROUP BY 1
ORDER BY total_death_count DESC;

-- TO Tableau file 3--Continentwise death number
--Removed 'Asia', 'Africa','Europe','World' came to location which have to represent country
--'Northern Cyprus', 'North Korea','Turkmenistan','Taiwan','Wales', 'Hong Kong', 'England','Northern Ireland','Western Sahara' , 'Scotland', 'Macao' Not recoganized as countries 
--Removed 'Lower middle income', 'Upper middle income','Low income', 'High income' from location and continents
SELECT "public"."coviddeaths"."location", "public"."coviddeaths"."population", MAX(total_cases) AS infection_count,MAX(((total_cases:: FLOAT /"public"."coviddeaths"."population" ::FLOAT)*100))
AS infection_rate
FROM "public"."coviddeaths"
WHERE LOCATION NOT IN ('Asia', 'Africa','Europe','World','Northern Cyprus', 'North Korea','Turkmenistan','Taiwan','Wales', 'Hong Kong', 'England','Northern Ireland','Western Sahara' , 'Scotland', 'Macao' , 
'Lower middle income', 'Upper middle income','Low income', 'High income'   )
GROUP BY 1,2
ORDER BY infection_rate DESC;

-- TO Tableau file 4--infection rate

SELECT "public"."coviddeaths"."location", "public"."coviddeaths"."population", "public"."coviddeaths"."date", MAX(total_cases) AS infection_count,MAX(((total_cases:: FLOAT /"public"."coviddeaths"."population" ::FLOAT)*100))
AS infection_rate
FROM "public"."coviddeaths"
WHERE LOCATION NOT IN ('Asia', 'Africa','Europe','World','Northern Cyprus', 'North Korea','Turkmenistan','Taiwan','Wales', 'Hong Kong', 'England','Northern Ireland','Western Sahara' , 'Scotland', 'Macao' , 
'Lower middle income', 'Upper middle income','Low income', 'High income'   ) 
GROUP BY 1,2,3
ORDER BY infection_rate DESC;
