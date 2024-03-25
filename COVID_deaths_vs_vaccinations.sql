Select *
From PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProjects..CovidVaccinations
--order by 3,4

--Selecting the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
order by 1,2


--Total Cases vs Total Deaths
--Demonstrates the likelihood of death if an individual contracted COVID-19 in the United Kingdom
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where Location like '%Kingdom%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Demonstrates what percentage of a country's population contracted COVID-19
Select location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where Location like '%Kingdom%'
order by 1,2

--Looking at countries with highest infection rate in comparison to population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where Location like '%Kingdom%'
Group by location, population
order by PercentPopulationInfected desc

--Demonstrating which countries have the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
where continent is not null
--Where Location like '%Kingdom%'
Group by location
order by TotalDeathCount desc

--Breaking things down by continent

--Demonstrating which continents have the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
where continent is not null
--Where Location like '%Kingdom%'
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where Location like '%Kingdom%'
where continent is not null
group by date
order by 1,2

--World Total 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where Location like '%Kingdom%'
where continent is not null
order by 1,2

--Looking at Total Population vs Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using a CTE

With PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinatedRolling)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (PeopleVaccinatedRolling/population)*100
From Popvsvac

-- Temp Table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinatedRolling numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (PeopleVaccinatedRolling/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Select *
--From PercentPopulationVaccinated

/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProjects..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
