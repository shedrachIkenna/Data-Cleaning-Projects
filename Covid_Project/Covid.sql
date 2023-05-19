---------------------------------------------
--Selects everything from CovidDeaths table 
---------------------------------------------
Select *
From PortfolioProject..CovidDeaths

--------------------------------------------------------------------------------
--Total Cases vs Total Deaths 
-- Shows the Death percentage based on the total cases from CovidDeaths table 
--------------------------------------------------------------------------------
Select Location, date, total_cases, total_deaths, Convert(Decimal(18, 3), (Convert(Decimal(18, 5), total_deaths)/ Convert(Decimal(18,5), total_cases))) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is NOT NULL
order by 1,2

--------------------------------------------------------------------------------------------------------------------------
-- Total Cases vs Population
-- Shows what percentage of the population has covid based on the population and Total cases Using the CovidDeaths table 
--------------------------------------------------------------------------------------------------------------------------
Select Location, date, total_cases, population, Convert(Decimal(18, 5), (Convert(Decimal(18, 8), total_cases)/ population)) * 100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

---------------------------------------------------------------------------------------------------------------
-- Shows the highest countries with highest infection rate compared to population using the CovidDeaths table 
---------------------------------------------------------------------------------------------------------------
Select Location, Population, Max(cast(total_cases as int)) as HighestInfectionCount, Max(Convert(Decimal(18, 8), (Cast(total_cases as int))/ population)) * 100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
order by PercentageOfPopulationInfected DESC

------------------------------------------------------------------------------------------
--Shows the Total Death count based on the Location-Country using the CovidDeaths table 
------------------------------------------------------------------------------------------
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is NOT NULL
Group by Location
order by TotalDeathCount DESC

------------------------------------------------------------------------
--Breaking things down by Continent
--Shows the Total Death Count by Continent using the CovidDeath Table
------------------------------------------------------------------------
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is NULL
Group by Location
order by TotalDeathCount DESC

--------------------------------------------------------------------------------------------------
-- Global Numbers
-- Shows the GlobalTotalCasesPerDay, GlobalTotalDeathsPerDay and the GlobalDeathPercentagePerDay
--------------------------------------------------------------------------------------------------
Select date, 
sum(cast(total_cases as int)) as GlobalTotalCasesPerDay, 
sum(cast(total_deaths as int)) as GlobalTotalDeathsPerDay,
(sum(cast(total_deaths as decimal))/ sum(cast(total_cases as decimal))) * 100 as GlobalDeathPercentagePerDay
From PortfolioProject..CovidDeaths
Where Continent is NOT NULL
Group by date
order by 1,2

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Join Covid deaths and Covid Vaccinations tables 
-- Displays each Continent,
-- Each country(Location) in the Continent,
-- Date for each records 
-- new vaccination data for each particular day, NULL if zero
-- Cummulatively adds each day's new vaccinations data to the previous day's vaccination data and gives the output in the TotalVaccinationCount aliase column
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfPeopleVaccinated
--(RollingCountOfPeopleVaccinated/population)*100 
--This wouldn't work because we just created that RollingCountOfPeopleVaccinated column and we can use it in the same query 
--To solve this, we use a CTE or Temp-table
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is Not Null and dea.location like '%albania%'
Order by 2,3

---------------------------------------------------------------------------------------------------------
-- Using a CTE
-- To get the RollingPercentageCountOfPeopleVaccinated using (RollingCountOfPeopleVaccinated/Population)*100
---------------------------------------------------------------------------------------------------------
With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingCountOfPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfPeopleVaccinated
--(RollingCountOfPeopleVaccinated/population)*100 
--This wouldn't work because we just created that RollingCountOfPeopleVaccinated column and we can use it in the same query 
--To solve this, we use a CTE or Temp-table
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is Not Null and dea.location like '%albania%'
--Order by 2,3
)
Select *, (RollingCountOfPeopleVaccinated/Population) * 100 as RollingPercentageCountOfPeopleVaccinated
From PopVsVac

--------------------------------------------------------------------------------------------------------------
-- Using a Temp Table 
--To get the RollingPercentageCountOfPeopleVaccinated using (RollingCountOfPeopleVaccinated/Population)*100
-- This is an alternative approach to using a CTE
--------------------------------------------------------------------------------------------------------------
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingCountOfPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfPeopleVaccinated
--(RollingCountOfPeopleVaccinated/population)*100 
--This wouldn't work because we just created that RollingCountOfPeopleVaccinated column and we can use it in the same query 
--To solve this, we use a CTE or Temp-table
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is Not Null --and dea.location like '%albania%'
--Order by 2,3
Select *, (RollingCountOfPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

-------------------------------------------------------------------------------------------------------------------------------
--This query does the same thing as the above query in a more direct way
-- Not done with this query
-------------------------------------------------------------------------------------------------------------------------------
Select dea.continent, dea.date, vac.location, dea.population, vac.new_vaccinations, vac.total_vaccinations --Max(vac.total_vaccinations) as TotalMaxVaccinationsForEachCountry
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is Not null and dea.location like '%albania%'
Group by vac.location, dea.continent, dea.population, dea.date, vac.total_vaccinations, vac.new_vaccinations
Order by 2,1

-----------------------------------------------------------
-- Create a view to store data for later visualization
-----------------------------------------------------------
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is Not Null 
--Order by 2,3

-- Pushed Covid Dataset
