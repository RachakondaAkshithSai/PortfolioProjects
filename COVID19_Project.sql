--Test cases
--select *
--from ProjectCOVID19..CovidDeaths

--select *
--from ProjectCOVID19..CovidVaccinations

select continent, location, date, total_cases, new_cases, total_deaths, population
from ProjectCOVID19..CovidDeaths
where continent is not null 
order by continent, location, date

-- Total Cases vs Total Deaths (not NULL) as DeathPercentage in India in descending order
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectCOVID19..CovidDeaths
where (total_deaths/total_cases)*100 is not NULL and location = 'India'
order by DeathPercentage desc

-- Total Cases vs Population -percentage of population infected with Covid
select Location, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from ProjectCOVID19..CovidDeaths
order by PercentPopulationInfected desc

-- Countries with Highest Infection Rate compared to Population
select Location, Population, 
max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as HighestPercentInfected
from ProjectCOVID19..CovidDeaths
group by Location, population
order by HighestPercentInfected desc

-- Locations with Highest Death Count per Population
-- Cast the total_deaths to integers to order them in desc
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from ProjectCOVID19..CovidDeaths
where continent is not NULL
group by Location
order by HighestDeathCount desc

-- Continents (location whose continent is NULL) with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from ProjectCOVID19..CovidDeaths
where continent is NULL
group by location
order by HighestDeathCount desc

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from ProjectCOVID19..CovidDeaths
where continent is not NULL
group by continent
order by HighestDeathCount desc

-- Global numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from ProjectCOVID19..CovidDeaths
where continent is not null

-- Total Population vs Total Vaccinations (Join two tables)
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select d.continent, d.location, d.date, d.population, v.total_vaccinations
from ProjectCOVID19..CovidDeaths d
join ProjectCOVID19..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null and v.total_vaccinations is not NULL
order by d.location, d.date

-- Total Population vs New Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.Location order by d.location, d.date) as TotalVaccinationsInSteps
from ProjectCOVID19..CovidDeaths d
join ProjectCOVID19..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not NULL
order by d.location, d.date

-- Using CTE to perform Calculation on Partition By in previous query
with popVSnewvac(Continent, Location, Date, Population, New_Vaccinations, TotalVaccinationsInSteps)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.Location order by d.location, d.date) as TotalVaccinationsInSteps
from ProjectCOVID19..CovidDeaths d
join ProjectCOVID19..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not NULL
--order by d.location, d.date (The order by clause is invalid in CTE's, views, subqueries etc.)
)
select *, (TotalVaccinationsInSteps/population)*100 as PercentVaccinated
from popVSnewvac

-- Using Temp Table to perform Calculation on Partition By in previous query
-- drop table if exists #PercentPopulationVaccinated - Include this if you alter the table orelse it will throw an error
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinationsInSteps numeric
)
insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.Location order by d.location, d.date) as TotalVaccinationsInSteps
from ProjectCOVID19..CovidDeaths d
join ProjectCOVID19..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not NULL

select *, (TotalVaccinationsInSteps/population)*100 as PercentVaccinated
from #PercentPopulationVaccinated

-- Creating views for visualization in Tableau
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.Location order by d.location, d.date) as TotalVaccinationsInSteps
from ProjectCOVID19..CovidDeaths d
join ProjectCOVID19..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not NULL