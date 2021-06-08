--Select *
--From PortfolioProject..covidvaccinations
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..coviddeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid-19 in the United Kingdom.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths
Where location like '%kingdom%'
order by 1,2 

-- Looking at total cases vs population
-- Shows percentage of population that has contracted covid-19 in the United Kingdom.
Select location, date, total_cases, population, (total_cases/population)*100 as PercentageCases
From PortfolioProject..coviddeaths
Where location like '%kingdom%'
order by 1,2 

--Looking at countries with highest infection rate compared to population
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases)/population)*100 as PercentageCases
From PortfolioProject..coviddeaths
Group by location, population
order by PercentageCases desc

-- Looking at countries with highest total death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Looking at continents with highest total death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..coviddeaths
where continent is not null
--group by date
order by 1,2 

-- Looking at Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, rollingtotalvaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
from PopVsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingtotalvaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingtotalvaccinations/population)*100
from #PercentPopulationVaccinated



