--Select *
--From PortfolioProject.dbo.CovidDeaths
--order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking total cases vs total deaths
-- Shows likelihood of dying 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%desh'
order by 1,2

-- Looking at total cases vs Population
-- Shows what percentage of population got covid in Bangladesh
Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%desh'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PopulationInfectedPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%desh'
group by location, population
order by PopulationInfectedPercentage desc


-- Showing countries with the highest death count for population
Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%desh'
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's break things down by continent

-- Showing the continents with the highest death per population

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%desh'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%desh'
where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated )
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 2, 3)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Drop table if exists #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated