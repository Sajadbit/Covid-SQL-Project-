-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
order by 1,2

-- Total cases vs Total deaths by country
CREATE PROCEDURE DeathPercentage
@country varchar(20)
as
Create table #DeathPercentage
(Location varchar (50), Date datetime, Total_Cases int, Total_Deaths int, DeathPercentage decimal(8,5))

insert into #DeathPercentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
from CovidProject..CovidDeaths
where Location like @country and  continent is not null
order by location, date

select *
from #DeathPercentage
;
exec DeathPercentage World

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
where continent is null and location not like 'International' -- Adding not like to remove International row
group by location 
order by 2 desc
