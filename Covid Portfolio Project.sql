

select *
FROM CovidProject..CovidDeaths
--where continent is not null
ORDER by 3,4

--select *
--FROM CovidProject..CovidVaccinations
--ORDER by 3,4

--selecting Data that will be used

select location,date,total_cases,new_cases,total_deaths,population
FROM CovidProject..CovidDeaths
ORDER by 1,2


----Total Cases Vs Total Deaths
---- Shows the likehood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
where location like  '%Cana%'
and continent is not null
ORDER by 1,2


----- Looking at Total Cases Vs Population
----- Showing what percentage of population got Covid

select location,date,population,total_cases,(total_cases/population)*100 AS InfectedPercentage
FROM CovidProject..CovidDeaths
--where location like  '%Cana%'
where continent is not null
ORDER by 1,2

----- Total number of people infected with covid and number of death as at April 2021

select location,population,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage
FROM CovidProject..CovidDeaths
--where location like '%Afghanistan%'
where continent is not null
GROUP BY location,population
ORDER BY 1,2


----- Looking at Countries with Highest Infection Rate compared to Population

select location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS InfectedPercentage
FROM CovidProject..CovidDeaths
--where location like  '%Nigeria%'
where continent is not null
GROUP by location,population
ORDER by InfectedPercentage desc


----- Showing Countries with Highest Death Count

select location,MAX(cast(total_deaths as int)) AS totaldeathcount
FROM CovidProject..CovidDeaths
--where location like  '%Nigeria%'
where continent is not null
GROUP by location
ORDER by totaldeathcount desc


----- Showing Continents with Highest Death Count (Correct)

select location,MAX(cast(total_deaths as int)) AS totaldeathcount
FROM CovidProject..CovidDeaths
--where location like  '%Nigeria%'
where continent is null
GROUP by location
ORDER by totaldeathcount desc

----- Showing Continents with Highest Death Count( For Project Purpose)

select continent,MAX(cast(total_deaths as int)) AS totaldeathcount
FROM CovidProject..CovidDeaths
--where location like  '%Nigeria%'
where continent is not null
GROUP by continent
ORDER by totaldeathcount desc


------ GLOBAL NUMBER

---- Total Cases and Death

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage
FROM CovidProject..CovidDeaths
--where location like  '%Nigeria%'
where continent is not null
--GROUP by date
ORDER by 1,2



select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage
FROM CovidProject..CovidDeaths
--where location like  '%Nigeria%'
where continent is not null
GROUP by date
ORDER by 1,2




--- Looking at Total Population vs Vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100 
FROM CovidProject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
ORDER by 2,3



---- USE CTE

With PopvsVac(continent,location,Date,Population,new_vaccinations,Rollingpeoplevaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100 
FROM CovidProject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--ORDER by 2,3
)

Select *, (Rollingpeoplevaccinated/population)*100
From PopvsVac



----- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100 
FROM CovidProject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--ORDER by 2,3

Select *, (Rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated



----- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date)
as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100 
FROM CovidProject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *
from #PercentPopulationVaccinated




