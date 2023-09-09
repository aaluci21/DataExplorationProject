--Select Data That We Will Be Exploring

Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_Portfolio_Project.dbo.CovidDeaths$
Order By 1,2

--Looking at Total Cases Vs. Total Deaths

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Covid_Portfolio_Project.dbo.CovidDeaths$ 
Order By 1,2
--This query shows the percentage of getting Covid and your chances of dying from it.

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Covid_Portfolio_Project.dbo.CovidDeaths$ 
--Where Location LIKE '%states%'
Order By 1,2

--Looking at the total cases vs. population

Select Location, date, population, total_cases,(total_cases/population)*100 as PercentageofPopulationInfected
From Covid_Portfolio_Project.dbo.CovidDeaths$ 
Order By 1,2
--this shows the percentage of the population who got covid

--Looking at Countries with the Highest Infection Rate Compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From Covid_Portfolio_Project.dbo.CovidDeaths$
--Where Location LIKE '%states%'
Group By Location, population
Order By PercentagePopulationInfected desc

--Showing Countries with The Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Portfolio_Project.dbo.CovidDeaths$
--Where Location LIKE '%states%'
Where continent is not Null
Group By Location
Order By TotalDeathCount desc
--This query shows the United States number 1 having the highest death rate

--Let's Break Things Down by Continent
	--Showing Continents with The Highest Death Count per Population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Portfolio_Project.dbo.CovidDeaths$
--Where Location LIKE '%states%'
Where continent is not Null
Group By continent
Order By TotalDeathCount desc
--This query does not show accurate numbers due to it not including Canada's numbers part of North America

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Portfolio_Project.dbo.CovidDeaths$
--Where Location LIKE '%states%'
Where continent is not Null
Group By location
Order By TotalDeathCount desc
--It's better to run it by location this way you can see every country's death count

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
	*100 as DeathPercentage
From Covid_Portfolio_Project.dbo.CovidDeaths$
--Where Location LIKE '%states%'
Where continent is not Null
Group By date
Order By 1,2
--this query shows results per day

--Looking at the total Population v. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where Location LIKE '%states%'
Where dea.continent is not Null
Order By 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
	Over(Partition by dea.location)
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where Location LIKE '%states%'
Where dea.continent is not Null
Order By 2,3
--this shows the sum of new vaccinations by the location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
	Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
Order By 2,3
--This query adds everytime someone get vaccinated 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
	Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
Order By 2,3

--Using CTE

With PopVsVac(Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
	Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order By 2,3
	)
Select*, (RollingPeopleVaccinated/population)*100
From PopVsVac


--Temp Table

Create Table #PercentagePopulationVaccinated
	(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
	Insert Into #PercentagePopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
	Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order By 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated

--Using the DROP TABLE IF EXISTS Statement

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
	(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
	Insert Into #PercentagePopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
	Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not Null
--Order By 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated

--Creating A View

Create View PercentagePopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
	Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid_Portfolio_Project.dbo.CovidDeaths$ dea
Join Covid_Portfolio_Project.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not Null
--Order By 2,3