/*
ANALYST: FOLASHADE OLAITAN

GLOBAL COVID-19 DATA EXPLORATION

Skills Used: JOINS, CTE, TEMP TABLE, AGGREGATE FUNCTIONS, CONVERTING DATA TYPES

Data: The dataset is from https://ourworldindata.org/covid-deaths. It has data from January 2020 to March 2023. 

Task: The goal of this project is to explore 2020-2022 COVID-19 Data by asking and answering data exploration questions. 
I explored data globally, continentally and country-wise focusing on the African countries.
*/



---Viewing the datasets

SELECT * 
FROM CovidAnalysis.dbo.Deaths$
ORDER BY 3,4


SELECT * 
FROM CovidAnalysis..Vaccinations$
ORDER BY  3,4



--------------------------------------------------------GLOBAL ANALYSIS-------------------------------------------------

-----What percentage of the world's population had covid?
SELECT SUM(population)AS World_Population, 
		SUM(new_cases) AS Total_Cases, 
		ROUND((SUM(new_cases)/SUM(population))*100, 3) AS Percentage_Infected
FROM CovidAnalysis..Deaths$
WHERE continent is not null
ORDER BY Percentage_Infected DESC

---INSIGHT:: Approximately 0.01% of the total world population got infected by the COVID-19 virus 
---from January 2020 until March 15, 2023




----What is the world's total confirmed cases, total deaths and what proportion of the infected cases DIED?
SELECT SUM(new_cases) AS GlobalConfirmedCases, 
		SUM(CAST(new_deaths AS INT)) AS GlobalConfirmedDeaths,
		SUM(new_cases)- SUM(CAST(new_deaths AS INT)) AS ConfirmedSurvivors,
		ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases)) * 100,3) AS DeathRate
FROM CovidAnalysis..Deaths$
WHERE continent is not null
ORDER BY DeathRate

---INSIGHT:: The total confirmed cases worldwide is about 760million cases as of March 15, 2023.
---with almost 6.9million deaths which is 0.90% of the total confirmed cases.




----How many people in the whole world have been vaccinated? Fully vaccinated? and gotten a booster dose?
---What % of the global population has gotten at least a dose of vaccine?
SELECT 
		SUM(CAST(vac.new_vaccinations AS BIGINT)) AS Total_Vaccinations,
		MAX(CAST(vac.people_vaccinated AS BIGINT)) AS People_Vaccinated_Atleast_Once,
		MAX(CAST(vac.people_fully_vaccinated AS BIGINT)) AS FullyVaccinated,
		(SUM(CAST(vac.new_vaccinations AS BIGINT))/SUM(dea.population))*100 AS global_vacc_percentage,
		MAX(CAST(vac.total_boosters AS BIGINT)) AS People_Boosted	
FROM CovidAnalysis..Vaccinations$ vac
JOIN CovidAnalysis..Deaths$ dea
	ON dea.continent = vac.continent
WHERE dea.continent is not null

---INSIGHT:: As of March 15, 2023 10,849,394,955 total vaccines have been administered worldwide 
---out of which only 1,276,760,000 have been fully vaccinated and 826,913,000 have gotten a boosted dose.




--------------------------------------------------------CONTINENTAL ANALYSIS-------------------------------------------------
---What continent has the highest death count and rate?
SELECT continent AS Continent, SUM(new_cases) AS ConfirmedCases, 
		SUM(CAST(new_deaths AS INT)) AS ConfirmedDeaths,
		ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100,2) AS DeathRate
FROM CovidAnalysis..Deaths$
WHERE continent is not null
GROUP BY continent
ORDER BY DeathRate DESC

---INSIGHT:: Asia recorded the highest confirmed COVID-19 cases from January 2020 up until March 15, 2023. 
---However, the highest death rate was recorded in South America with approximately 1.99% of the people infected died.
---Oceania has the lowest death rate even though their recorded confirmed cases was a little higher than Africa’s




/* Which continents have the highest vaccination count? */
SELECT continent AS Continent, 
		SUM(CAST(new_vaccinations AS BIGINT)) AS Total_Vaccinations_Administered, 
		MAX(CAST(people_fully_vaccinated AS BIGINT)) AS Fully_Vaccinated
FROM CovidAnalysis..Vaccinations$
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Vaccinations_Administered DESC

---INSIGHT:: Asia has the highest vaccination counts with total vaccinations of 7,546,077,630 as of March 15, 2023. 
---This is not surprising because they have recorded a low death rate even though they have the highest number of confirmed cases.




---What percentage of each continent' population have been vaccinated
SELECT vac.continent AS Continent, SUM(dea.population),
		MAX(CAST(vac.total_vaccinations AS BIGINT)) AS Total_Vaccinations,
		ROUND((MAX(CAST(vac.total_vaccinations AS BIGINT)) / SUM(dea.population)) *100, 2) AS Percentage_Population_Vaccinated
FROM CovidAnalysis..Vaccinations$ vac
JOIN CovidAnalysis..Deaths$ dea
	on vac.continent = dea.continent
WHERE vac.continent is not null
GROUP BY vac.continent
--ORDER BY vac.continent 





---Death counts by continent overtime (2020-2022)
---Total deaths per continent in 2020
DROP TABLE IF EXISTS #ContinentalDeaths2020
SELECT continent AS Continent, SUM(new_deaths) AS TotalDeaths_2020
INTO #ContinentalDeaths2020
FROM CovidAnalysis..Deaths$
WHERE continent is not null and datepart(year from date) like '%2020%'
GROUP BY continent
ORDER BY TotalDeaths_2020 DESC


---Total deaths per continent in 2021
DROP TABLE IF EXISTS #ContinentalDeaths2021
SELECT continent AS Continent, 
		SUM(new_deaths) AS TotalDeaths_2021
INTO #ContinentalDeaths2021
FROM CovidAnalysis..Deaths$
WHERE continent is not null and datepart(year from date) like '%2021%'
GROUP BY continent
ORDER BY TotalDeaths_2021 DESC


---Total deaths per continent in 2022
DROP TABLE IF EXISTS #ContinentalDeaths2022
SELECT continent AS Continent, 
		SUM(new_deaths) AS TotalDeaths_2022
INTO #ContinentalDeaths2022
FROM CovidAnalysis..Deaths$
WHERE continent is not null and datepart(year from date) like '%2022%'
GROUP BY continent
ORDER BY TotalDeaths_2022 DESC


---Administered Vaccination counts by continent overtime (2020-2022)
---Total vaccinations per continent in 2020
DROP TABLE IF EXISTS #ContinentalVaccines2020
SELECT continent AS Continent, SUM(CAST(new_vaccinations AS BIGINT)) AS Total_Administered_Vaccines_2020
INTO #ContinentalVaccines2020
FROM CovidAnalysis..Vaccinations$
WHERE continent is not null and datepart(year from date) like '%2020%'
GROUP BY continent
ORDER BY Total_Administered_Vaccines_2020 DESC


---Total vaccinations per continent in 2021
DROP TABLE IF EXISTS #ContinentalVaccines2021
SELECT continent AS Continent, SUM(CAST(new_vaccinations AS BIGINT)) AS Total_Administered_Vaccines_2021
INTO #ContinentalVaccines2021
FROM CovidAnalysis..Vaccinations$
WHERE continent is not null and new_vaccinations is not null and datepart(year from date) like '%2021%'
GROUP BY continent
ORDER BY Total_Administered_Vaccines_2021 DESC

---Total vaccinations per continent in 2022
DROP TABLE IF EXISTS #ContinentalVaccines2022
SELECT continent AS Continent, SUM(CAST(new_vaccinations AS BIGINT)) AS Total_Administered_Vaccines_2022
INTO #ContinentalVaccines2022
FROM CovidAnalysis..Vaccinations$
WHERE continent is not null and datepart(year from date) like '%2022%'
GROUP BY continent
ORDER BY Total_Administered_Vaccines_2022 DESC


---See death counts overtime (2020-2022)
SELECT  CD2020.Continent, CD2020.TotalDeaths_2020, CD2021.TotalDeaths_2021,
		ROUND(((CD2021.TotalDeaths_2021 - CD2020.TotalDeaths_2020)/CD2020.TotalDeaths_2020)*100,2) AS Percentage_Change_Btw_2020_and_2021,
		CD2022.TotalDeaths_2022,
		ROUND(((CD2022.TotalDeaths_2022 - CD2021.TotalDeaths_2021)/CD2021.TotalDeaths_2021)*100,2) AS Percentage_Change_Btw_2021_and_2022
FROM #ContinentalDeaths2020 CD2020
JOIN #ContinentalDeaths2021 CD2021
	ON CD2020.Continent = CD2021.Continent
JOIN #ContinentalDeaths2022 CD2022
	ON CD2020.Continent = CD2022.Continent
ORDER BY CD2020.Continent


---See vaccination counts and change overtime (2020-2022)
SELECT  CV2020.Continent, CV2020.Total_Administered_Vaccines_2020, CV2021.Total_Administered_Vaccines_2021,
		ROUND(((CV2021.Total_Administered_Vaccines_2021 - CV2020.Total_Administered_Vaccines_2020)/CV2020.Total_Administered_Vaccines_2020)*100,5) AS Percentage_Change_Btw_2020_and_2021,
		CV2022.Total_Administered_Vaccines_2022,
		ROUND(((CV2022.Total_Administered_Vaccines_2022 - CV2021.Total_Administered_Vaccines_2021)/CV2021.Total_Administered_Vaccines_2021)*100,5) AS Percentage_Change_Btw_2021_and_2022
FROM #ContinentalVaccines2020 CV2020
JOIN #ContinentalVaccines2021 CV2021
	ON CV2020.Continent = CV2021.Continent
JOIN #ContinentalVaccines2022 CV2022
	ON CV2020.Continent = CV2022.Continent
ORDER BY CV2020.Continent












--------------------------------------------------------COUNTRY-WISE ANALYSIS (AFRICAN COUNTRIES)-------------------------------------------------

---1. Top 5 African countries with the highest recorded cases and death rate. What % do they make of the total Africa confirmed cases?
	
	--- Top 5 African countries by confirmed cases
		SELECT TOP 5 location AS Country, 
		SUM(new_cases) AS Total_Confirmed_Cases, 
		SUM(new_deaths) AS Confirmed_Deaths,
		ROUND((SUM(new_deaths)/SUM(new_cases)) * 100, 2) AS Death_Rate
		FROM CovidAnalysis..Deaths$ dea
		WHERE continent ='Africa'
		GROUP BY location
		ORDER BY Total_Confirmed_Cases DESC

		--- Top 5 African countries by death rate
		SELECT TOP 5 location AS Country, 
		SUM(new_cases) AS Total_Confirmed_Cases, 
		SUM(new_deaths) AS Confirmed_Deaths,
		ROUND((SUM(new_deaths)/SUM(new_cases)) * 100, 2) AS Death_Rate
		FROM CovidAnalysis..Deaths$ dea
		WHERE continent ='Africa'
		GROUP BY location
		ORDER BY Death_Rate DESC


DROP TABLE IF EXISTS #Africa
SELECT continent as continent, SUM(new_cases) as Africa_Confirmed_Cases
INTO #Africa 
FROM CovidAnalysis..Deaths$
WHERE continent = 'Africa' 
GROUP BY continent

----Top 5 major contributing countries to Africa's number of confirmed cases
SELECT TOP 5 dea.location AS Country, 
		SUM(dea.new_cases) AS Total_Confirmed_Cases, 
		SUM(dea.new_deaths) AS Confirmed_Deaths,
		ROUND((SUM(dea.new_deaths)/SUM(dea.new_cases)) * 100, 2) AS Death_Rate,
		Africa_Confirmed_Cases,
		ROUND((SUM(dea.new_cases) / afr.Africa_Confirmed_Cases) *100, 2) AS Percentage_Case_Contribution_to_Africa
FROM CovidAnalysis..Deaths$ dea
JOIN #Africa afr
	ON dea.continent = afr.continent
WHERE dea.continent = 'Africa' 
GROUP BY location, Africa_Confirmed_Cases
ORDER BY Percentage_Case_Contribution_to_Africa DESC



---2.	What is the vaccination rate of each African country? This is the percentage of the population that has gotten ATLEAST one dose of vaccine.
WITH Vaccinations AS (
	SELECT 
		location AS Country,
		SUM(CAST(new_vaccinations AS BIGINT)) AS Total_Vaccinations
	FROM 
		CovidAnalysis..Vaccinations$
	WHERE 
		continent = 'Africa'
	GROUP BY 
		location
),
Populations AS (
	SELECT 
		location AS Country,
		population
	FROM 
		CovidAnalysis..Deaths$
	WHERE 
		continent = 'Africa'
	GROUP BY location, population
)
SELECT 
	v.Country,
	v.Total_Vaccinations,
	ROUND((CAST(v.Total_Vaccinations AS FLOAT) / p.population) * 100, 2) AS Vaccination_Rate
FROM 
	Vaccinations v
	JOIN Populations p ON v.Country = p.Country
GROUP BY v.Country, v.Total_Vaccinations, p.population
ORDER BY 
	Vaccination_Rate DESC

----INSIGHT:: Morocco, Tunisia, Zimbabwe are the 3 countries with over 50% of their populations vaccinated.
----While Seychelle and South AFrica have over 30% already vaccinated. This is evident in their death rates 
----as they have been able to manage the impact of the virus to an extent




----What % of each countries population had COVID? What % died of COVID and what % have been vaccinated?
WITH Vaccinations AS (
	SELECT 
		location AS Country,
		SUM(CAST(new_vaccinations AS BIGINT)) AS Total_Vaccinations
	FROM 
		CovidAnalysis..Vaccinations$
	WHERE 
		continent = 'Africa'
	GROUP BY 
		location
),
Populations AS (
	SELECT 
		location AS Country,
		SUM(new_cases) AS Total_Cases,
		SUM(new_deaths) AS Total_Deaths,
		MAX(population) AS population
	FROM 
		CovidAnalysis..Deaths$
	WHERE 
		continent = 'Africa'
	GROUP BY 
		location
)
SELECT 
	v.Country,
	p.population,
	p.Total_Cases,
	v.Total_Vaccinations,
	p.Total_Deaths,
	ROUND((CAST(p.Total_Cases AS FLOAT) / p.population) * 100, 2) AS had_COVID,
	ROUND((CAST(p.Total_Deaths AS FLOAT) / p.population) * 100, 2) AS Died_of_COVID,
	ROUND((CAST(v.Total_Vaccinations AS FLOAT) / p.population) * 100, 2) AS Pop_Vaccinated
FROM 
	Vaccinations v
	JOIN Populations p ON v.Country = p.Country
WHERE 
	p.population > 0 AND v.Total_Vaccinations > 0
ORDER BY 
	had_COVID DESC, Died_of_COVID DESC, Pop_Vaccinated DESC




---What is the average life expectancy of each country? Which 3 countries have the highest life expectancy and how does this compare to their death rate?
SELECT 
    d.location AS Country,
    AVG(CAST(v.life_expectancy AS FLOAT)) AS Average_Life_Expectancy,
    SUM(CAST(d.new_deaths AS BIGINT)) AS Total_Deaths,
    ROUND(SUM(CAST(d.new_deaths AS FLOAT)) / SUM(CAST(d.new_cases AS FLOAT)) * 100, 2) AS Death_Rate
FROM 
    CovidAnalysis..Deaths$ d
    JOIN CovidAnalysis..Vaccinations$ v ON d.location = v.location
WHERE 
    d.continent = 'Africa' 
GROUP BY 
    d.location
ORDER BY 
    Average_Life_Expectancy DESC, Death_Rate DESC

---INSIGHT:: A higher life expectancy and low death rate mean the country has a good healthcare system in place.




---What demographic and health related factors have contributed to a country's COVID-19 outcomes. 
---For example, countries with higher median ages or higher rates of diabetes may be at higher risk for severe outcomes
SELECT 
    d.location AS Country,
    v.median_age AS Median_Age,
    v.diabetes_prevalence AS Diabetes_Prevalence,
    d.total_cases AS Total_Cases,
    d.total_deaths AS Total_Deaths,
    v.total_tests AS Total_Tests,
    v.total_vaccinations AS Total_Vaccinations
FROM 
    CovidAnalysis..Deaths$ d
JOIN
    CovidAnalysis..Vaccinations$ v
ON 
    d.location = v.location
WHERE d.continent = 'Africa'
GROUP BY d.location,  v.median_age, v.diabetes_prevalence,d.total_cases,d.total_deaths,v.total_tests,v.total_vaccinations
ORDER BY 
    Median_Age DESC, Diabetes_Prevalence DESC



---The reproduction rate data can provide insights into the rate at which the virus is spreading in different countries. 
---A reproduction rate above 1 indicates that the virus is spreading rapidly, while a rate below 1 suggests that the virus is being contained.
SELECT 
    location AS Country, population AS Population,
	ROUND((SUM(new_cases)/population) * 100,2) AS Perc_Pop_With_COVID,
    MAX(CAST(reproduction_rate AS FLOAT)) AS Reproduction_Rate,
    SUM(new_cases) AS Confirmed_Cases
FROM 
    CovidAnalysis..Deaths$
WHERE continent= 'Africa'
GROUP BY location,population
ORDER BY 
	Reproduction_Rate DESC,
    Perc_Pop_With_COVID DESC, 
    Confirmed_Cases DESC;
