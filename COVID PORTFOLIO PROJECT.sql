select * from CovidDeaths
where continent is not null

select * from CovidVaccinations

--select the data which we will be using
Select location, date, population_density, total_cases, new_cases, total_deaths
from CovidDeaths order by 1,2

-- total cases vs total deaths
Select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
from CovidDeaths 
where location LIKE '%india'
order by 1,2


-- looking at total cases vs population
Select location, date,total_cases, population_density, (total_cases/population_density)*100 as DeathPercentage
from CovidDeaths 
where location LIKE '%india'
order by 1,2


--looking at countries with highest infection rate compared to population
Select location,MAX(total_cases) as HighestInfectionCount, population_density, MAX((total_cases/population_density)*100) as PopulationInfected
from CovidDeaths 
where continent is not null
group by population_density, location
order by PopulationInfected DESC


--- showing countries with the highest death count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc


--- lets break this down by continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc

---- showing continents with highest death count per population
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
Select date, SUM(cast(new_cases as BIGINT)) as new_cases, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(total_deaths as int))/SUM(cast(new_cases as BIGINT))*100 as PercentageDeaths
from CovidDeaths 
--where location LIKE '%india'
where continent is not null
group by date
order by 1,2


Select *
From CovidVaccinations
order by 1,2

--looking at total population vs vaccinations

Select C.continent, C.location, C.date, C.population_density, C1.new_vaccinations,
SUM(CONVERT(int,C1.new_vaccinations)) OVER (Partition by C.location order by C.location, C.date) as RollingPeopleVaccinated
From CovidDeaths C JOIN CovidVaccinations C1 ON
C.location = C1.location AND C.date = C1.date
where C.continent is not null
--order by 2,3

--USE CTE
with PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select C.continent, C.location, C.date, C.population_density, C1.new_vaccinations,
SUM(CONVERT(int,C1.new_vaccinations)) OVER (Partition by C.location order by C.location, C.date) as RollingPeopleVaccinated
From CovidDeaths C JOIN CovidVaccinations C1 ON
C.location = C1.location AND C.date = C1.date
where C.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

-- TEMP TABLE
Drop table if exists #PercentPeopleVaccinated

Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select C.continent, C.location, C.date, C.population_density, C1.new_vaccinations,
SUM(CONVERT(int,C1.new_vaccinations)) OVER (Partition by C.location order by C.location, C.date) as RollingPeopleVaccinated
From CovidDeaths C JOIN CovidVaccinations C1 ON
C.location = C1.location AND C.date = C1.date
where C.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated

--CREATING VIEWS
Create View PercentPeopleVaccinated as
Select C.continent, C.location, C.date, C.population_density, C1.new_vaccinations,
SUM(CONVERT(int,C1.new_vaccinations)) OVER (Partition by C.location order by C.location, C.date) as RollingPeopleVaccinated
From CovidDeaths C JOIN CovidVaccinations C1 ON
C.location = C1.location AND C.date = C1.date
where C.continent is not null
--order by 2,3

Select *
from PercentPeopleVaccinated