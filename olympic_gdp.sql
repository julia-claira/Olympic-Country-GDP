--set up table
DROP TABLE summer

CREATE TABLE summer(
	id serial,
	year INT,
	city VARCHAR(40),
	sport VARCHAR(50),
	discipline VARCHAR(50),
	athlete VARCHAR(50),
	country VARCHAR(50),
	gender VARCHAR(7),
	event VARCHAR(50),
	medal VARCHAR(7)
)

--create table with ICO abbreviations
DROP TABLE country_ico

CREATE TABLE country_ico (
	id int,
	abbr VARCHAR (5),
	country VARCHAR (30)
)

--create GDP table
DROP TABLE gdp

CREATE TABLE gdp(
	id int,
	country VARCHAR (40),
	code VARCHAR(5),
	year FLOAT,
	value FLOAT,
	ioc VARCHAR(5),
	normalized_name VARCHAR (40)
)

--check medal count for USA women by country after 1960s
SELECT country,medal, COUNT(medal) FROM summer
WHERE year>=1960 and gender='Women' and country='USA'
GROUP By country,medal

--see if there are nulls in the country column
SELECT country FROM summer
WHERE country IS NULL

--delete rows where country is null
DELETE FROM summer
WHERE country IS NULL

--examine the countries in the list and a count
SELECT DISTINCT country, count(medal) OVER (PARTITION BY country) as medal_count
FROM summer
ORDER BY medal_count DESC

--normalize country codes to enable joining of GDP data
SELECT s.*,c.country FROM summer AS s
JOIN country_ico AS C
ON s.country=c.abbr

ALTER TABLE summer
ADD COLUMN full_country VARCHAR(30);

UPDATE summer
SET full_country=c.country
	FROM country_ico as c
	WHERE c.abbr=summer.country
	
	
--delete nulls in full_country associated with ZZX which stands for mixed teams
--as there is no way to associate GDP with a team comprised of more than one country
SELECT country, full_country,COUNT(medal)
FROM summer
WHERE full_country IS NULL
GROUP BY country,full_country

DELETE FROM summer
WHERE full_country IS NULL


--delete duplicate medals so team medals only add up to 1
WITH cte AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY year,country,gender,event,sport,discipline,medal) as duplicates
	FROM summer
)
SELECT * FROM cte
WHERE duplicates>1

SELECT * from summer

WITH cte AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY year,country,gender,event,sport,discipline,medal) as duplicates
	FROM summer
)
DELETE FROM summer 
WHERE id IN (
	SELECT s.id FROM summer as s
	JOIN cte as c
	ON c.id=s.id
	WHERE c.duplicates>1
)

--drop athlete column as I'm focusing on countries
ALTER TABLE summer
DROP COLUMN athlete


--change GDP year to integer to match data type of master
ALTER TABLE GDP
ADD COLUMN the_year INT


--Drop old year  column from GDP
ALTER TABLE GDP
DROP COLUMN year

--join GDP table with master
ALTER TABLE summer
ADD COLUMN gdp double precision

UPDATE summer
SET gdp=g.value
FROM gdp AS g
WHERE g.ioc=summer.country AND g.the_year=summer.year

--count nulls in data set after 1960
SELECT SUM(CASE WHEN gdp IS NULL THEN 1 ELSE 0 END) FROM summer
WHERE year>=1960

--find countries with no gdp data after 1960
SELECT DISTINCT(country) FROM SUMMER
WHERE year>=1960 AND gdp IS NULL

--drop years prior to 1960 as there is no gdp data for that time period
DELETE FROM summer
WHERE year <1960

--final table
SELECT * FROM summer_gdp

--create total medals table
CREATE TABLE medal_count AS (
SELECT full_country,COUNT(medal) FROM summer
WHERE year=2012
Group By full_country);

--add a medal count
WITH cte AS(
	SELECT *,
	COUNT(medal) OVER (PARTITION BY country,year) as medal_count
	FROM summer
)
SELECT DISTINCT country,year, medal_count
FROM CTE
ORDER BY country DESC ,year ASC
