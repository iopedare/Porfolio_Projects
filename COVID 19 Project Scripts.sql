select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--where continent is not null
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by location, population
order by PopulationPercentageInfected DESC



-- Looking at Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount DESC


-- Let's break things down by continent




-- Showing continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC


-- Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
-- group by date
order by 1,2



-- Looking at Total Popluation vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as cummulativePeopleVaccinated
--, (cummulativePeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, cummulativePeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as cummulativePeopleVaccinated
--, (cummulativePeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (cummulativePeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

DROP TABLE if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations bigint,
cummulativePeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as cummulativePeopleVaccinated
--, (cummulativePeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (cummulativePeopleVaccinated/Population)*100
from #percentPopulationVaccinated


-- Creating View to store data for later visialization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as cummulativePeopleVaccinated
--, (cummulativePeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3


SELECT * FROM PercentPopulationVaccinated
