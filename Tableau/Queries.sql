-- 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectCOVID19..CovidDeaths
where continent is not null 
order by total_cases, total_deaths


-- 2. 
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From ProjectCOVID19..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectCOVID19..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectCOVID19..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 5
select d.continent, d.location, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.Location order by d.location, d.date) as TotalVaccinationsInSteps
from ProjectCOVID19..CovidDeaths d
join ProjectCOVID19..CovidVaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not NULL
order by d.location