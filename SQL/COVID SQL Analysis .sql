SELECT * FROM sreeTest.CovidDeaths 
where continent <> ''
ORDER BY 3,4

--

SELECT location, recordDate, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

-- Likelihood to dying if infected by covid19

SELECT location, recordDate, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc
FROM CovidDeaths
WHERE location like 'Netherlands'
ORDER BY 1, 2

-- total_cases vs population

SELECT location, recordDate, total_cases, population, (total_cases/population)*100 as InfectionPerc
FROM CovidDeaths
WHERE location like 'Netherlands'
ORDER BY 1, 2

-- Countries with Highest Infection Rate vs population

SELECT location, population, MAX(total_cases) as TopInfections, MAX(total_cases/population)*100 as MaxInfectionPerc
FROM CovidDeaths
GROUP BY location, population
ORDER BY MaxInfectionPerc DESC

-- Countries with Highest Death Rate vs population

SELECT location, MAX(total_deaths) as TopDeaths
FROM CovidDeaths
WHERE continent <> ''
GROUP BY location
ORDER BY TopDeaths DESC

-- Continents with Highest Death Rate vs population

SELECT continent, MAX(total_deaths) as TopDeaths
FROM CovidDeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY TopDeaths DESC

-- Global Numbers per recorded date

SELECT recordDate, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPerc
FROM CovidDeaths
WHERE continent <> ''
GROUP By recordDate
ORDER BY 1, 2

-- Convert date column into date format

ALTER TABLE CovidVaccinations
ADD COLUMN recordDate date AFTER location

SELECT * from CovidVaccinations

UPDATE CovidVaccinations
SET recordDate = STR_TO_DATE(date, '%d/%m/%Y')

ALTER TABLE CovidVaccinations
DROP COLUMN date

-- 

SELECT
	covdeath.continent,
	covdeath.location,
	covdeath.recordDate,
	covdeath.population,
	covac.new_vaccinations,
	SUM(covac.new_vaccinations) OVER (PARTITION BY covdeath.location ORDER BY covdeath.location,
		covdeath.recordDate) as RollingVaccineCount
FROM CovidDeaths covdeath
JOIN CovidVaccinations covac
	ON covdeath.location = covac.location AND covdeath.recordDate = covac.recordDate
WHERE covdeath.continent <> ''
ORDER BY 2,3

-- Find the progression of vaccination as a perc of population per day, in each location
-- Using a CTE 

WITH PopVsVac (Continent, Location, RecordDate, Population, NewVaccinations, RollingVaccineCount)
AS (
SELECT
	covdeath.continent, covdeath.location, covdeath.recordDate,covdeath.population, covac.new_vaccinations,
	SUM(covac.new_vaccinations) OVER (PARTITION BY covdeath.location ORDER BY covdeath.location,
		covdeath.recordDate) as RollingVaccineCount
FROM CovidDeaths covdeath
JOIN CovidVaccinations covac
	ON covdeath.location = covac.location AND covdeath.recordDate = covac.recordDate
WHERE covdeath.continent <> ''
)
SELECT *, (RollingVaccineCount/Population)*100 AS RollingVaccinePerc FROM PopVsVac

-- View for Visualisations

CREATE VIEW PercPopVaccinated AS
SELECT
	covdeath.continent, covdeath.location, covdeath.recordDate,covdeath.population, covac.new_vaccinations,
	SUM(covac.new_vaccinations) OVER (PARTITION BY covdeath.location ORDER BY covdeath.location,
		covdeath.recordDate) as RollingVaccineCount
FROM CovidDeaths covdeath
JOIN CovidVaccinations covac
	ON covdeath.location = covac.location AND covdeath.recordDate = covac.recordDate
WHERE covdeath.continent <> ''


--
-- TAB1

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(New_Cases))*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

-- TAB2

SELECT location, SUM(new_deaths) as TotalDeaths
FROM CovidDeaths
WHERE continent = '' AND `location` not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeaths DESC

-- TAB3

Select location, population, MAX(total_cases) as TopInfections,  MAX(total_cases/population)*100 as MaxInfectionPerc
FROM CovidDeaths
Group by location, population
order by MaxInfectionPerc desc


-- TAB4

Select Location, Population, recordDate, MAX(total_cases) as TopInfections,  MAX(total_cases/population)*100 as MaxInfectionPerc
FROM CovidDeaths
Group by location, population, recordDate
order by MaxInfectionPerc desc

