/*

COVID-19 DATA EXPLORATION 
DATASET - https://ourworldindata.org/covid-deaths

*/

SELECT * 
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--BASIC DATA UNDERSTANDING

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--TOTAL CASES VS TOTAL DEATHS
--SHOWS THE PERCENTAGE CHANCES OF DYING INCASE OF AFFECTED BY COVID-19 BY EACH DATE

SELECT location,date,total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,2) as Chance_of_Death 
FROM Portfolio_Project..covid_deaths
WHERE location='India' AND continent IS NOT NULL
ORDER BY 1,2;

--TOTAL CASES VS POPULATIOM
--SHOWS PERCENTAGE CHANCES OF GETTING COVID-19 IN A COUNTRY BY EACH DATE

SELECT location,date,population,total_cases, ROUND((total_cases/population)*100,2) as Chance_of_Infection
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--TOP 10 COUNTRIES WITH HIGHEST INFECTION PERCENTAGE

SELECT TOP 10 location,population,MAX(total_cases) as Highest_Infection_Count, MAX(ROUND((total_cases/population)*100,2)) as Chance_of_Infection
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY Chance_of_Infection DESC;

--COUNTRIES WITH HIGHEST DEATH COUNT BY LOCATION

SELECT location, MAX(CAST(total_deaths as int)) as Highest_Death_Count
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC;

--DATA OF COUNTRIES WITH HIGHEST DEATH PERCENTAGE

SELECT location,population,MAX(cast(total_deaths as int)) as Highest_Death_Count, MAX(ROUND((cast(total_deaths as int)/population)*100,2)) as Chance_of_Death
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location,population
--HAVING location='United States'
ORDER BY Chance_of_Death DESC;

-- DETAILS ABOUT ALL CONTINENTS

SELECT continent,MAX(CAST(total_deaths as int)) as Highest_Death_Count
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC;

--GLOBAL DATA

SELECT SUM(new_cases) as total__cases,SUM(CAST(new_deaths as int)) as total__deaths,ROUND((SUM(CAST(new_deaths as int))/SUM(new_cases))*100,2) as Chance_of_Death
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL;

--TOTAL POPULATION VS VACCINATIONS
--SHOWING PERCENTAGE OF POPULATION THAT HAS RECEIVED AT LEAST ONE COVID VACCINE

SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY d.location  ORDER BY d.location,d.date) AS Rolling_Vaccination
FROM Portfolio_Project..covid_deaths d
JOIN Portfolio_Project..covid_vaccinations v
ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

--SELECT location,SUM(CAST(new_vaccinations as bigint))
--FROM Portfolio_Project..covid_vaccinations
--GROUP BY location;

-- USING COMMON TABLE EXPRESSIONS(CTE)

WITH People_Vaccinated (Continent, Location,Date,Population,New_vaccinations,Rolling_Vaccination)
AS
(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date)
FROM Portfolio_Project..covid_deaths d
JOIN Portfolio_Project..covid_vaccinations v
ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL
)
SELECT *,(Rolling_Vaccination/Population)*100 AS Percentage_People_Vaccinated
FROM People_Vaccinated;

--USING TEMPORARY TABLE TO PERFORM CALCULATIONS

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
Rolling_Vaccinations NUMERIC
)

INSERT INTO #Percent_Population_Vaccinated
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date)
FROM Portfolio_Project..covid_deaths d
JOIN Portfolio_Project..covid_vaccinations v
ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL

Select *, (Rolling_Vaccinations/Population)*100 AS Percentage_People_Vaccinated
From #Percent_Population_Vaccinated

-- CREATING A VIEW

CREATE VIEW Percentage_Vaccinated AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as Rolling_vaccinations
FROM Portfolio_Project..covid_deaths d
JOIN Portfolio_Project..covid_vaccinations v
ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL;

-- EXECUTING THE CREATED VIEW

SELECT * FROM Percentage_Vaccinated;