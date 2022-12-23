SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of pop that has contracted covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS GotCovid
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location like '%states%'
ORDER BY 1,2

-- Countries w highest infection rates compared to pop

SELECT Location, Population, MAX(total_cases) AS HighestInfecCount, MAX((total_cases/population))*100 AS GotCovid
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY GotCovid DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCt
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCt DESC

--Show countries w highest death count per pop
SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCt
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCt DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total pop vs vaccinations
--USE CTE
WITH PopVSVac (Continent, Location, Date, Population, new_vaccinations, RollingPPLVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS bigint)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPPLVaccinated
--, (RollingPPLVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPPLVaccinated/Population)*100
FROM PopVSVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPPLVaccinated numeric
)
Insert into #PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS bigint)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPPLVaccinated
--, (RollingPPLVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPPLVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store date for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS bigint)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPPLVaccinated
--, (RollingPPLVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
