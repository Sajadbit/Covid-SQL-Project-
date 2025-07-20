-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
order by 1,2

-- Total cases vs Total deaths by country
DROP PROCEDURE IF EXISTS DeathPercentage 

CREATE PROCEDURE DeathPercentage
@country varchar(20)
as
begin
	Create table #DeathPercentage
	(Location varchar (50),
	Date datetime,
	Total_Cases int,
	Total_Deaths int,
	DeathPercentage decimal(8,5))

	insert into #DeathPercentage
	select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
	from CovidProject..CovidDeaths
	where Location like @country and  continent is not null
	order by location, date

	select *
	from #DeathPercentage
end;

exec DeathPercentage Canada

-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100  as Infection_Rate
from CovidProject..CovidDeaths
where continent is not null
order by location, date

-- Shows countries with highest infection rate compared to population
select Location, Population, max(total_cases) as Total_Cases, max((total_cases/population))*100  as Infection_Rate
from CovidProject..CovidDeaths
where continent is not null
group by location, population
order by Infection_Rate desc

-- Shows countries with highest death count per populatin
select Location, Population, max(cast(total_deaths as int)) as Total_Deaths, max((total_deaths/population))*100  as Death_Rate
from CovidProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- Deaths by continent 
select location, max(cast(total_deaths as int)) as Total_Deaths, max((total_deaths/population))*100  as Death_Rate
from CovidProject..CovidDeaths
where continent is null and location not in( 'International' , 'World') -- Adding not like to remove International row
group by location 
order by 2 desc


-- Global numbers
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
where continent is not null
order by 1


-- Total Population vs Vaccinations by CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) Over ( Partition By dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths as dea  join CovidProject..CovidVaccinations as vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac


-- Temp table for saving total population that are vaccianted 

Drop Table if exists #Percent_Population_Vaccinated

Create Table #Percent_Population_Vaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric)

insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) Over ( Partition By dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths as dea  join CovidProject..CovidVaccinations as vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From #Percent_Population_Vaccinated

-- Creating view for data visualization

Create View Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) Over ( Partition By dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths as dea  join CovidProject..CovidVaccinations as vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *
from Percent_Population_Vaccinated