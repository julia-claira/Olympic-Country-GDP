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



--delete duplicate medals so team medals only add up to 1

