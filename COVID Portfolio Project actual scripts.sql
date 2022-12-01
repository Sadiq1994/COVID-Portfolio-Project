USE Projects;

SELECT * FROM CovidDeaths
ORDER BY 3,4;

/*
SELECT * FROM CovidVaccination
ORDER BY 3,4;
*/

-- Select data that we are going to be using

SELECT location,date,population,total_cases,new_cases,total_deaths
FROM CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying f contract covid in your country

SELECT location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at Total Cases vs Percentage
-- Shows what percentage of population got covid

SELECT location,date,population,total_cases,ROUND((total_cases/population)*100,2) AS PopulationPercentageCases
FROM CovidDeaths
--WHERE location = 'INDIA';
ORDER BY 1,2;

SELECT * FROM CovidDeaths;

-- Looking at the Countries with the highest Infection rate compared to population

SELECT location,population,MAX(total_cases) AS HighestInfectCount,
ROUND(MAX((total_cases/population))*100,2) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population

SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT location FROM CovidDeaths
WHERE continent IS NULL
group by location;

DELETE FROM CovidDeaths
WHERE location IN ('Upper middle income','Low Income');

-- Let's Break things by Continent



-- Showing the continents with the Highest Death Counts
SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Golbal Numbers 

SELECT SUM(new_cases) AS Total_Cases
, SUM(CAST(new_deaths AS int)) AS Total_Deaths
, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 , 2) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY DeathPercentage DESC;


-- Looking at Total Population vs Vaccinations


-- USE CTE
WITH PopVac(continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT cd.continent,cd.location, cd.date , cd.population, cv.new_vaccinations
,SUM (CONVERT(BIGINT,cv.new_vaccinations)) OVER( PARTITION BY cd.location ORDER BY cd.location ,cd.date ) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/cd.population)*100
FROM CovidDeaths cd
JOIN CovidVaccination cv
  ON cd.location = cv.location 
  AND
     cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *
,ROUND((RollingPeopleVaccinated/population)*100,2)
FROM PopVac;


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
Continent nVARCHAR(255),
Location nVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent,cd.location, cd.date , cd.population, cv.new_vaccinations
,SUM (CONVERT(BIGINT,cv.new_vaccinations)) OVER( PARTITION BY cd.location ORDER BY cd.location ,cd.date ) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccination cv
  ON cd.location = cv.location 
  AND
     cd.date = cv.date;
--WHERE cd.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *
,(RollingPeopleVaccinated/Population)*100
FROM  #PercentPopulationVaccinated;

-- Creating View to store data structure for later visualization

CREATE VIEW GlobalNumbers
AS
SELECT SUM(new_cases) AS Total_Cases
, SUM(CAST(new_deaths AS int)) AS Total_Deaths
, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 , 2) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;

CREATE VIEW Continents
AS
SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC;

CREATE VIEW PercentPopulationVaccinated
AS
SELECT cd.continent,cd.location, cd.date , cd.population, cv.new_vaccinations
,SUM (CONVERT(BIGINT,cv.new_vaccinations)) OVER( PARTITION BY cd.location ORDER BY cd.location ,cd.date ) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccination cv
  ON cd.location = cv.location 
  AND
     cd.date = cv.date
WHERE cd.continent IS NOT NULL ;

SELECT * FROM PercentPopulationVaccinated;