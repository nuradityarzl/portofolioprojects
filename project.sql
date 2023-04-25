select *
from master.dbo.coviddeath1

--select data that we are going to be USING

select location, date, total_cases, new_cases, total_deaths, population
from master.dbo.coviddeath1
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as deathpercentage
from master.dbo.coviddeath1
where location = 'indonesia' and continent is not null
order by 2 

-- looking at total cases vs population
-- show what percentage of population got covid

select location, date, total_cases, population, (total_cases/population) * 100 as casespercentage
from master.dbo.coviddeath1
--where location = 'indonesia'
where continent is not null
order by 1,2 

-- looking countries with highest infection
-- show what percentage of population got covid

select location, population, max(total_cases) as highestinfection, max((total_cases/population)) * 100 as casespercentage
from master.dbo.coviddeath1
--where location = 'indonesia'
where continent is not null
group by location, population
order by 4 desc

-- looking countries with highest death per population

select location, max(total_deaths) as highestdeathcount--, max((total_deaths/population)) * 100 as deathpercentage
from master.dbo.coviddeath1
--where location = 'indonesia'
where continent is not null
group by location
order by 2 desc

-- lets break things down by continent

-- showing continent with highest death per population

select continent, max(total_deaths) as highestdeathcount--, max((total_deaths/population)) * 100 as deathpercentage
from master.dbo.coviddeath1
--where location = 'indonesia'
where continent is not null
group by continent
order by 2 desc

-- global numbers
select sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases) * 100 as deathspercentage 
from master.dbo.coviddeath1
--where location = 'indonesia' and 
where continent is not null and new_cases <> 0
--group by date
order by 1,2


-- looking  at total population vs vaccinations
select dea.continent, dea.LOCATION, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacc 
--,(rollingpeoplevacc/dea.population)*100
from master.dbo.coviddeath1 dea
join covidvaccination1 vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevacc)
AS
(
select dea.continent, dea.LOCATION, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacc 
--,(rollingpeoplevacc/dea.population)*100
from master.dbo.coviddeath1 dea
join covidvaccination1 vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevacc/population)*100
from popvsvac

--TEMP TABLE
drop table if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
    continent nvarchar(255),
    LOCATION nvarchar(255),
    date datetime,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevacc NUMERIC
)

insert INTO #percentpopulationvaccinated
select dea.continent, dea.LOCATION, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacc 
--,(rollingpeoplevacc/dea.population)*100
from master.dbo.coviddeath1 dea
join covidvaccination1 vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevacc/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualtization

create VIEW percentpopulationvaccinated as
select dea.continent, dea.LOCATION, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacc 
--,(rollingpeoplevacc/dea.population)*100
from master.dbo.coviddeath1 dea
join covidvaccination1 vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3