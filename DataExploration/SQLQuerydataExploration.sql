

select *
from porfolioproject..CovidDeaths
order by 3, 4

select *
from porfolioproject..CovidVaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from porfolioproject..CovidDeaths
where location like '%vie%' and total_deaths is not null
--order by 1,2


select location, population, MAX (total_cases) as HighestInfectionCount , max((total_cases/population))*100 as PercentPopulationInfected
from porfolioproject..CovidDeaths
where location like '%state%'
group by location, population
order by PercentPopulationInfected desc

showing the country with highest death

select Location, Max(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing the Continent with Highest Death Count
Select continent, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
group by continent
Order by 1,2 desc



select *
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated )
as (
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated /population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated /population)*100
From PopvsVac

