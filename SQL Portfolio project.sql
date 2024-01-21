
select *
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4;

select *
from [Portfolio Project]..['Covid Vaccination$']
order by 3,4;


-- Select Data we are going to be using

Select location, 
       date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying from Covid in various Countries
Select location, 
       date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 as Deaths_per_cases
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population that contracted Covid

Select location, 
       date,
	   Population,
	   total_cases,
	   (total_cases/population)*100 as Cases_per_population
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at Countries with the highest infection rate compared to Population

select location,
       population,
	   Max(total_cases) as infections,
	   Max((total_cases/population)*100) as Cases_per_population
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by Location, Population
order by 4 desc



-- Looking at Countries with the highest Death count per Population

select location,
       population,
	   Max(cast (total_deaths as int)) as Total_deaths
	   -- Max((total_deaths/population)*100) as deaths_per_population
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by Location, Population
order by 3 desc

-- Looking at Continents with the highest Death count per Population
select continent,
	   Max(cast (total_deaths as int)) as Total_deaths
	   -- Max((total_deaths/population)*100) as deaths_per_population
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by continent
order by 2 desc

-- Global Numbers: Death, Cases, Death_per_cases_%

select date, 
       sum(new_cases) as total_cases,
	   sum(cast(new_deaths as int)) as total_deaths,
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by date
order by 1 asc

select sum(new_cases) as total_cases,
	   sum(cast(new_deaths as int)) as total_deaths,
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
-- group by date
-- order by 1 asc

select *
from [Portfolio Project]..CovidDeaths$ A
JOIN [Portfolio Project]..CovidVaccinations$  B
on A.location = B.location
and A.date = B.date

-- Total Population vs Total Vaccination
select A.continent,
       A.location,
	   A.date,
	   B.new_vaccinations,
	   sum(cast (B.new_vaccinations as int)) over (Partition by A.location order by A.location, A.date) as Rolling_Vaccinations
from [Portfolio Project]..CovidDeaths$ A
JOIN [Portfolio Project]..CovidVaccinations$  B
on A.location = B.location
and A.date = B.date
where A.continent is not null
order by 2,3

-- People Vaccinated in each country
with Covid_data (continent, location, date, new_vaccinations, Rolling_Vaccinations)
as
(select A.continent,
       A.location,
	   A.date,
	   B.new_vaccinations,
	   sum(cast (B.new_vaccinations as int)) over (Partition by A.location order by A.location, A.date) as Rolling_Vaccinations
from [Portfolio Project]..CovidDeaths$ A
JOIN [Portfolio Project]..CovidVaccinations$  B
on A.location = B.location
and A.date = B.date
where A.continent is not null
--order by 2,3
)
Select continent,
       location,
	   -- date,
	   Max(Rolling_Vaccinations) as Total_Vaccinations
from Covid_data
group by continent, location
order by 3 desc



-- Creating view to store data for later visualizations
Create view Percentpopulationvaccinated as
select A.continent,
       A.location,
	   A.date,
	   B.new_vaccinations,
	   sum(cast (B.new_vaccinations as int)) over (Partition by A.location order by A.location, A.date) as Rolling_Vaccinations
from [Portfolio Project]..CovidDeaths$ A
JOIN [Portfolio Project]..CovidVaccinations$  B
on A.location = B.location
and A.date = B.date
where A.continent is not null
--order by 2,3

Select *
from Percentpopulationvaccinated