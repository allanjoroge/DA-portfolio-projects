select * 
from PortfolioProjects..CovidDeaths
where continent is not null --gets rid of 
order by 3,4

select * 
from PortfolioProjects..CovidVacinations
order by 3,4


-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not null 
order by 1,2

-- looking at total cases vs total deaths
-- shows the likelyhood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%states%' and continent is not null 
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null 
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- showing countries with the highest deathcount per population 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null 
Group by location
order by TotalDeathCount desc

-- lets break things down by continent


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is null 
Group by location
order by TotalDeathCount desc


-- shwoing the continents with the highest death counts

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null 
Group by continent
order by TotalDeathCount desc


-- global numbers

select date, Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null 
group by date
order by 1,2

-- world wide

select Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null 
-- group by date
order by 1,2

-- looking at total population vs vaccinations

select * 
from PortfolioProjects..CovidDeaths dea 
Join PortfolioProjects..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)* 100
from PortfolioProjects..CovidDeaths dea 
Join PortfolioProjects..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

With PopvsVac(Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)* 100
from PortfolioProjects..CovidDeaths dea 
Join PortfolioProjects..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated -- recommened if you are gonna be making any changes
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)* 100
from PortfolioProjects..CovidDeaths dea 
Join PortfolioProjects..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)* 100
from PortfolioProjects..CovidDeaths dea 
Join PortfolioProjects..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * 
from PercentPopulationVaccinated
