--Select *
--From PortfolioProject..CovidDeaths
--Order By 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3, 4

-- CovidDeaths Queries
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1, 2

-- Total Cases vs Total Deaths: Likelihood of dying if you contract covid by country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order By 1, 2

-- Total Cases vs Population: What % of population have Covid

Select location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order By 1, 2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group By location, population
Order By PercentPopulationInfected desc

-- Total Death Count per Country

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By location, population
Order By TotalDeathCount desc

-- Total Death Count per Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group By location
Order By TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
Order By 1, 2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
Order By 1, 2


-- CovidVaccination Queries

--Total Population vs Vaccinated Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- CTE Incorporation

With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
From PopvsVac

Create View PopvsVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

-- Temp Table Incorporation

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View