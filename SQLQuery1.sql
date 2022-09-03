SELECT * 
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data  that we are  going to be using 

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of diyng if you contract Covid in your Country 

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPrecentage 
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs The Population
-- Shows what % of population got Covid

SELECT location,date, total_cases, population, (total_cases/population)*100 AS InfectedPrecentage 
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS HighestInfection,  MAX((total_cases/population))*100 AS InfectedPrecentage 
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY InfectedPrecentage DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Brake down by Continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
   On dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
   On dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


--Create View to store data for later vizualisations


CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
   On dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3