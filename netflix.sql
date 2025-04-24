--project on netflix
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	    show_id	VARCHAR(6) ,
	    typess	VARCHAR(10),
	    title   VARCHAR(150),
	    director	VARCHAR(208),	
	    casts		VARCHAR(1000),
	    country	  VARCHAR(150),
	    date_added	VARCHAR(50)	,
	    release_year INT,
	    rating		VARCHAR(10),
	    duration		VARCHAR(15),
	    listed_in		VARCHAR(100),
	    description	VARCHAR(250)

);

SELECT * FROM netflix

COPY netflix (show_id,typess,title,director,casts,country,date_added,release_year,rating,duration,listed_in,description
)
FROM'C:\Users\tanya\OneDrive\Desktop\netflix.csv'
WITH CSV HEADER;
copy netflix FROM 'D:\arduino\Arduino IDE\netflix.csv' WITH (FORMAT csv, HEADER true);
SELECT * FROM netflix
--to find total entries in data
SELECT 
count(*) as total_content 
FROM netflix;
--to find count of different type of content
SELECT 
count(distinct typess)
FROM netflix;

SELECT
count(*) as total_content 
FROM netflix;

--business problems and solutions

--count the no of movies vs tv shows
SELECT 
typess,
count(*) as total_content 
FROM netflix
GROUP BY typess;

--Find the Most Common Rating for Movies and TV Shows
with t1 as(
select typess,
rating,
count(*),
RANK()OVER(PARTITION BY typess order by count(*)desc) as ranking
from netflix
group by 1,2)
select typess,rating
from t1
where ranking=1;
--order by 1,3 DESC

select * from netflix;

--List All Movies Released in a Specific Year (e.g., 2020)

select * from netflix 
where
typess = 'Movie'
and 
release_year = 2020;

-- find top 5 countries with the most content on netflix
select 
country,
count(show_id)as total_content
from netflix
group by 1;

select
unnest(string_to_array(country,','))as new_country
from netflix;

select 
unnest(string_to_array(country,','))as new_country,
count(show_id)as total_content
from netflix
group by 1
order by 2 desc
limit 5;

--identify the longest movie
select * from netflix 
where
typess = 'Movie'
and 
duration=(select max(duration) from netflix)
;
--find content added in last 5 years

select *
from netflix
where 
to_date(date_added,'Month DD,YYYY')>=current_date -interval'5 years'
;
--all movies/tv show by director 'Rajiv Chilaka'
select *
from netflix
where 
director ilike'%Rajiv Chilaka%'
;
--list tv shows with more than 5 seasons
select *
from netflix
where 
typess='TV Show'
and
split_part(duration,' ',1)::numeric>5
;
--count number of content in each genre

select 
unnest(string_to_array(listed_in,','))as genre,
count(show_id) as total_content
from netflix
group by 1
;
--Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release
select
extract (year from to_date(date_added, 'Month DD,YYYY'))as year,
count(*)as yearly_content,
round(
count(*)::numeric/(select count(*)from netflix where country='India')::numeric * 100,2)
as avg_content_per_year
from netflix
where country='India'
group by 1
order by 2 desc
limit 5
;
--list all movies that are documentaries

select *
from netflix
where 
listed_in ilike'%Documentaries%'
;
--find all content without a director

select *
from netflix
where 
director is NULL
;
--find how many movies actor 'salman khan' appeared in last 10 years!

select *
from netflix
where 
casts ilike'%Salman Khan%'
and
release_year>=extract(year from current_date) -10 
;
-- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select 
unnest(string_to_array(casts,','))as actors,
count(*) as total_content
from netflix
where country ilike '%India%'
group by 1
order by 2 desc
limit 10
;
--Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
--Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise
--Count the number of items in each category

with new_table as
(select * ,
case
when
description ilike '%kill%' or
description ilike '%violence%'
then 'Bad_Content'
else 'Good_Content'
end as category
from netflix
)
select 
category,
count(*) as total_content
from new_table
group by 1
