Create Database world_population;
-- Choose the database world_population
Use world_population;

CREATE TABLE world_population1 (
    `rank` INT,
    cca3 CHAR(3),
    country VARCHAR(100) NOT NULL,
    capital VARCHAR(100),
    continent VARCHAR(50),
    population_2022 BIGINT,
    population_2020 BIGINT,
    population_2015 BIGINT,
    population_2010 BIGINT,
    population_2000 BIGINT,
    population_1990 BIGINT,
    population_1980 BIGINT,
    population_1970 BIGINT,
    area_km2 DECIMAL(12, 1),
    density_per_km2 DECIMAL(10, 4),
    growth_rate DECIMAL(8, 4),
    world_pop_percentage DECIMAL(5, 2),
    PRIMARY KEY (cca3)
);
-- Display the information in the table
select * from world_population1;
-- check for the description of the table
DESCRIBE world_population1;

-- Rename the Columns
ALTER TABLE world_population1 CHANGE `World_Pop_Percentage`  `world_population_percentage` double;

ALTER TABLE world_population1 CHANGE `Area_km2`  `area` int;

ALTER TABLE world_population1 CHANGE `Country`  `country` varchar (100);

ALTER TABLE world_population1 CHANGE `Growth_Rate`  `growth_rate` double;

ALTER TABLE world_population1 CHANGE `Density_per_km2`  `pop_density` double;

-- Find the country, capital city and continent from the table
SELECT country, capital, continent
FROM world_population1
WHERE continent IS NOT NULL
ORDER BY country DESC;

-- Find the distinct countries
SELECT DISTINCT COUNT(country)
FROM world_population1
WHERE country IS NOT NULL;
    
-- Find the distinct continents
SELECT DISTINCT COUNT(continent)
FROM world_population1
WHERE continent IS NOT NULL;

-- Find the average population of each continent in 2022
SELECT continent , ROUND(AVG(population_2022),2) AS Avg_Population
FROM world_population1
GROUP BY continent
ORDER BY continent DESC;

-- Find the highest and lowest population in 2022
SELECT MAX(population_2022) AS Max_Population,
MIN(population_2022) AS Min_Population
FROM world_population1;

-- Find the countries with the highest and lowest population in 1970
(
  SELECT Country, population_1970
  FROM world_population1
  ORDER BY population_1970 DESC
  LIMIT 1
)
UNION
(
  SELECT Country, population_1970
  FROM world_population1
  ORDER BY population_1970 ASC
  LIMIT 1
);

--  Find the population of North America with a capital city called The Valley in the year 2022
SELECT Population_2022 FROM world_population1 
WHERE Continent = 'North America'
AND Capital = 'The Valley' ;

-- Find the top 10  populated countries in 2015 
SELECT Country, Population_2015 FROM world_population1
ORDER BY Population_2015 DESC 
LIMIT 10;

-- Find the countries whose total population is greater than the average population
SELECT Country, Population_2022 AS Total_Population
FROM world_population1
WHERE Population_2022 >
(SELECT ROUND(AVG(population_2022)) FROM world_population1) 
ORDER BY Total_Population DESC ;

-- What number of countries will have a population less than the country with the highest population in 2022?
SELECT COUNT(population_2022)
FROM world_population1
WHERE population_2022 < (SELECT MAX(POPULATION_2022) FROM world_population1);

-- What is the rank and dense rank of the population in 2015?
SELECT country, population_2015,
RANK() OVER (ORDER BY population_2015 DESC) AS `RANK`,
DENSE_RANK() OVER (ORDER BY population_2015 DESC) AS `DENSE_RANK`
FROM world_population1 LIMIT 10;

-- What is the fastest and slowest rate of population growth?
(SELECT country, growth_rate, 'Max Growth' AS label
FROM world_population1
ORDER BY growth_rate DESC
LIMIT 1)
UNION ALL
(SELECT country, growth_rate, 'Min Growth' AS label
FROM world_population1
ORDER BY growth_rate ASC
LIMIT 1);
--  What is the largest and smallest area?
SELECT MAX(area) AS max_area, 
MIN(area) AS min_area
FROM world_population1; 

-- Create a new field for area sizes, and return the country, continent, country code, and area. Order them in descending order.
SELECT country, continent, cca3, `area` , 
CASE WHEN area > 2000000
		THEN 'large'
	WHEN area > 40000
		THEN 'medium'
	ELSE 'small' 
END AS area_size FROM world_population1;