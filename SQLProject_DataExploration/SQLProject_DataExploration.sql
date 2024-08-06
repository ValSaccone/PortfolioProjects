--Select *
--From PortfolioProject..CovidDeaths
--order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

--Cuando el continente es null, en location aparece el continente.
Select *
From  PortfolioProject..CovidDeaths
Where continent is not null

-- Seleccionar datos a utilizar

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Cantidad de casos vs cantidad de muertes: Porcentaje de muertes

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1, 2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2

--Casos totales vs Poblacion

Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
order by 1, 2

Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2

--Paises con los indices de contagio más altos comparados con la población.

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasesPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location, population
Order by CasesPercentage Desc

-- Países con la mayor cantidad de muertes según la población.

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount desc

-- Ahora por continente: orden de continentes con la mayor cantidad de muertes según la población

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc

--El correcto es este por como está la tabla en excel. 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group By location
Order By TotalDeathCount desc

-- *** Números Globales ***

--Muertes en el mundo según la fecha

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

--Muertes en el mundo

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- ** CovidVaccinations **

Select *
from PortfolioProject..CovidVaccinations

-- ** Utilizamos ambas tablas **

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Población total vs vacunaciones
-- new_vaccinations son nuevas vacunas por día

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- sum suma de las nuevas vacunaciones particionadas por la localidad, ordenado por localidad y fecha.
-- SumPeopleVaccinated/population, queremos saber cuantas personas están vacunadas (pero no se puede utilizar una columna recien creada)
-- Usamos CTE

With PopVsVac (continent, location, date, population, new_vaccinations, SumPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location, dea.date) as SumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

Select *, (SumPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
from PopVsVac
order by PeopleVaccinatedPercentage

--Lo mismo pero con Temp table

Drop table if exists #PopulationVaccinatedPercentage
Create Table #PopulationVaccinatedPercentage
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	SumPeopleVaccinated numeric
)

Insert into #PopulationVaccinatedPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location, dea.date) as SumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (SumPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
from #PopulationVaccinatedPercentage


--*** Creo una view para guardar datos para futuras visualizaciones

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location, dea.date) as SumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
from PercentPopulationVaccinated
