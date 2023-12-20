SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population_density
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows the percentage of population that was positive for COVID

SELECT location, date, total_cases, population,
(CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0)) * 100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population,
MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0)))* 100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PopulationInfectedPercentage desc


-- Looking at countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Highest Death Count per Continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Total Death Count per Continent

SELECT continent, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT date, SUM(CAST(new_cases AS int)) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths,
SUM(CAST(new_deaths AS int)*1.0)/NULLIF(SUM(CAST(new_cases AS int)),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated*1.0/Population)*100
FROM PopvsVac



--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_Vaccinations bigint,
RollingPeopleVaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated*1.0/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated