SELECT * 
FROM PortfolioProject.CovidDeaths
order by 3, 4;

-- SELECT * 
-- FROM PortfolioProject.CovidVaccinations
-- order by 3, 4

-- Select Data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs. Total Deaths
-- Likelihood of dying from Covid based on reported cases in the US
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE location LIKE "United States"
ORDER BY 1, 2;

-- Looking at Total Cases vs. Population
-- Percentage of population that has contracted Covid in US
SELECT Location, date, total_cases,population, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject.CovidDeaths
WHERE location LIKE "United States"
ORDER BY 1, 2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC;

-- Countries with Highest Death Count Per Population
SELECT Location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM (
    SELECT *
    FROM PortfolioProject.CovidDeaths
    WHERE continent IS NOT NULL AND TRIM(continent) <> ''
) AS NotNullContinents
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Continents with Highest Death Count
SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM PortfolioProject.CovidDeaths
WHERE Continent!=''
GROUP BY Continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS UNSIGNED)) AS Total_Deaths, SUM(cast(new_deaths AS UNSIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE Continent!='' AND Continent IS NOT NULL
GROUP BY Date
ORDER BY 1, 2;

-- Total Population vs. Total Vaccination

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.Continent!='' AND dea.Continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

-- Temp Table
USE PortfolioProject;
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%m/%d/%y'),
    dea.population, 
    NULLIF(vac.new_vaccinations, ''),
    COALESCE(SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED)), 0) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.Continent != '' AND dea.Continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations;

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
Create View PercentagePopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DpercentagepopulationvaccinatedATE(dea.date, '%m/%d/%y'),
    dea.population, 
    NULLIF(vac.new_vaccinations, ''),
    COALESCE(SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED)), 0) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.Continent != '' AND dea.Continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations;

-- Access View
SELECT *
FROM PercentagePopulationVaccinated;
