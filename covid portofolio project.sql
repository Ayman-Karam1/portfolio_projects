select *
from covid_deaths
where continent is not null
order by 3,4


--select *
--from covid_Vaccinations
--order by 3,4

--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where continent is not null
order by 1,2


--looking at total cases vs total deaths

select location, date, total_cases, total_deaths,(convert(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 as death_percentage
from portofolio_project.dbo.covid_deaths
--where location = 'Egypt'
where continent is not null
order by 1,2



--looking at the total cases vs the population

select location, date, total_cases, population,(convert(float,total_cases)/NULLIF(convert(float,population),0))*100 as 'total_cases-percentage'
from portofolio_project.dbo.covid_deaths
--where location = 'Egypt'
where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population


select location,population, MAX(total_cases) as Highest_infection_count,max((convert(float,total_cases)/NULLIF(convert(float,population),0)))*100 as 'percent_population_infected'
from portofolio_project.dbo.covid_deaths
--where location = 'Egypt'
where continent is not null
group by location, population 
order by 4 desc



--showing the countries with the highest death count per population

select location, Max(cast(total_deaths as int)) as total_deaths_count 
from portofolio_project.dbo.covid_deaths
--where location = 'Egypt'
where continent is not null
group by location
order by 2 desc


--let's break things down by continent


--showing the continents with the highest death_count


select continent, SUM(cast(new_deaths as int)) as total_deaths_count 
from portofolio_project.dbo.covid_deaths
--where location = 'Egypt'
where continent is not  null
group by continent
order by 2 desc


--global numbers


select date, MAX(cast(total_cases as int)) as total_new_cases,MAX(cast(total_deaths as int)) as total_new_deaths --, MAX(cast(total_deaths as int))/MAX(cast(total_cases as int))*100 as daily_deaths_percentage
from portofolio_project.dbo.covid_deaths
--where location = 'Egypt'
--where continent is not null
group by date
order by 1,2


--looking at total population vs Vaccinations
 
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
 from portofolio_project.dbo.covid_deaths dea
 join portofolio_project.dbo.covid_vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
	 where dea.continent is not null
	 order by 2,3




	 --USE CTE



with popvsvac (continent, location, date, population, new_vaccinations ,Rolling_people_vaccinated)
as
	( 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
 from portofolio_project.dbo.covid_deaths dea
 join portofolio_project.dbo.covid_vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
	 where dea.continent is not null
	-- order by 2,3
	 )
	 select* ,(Rolling_people_vaccinated/population)*100 as the_vaccenated_people_percentage
	 from popvsvac
	 where location='Egypt'




	 --TEMP TABLE


	drop table if exists  #percent_population_Vaccinated
	 create table  #percent_population_Vaccinated
	 (
	 continent nvarchar(255),
	 location nvarchar(255),
	 date datetime,
	 population numeric,
	 new_vaccinations numeric,
	 Rolling_people_vaccinated numeric
	 )

	 
	 insert into  #percent_population_Vaccinated
	  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
 from portofolio_project.dbo.covid_deaths dea
 join portofolio_project.dbo.covid_vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
	-- where dea.continent is not null
	-- order by 2,3

	select*, (Rolling_people_vaccinated/population)*100 as the_vaccenated_people_percentage
	 from  #percent_population_Vaccinated
	 --where location='Egypt'




	 --creating view to store data for later visualization


	 create view percent_population_vaccinated 
	 as
	 	  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
 from portofolio_project.dbo.covid_deaths dea
 join portofolio_project.dbo.covid_vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
	 where dea.continent is not null
   --  order by 2,3

   select * 
   from percent_population_vaccinated
