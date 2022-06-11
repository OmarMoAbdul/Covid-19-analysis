Select location,date,total_cases,new_cases,total_deaths,population
From portifolio..CovidDeaths
order by 1,2

-- Total_cases VS Total_Deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deaths_Percentage
From portifolio..CovidDeaths
order by 1,2

-- The relation between location and Dying affected by covid 

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deaths_Percentage
From portifolio..CovidDeaths
where location = 'canada'
order by 1,2

-- How does the population got affected by covid infection

Select location,date,total_cases,population,total_deaths,(total_cases/population)*100 as Infection_rate
From portifolio..CovidDeaths
where location = 'canada'
order by 1,2

-- What is the highest infection rates compared to population 

Select location,population,MAX(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as Infection_rate
From portifolio..CovidDeaths
--where location = 'canada'
GROUP BY location,population
order by Infection_rate DESC

Select location,population,date,MAX(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as Infection_rate
From portifolio..CovidDeaths
--where location = 'canada'
GROUP BY location,population,date
order by Infection_rate DESC



--What is the deaths count compared to population

Select location,population,MAX(cast(total_deaths as int)) as HighestDeathsCount
From portifolio..CovidDeaths
where continent is not  null
GROUP BY location,population
order by HighestDeathsCount DESC


--What is the deaths rate compared to population

Select location,MAX(cast(total_deaths as int)) as HighestDeathsCount
From portifolio..CovidDeaths
where continent is null
GROUP BY location,population
order by HighestDeathsCount DESC

-- Excluding unwanted sections for  visualization

Select location,MAX(cast(total_deaths as int)) as HighestDeathsCount
From portifolio..CovidDeaths
where continent is null
and location not in ('World','Upper middle income','High income','Lower middle income','European Union','Low income','International')
GROUP BY location,population
order by HighestDeathsCount DESC


--Global records

Select date,SUM(new_cases) as total_Worldcases,SUM(CAST(new_deaths as int)) as total_Worldeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From portifolio..CovidDeaths
where continent is not  null
GROUP BY date
order by 1,2

Select SUM(new_cases) as total_Worldcases,SUM(CAST(new_deaths as int)) as total_Worldeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From portifolio..CovidDeaths
where continent is not  null
--GROUP BY date
order by 1,2

--Population VS Vaccinations
WITH PopvsVac( continent,Location,date,Population,new_vaccinations,Total_vaccinations)
as
(
SELECT D.continent,D.Location,D.date,D.Population,V.new_vaccinations,
SUM(CONVERT(bigint,V.new_vaccinations)) OVER (partition by D.Location order by D.location,D.Date) AS Total_vaccinations
FROM portifolio..CovidDeaths D
join portifolio..CovidVaccinations V
  ON D.location = V.location
  and D.date = V.date
  WHERE D.continent is not null
  --ORDER BY 2,3
 )

 SELECT*,(Total_vaccinations/Population)*100 AS Vaccinations_Percentage
 FROM PopvsVac

 --Creating views for visualizations

 CREATE view vaccinationsPercentage as
 WITH PopvsVac( continent,Location,date,Population,new_vaccinations,Total_vaccinations)
as
(
SELECT D.continent,D.Location,D.date,D.Population,V.new_vaccinations,
SUM(CONVERT(bigint,V.new_vaccinations)) OVER (partition by D.Location order by D.location,D.Date) AS Total_vaccinations
FROM portifolio..CovidDeaths D
join portifolio..CovidVaccinations V
  ON D.location = V.location
  and D.date = V.date
  WHERE D.continent is not null
  --ORDER BY 2,3
 )

 SELECT*,(Total_vaccinations/Population)*100 AS Vaccinations_Percentage
 FROM PopvsVac

 CREATE VIEW deathsPercentage as
 Select date,SUM(new_cases) as total_Worldcases,SUM(CAST(new_deaths as int)) as total_Worldeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From portifolio..CovidDeaths
where continent is not  null
GROUP BY date
--order by 1,2

SELECT*
FROM deathsPercentage


CREATE VIEW continentDeathscount as
Select location,MAX(cast(total_deaths as int)) as HighestDeathsCount
From portifolio..CovidDeaths
where continent is null
GROUP BY location,population
--order by HighestDeathsCount DESC

SELECT *
FROM continentDeathscount


CREATE VIEW locationDeathscount as
Select location,population,MAX(cast(total_deaths as int)) as HighestDeathsCount
From portifolio..CovidDeaths
where continent is not  null
GROUP BY location,population
--order by HighestDeathsCount DESC


SELECT * 
FROM locationDeathscount


CREATE VIEW locationInfectionrate as 
Select location,population,MAX(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as Infection_rate
From portifolio..CovidDeaths
--where location = 'canada'
GROUP BY location,population
--order by Infection_rate DESC

SELECT * 
FROM locationInfectionrate