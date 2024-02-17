select * 
from CovidDeaths
where continent is not null
order by 3,4

--select Data,that we are going to strart with

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2


--total_case Vs total_death
--Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2

--total_case Vs Population
-- Shows what percentage of population infected with Covid


select location,date,total_cases,population,(total_cases/population)*100 as PercentagepopulationInfection
from CovidDeaths
where location like '%state%'
--and continent is not null
order by 1,2

--Countries with heightst infection Rate compared to population

select location,population , MAX(total_cases)as heightsinfetion , max((total_cases/population))*100 as percentagepopulationinfetion
from CovidDeaths
group by location,population
order by percentagepopulationinfetion desc


--countries with heghst death count per population

select location ,max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not null
group by location
order by Totaldeathcount desc


--Breaking Things Down by Continent
--Showing Continent with highst death count per population

select continent , Max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathcount desc

--Global Number
select sum(new_cases) as TotalCases , sum(cast(total_deaths as int)) as TotalDeath, sum(cast(total_deaths as int))/sum(new_cases)*100 as GlubalDeathpercentage
from CovidDeaths
where continent is not null
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int))  over(partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
order by RollingPeopleVaccinated desc

-- Using CTE to perform Calculation on Partition By in previous query


with PopVSvac(continent , location , date , population , new_vaccinations , RollingpeopleVaccinated)

as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int))  over(partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
--order by RollingPeopleVaccinated desc
)
select*,(RollingPeopleVaccinated/population)*100
from PopVSvac


-- Using Temp Table to perform Calculation on Partition By in previous query


Drop Table if exists #percentagepopulationVaccinated
create Table #percentagepopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int))  over(partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
order by RollingPeopleVaccinated desc

select*,(RollingPeopleVaccinated / population)*100
from #percentagepopulationVaccinated

-- Creating View to store data for later visualizations

Create View percentagepopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *
from percentagepopulationVaccinated