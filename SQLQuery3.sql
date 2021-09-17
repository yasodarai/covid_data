
Select *
From covid1.dbo.CovidDeaths
Where continent is not null 
order by 3,4;

Select *
From covid1.dbo.covidVaccine
Where continent is not null 
order by 3,4;

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From covid1.dbo.CovidDeaths
Where continent is not null 
order by 1,2;

-- Total Cases vs Population
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From  covid1.dbo.CovidDeaths
--Where location like '%Australia%'
Where continent is not null 
order by 1,2;

Select location, population,MAX(total_cases) AS highestInfection,  MAX((total_cases/population))*100 as PercentPopulationInfected
from covid.dbo.CovidDeaths
--where location like '%Australia%'
where continent is not null
group by location, population
order by PercentPopulationInfected DESC;

-- Total Cases vs Total Deaths
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid.dbo.CovidDeaths
--Where location like '%Australia%'
Where continent is not null 
order by 1,2 DESC;


Select location, population,MAX(total_deaths) as TotalDeathCount,  MAX((total_deaths/population))*100 as PercentPopulationDeath
from covid.dbo.CovidDeaths
--where location like '%Australia%'
where continent is not null
group by location, population
order by PercentPopulationDeath DESC;

-- Countries, continent with Highest Death Count per Population
Select location, MAX(total_deaths) as TotalDeathCount
from covid.dbo.CovidDeaths
--where location like '%Australia%'
where continent is not null
group by location
order by TotalDeathCount DESC;

Select continent, MAX(total_deaths) as TotalDeathCount
from covid.dbo.CovidDeaths
--where location like '%Australia%'
where continent is not null
group by continent
order by TotalDeathCount DESC;

Select location, MAX(total_deaths) as TotalDeathCount
from covid.dbo.CovidDeaths
--where location like '%Australia%'
where continent is null
group by location
order by TotalDeathCount DESC;

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int) )/SUM(new_cases)*100 as DeathPercentage
from covid.dbo.CovidDeaths
--Where location like '%Australia%'
where continent is not null 
--Group By date
order by 1,2;


-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select * from covid.dbo.CovidDeaths d
JOIN covid.dbo.covidVaccine v
ON d.location=v.location
AND d.date= v.date;

select d.continent, d.location, d.date, d.population, v.new_vaccinations 
from covid.dbo.CovidDeaths d
JOIN  covid.dbo.covidVaccine v
ON d.location=v.location
AND d.date= v.date
where d.continent is not null
order by 2,3;

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER (partition by d.location Order by d.location , d.date)  as RollingPeopleVaccinated
from covid.dbo.CovidDeaths d
JOIN covid.dbo.covidVaccine v
ON d.location=v.location
AND d.date= v.date
where d.continent is not null
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int, v.new_vaccinations)) OVER (partition by d.location Order by d.location , d.date)  as RollingPeopleVaccinated
from covid.dbo.CovidDeaths d
JOIN covid.dbo.covidVaccine v
ON d.location=v.location
AND d.date= v.date
where d.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

--create view
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid.dbo.CovidDeaths d
Join covid.dbo.covidVaccine v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
