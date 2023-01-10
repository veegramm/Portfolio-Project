Select *
From PortfolioProject..CovidDeaths
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2

--Looking at the total cases versus total deaths
-- shows the likelihood of dieing if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order By 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'
Order By 1,2

--Looking at the total cases versus the population
--Shows what percentage of population got covid

Select location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'
Order By 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Group By location, population
Order By PercentPopulationInfected desc

--Showing the countries with the Highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
-- This should be noted rom the raw data
Group By location
Order By TotalDeathCount desc

--Let's break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
-- This should be noted rom the raw data
Group By continent
Order By TotalDeathCount desc

--Showing the continents with the highest deat counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
-- This should be noted rom the raw data
Group By continent
Order By TotalDeathCount desc


--Global numbers
--Sum of new cases per day
--Sum of new deaths per day

Select date, SUM(new_cases) --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
Group By date
Order By 1,2

Select date, SUM(new_cases) as totalcasesdaily, SUM(cast(new_deaths as int)) as totaldeathsdaily 
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
Group By date
Order By 1,2

--Death percentage globally.

Select date, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
Group By date
Order By 1,2

--Thus, total cases daily,total deaths daily and death percentage globally is

Select date, SUM(new_cases) as totalcasesdaily, SUM(cast(new_deaths as int)) as totaldeathsdaily, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

--Total Cases reported across the world

Select SUM(new_cases) as totalcasesdaily, SUM(cast(new_deaths as int)) as totaldeathsdaily, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


Select *
From PortfolioProject..CovidVaccinations

--Joining the two tables

Select *
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Looking at total Population vs vaccinations (total number of people in the world that have been vaccinated)

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using a CTE

With CTE_PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as 
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From CTE_PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime,
Population numeric,
New_Vaccinations int,
RollingPeopleVaccinated int
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store later for visualizations

Create View PercentPopulationVacinated as

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Create View DeathPercentageGlobally as
Select date, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent is not null
Group By date
