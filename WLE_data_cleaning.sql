# World Life Expectancy (Data Cleaning)

use world_life_expectancy;

select *
from world_life_expectancy
;

-- find if there's duplicates 
select country, year, concat(country, year), count(concat(country, year))
from world_life_expectancy
group by country, year, concat(country, year)
having count(concat(country, year)) > 1
;


select *
from (
	select row_id, 
	concat(country, year),
	row_number() over( partition by concat(country, year) order by concat(country, year)) AS row_num
	from world_life_expectancy
    ) AS row_table
where row_num > 1
;

delete from world_life_expectancy
where 
	row_id IN (
    select row_id
from (
	select row_id, 
	concat(country, year),
	row_number() over( partition by concat(country, year) order by concat(country, year)) AS row_num
	from world_life_expectancy
    ) AS row_table
where row_num > 1
)
;


-- find blanks in Status column 
select *
from world_life_expectancy
where status = ''  
;


select distinct(status)
from world_life_expectancy
where status <> '' 
;

select distinct(country)
from world_life_expectancy
where status = 'developing' 
; 

update world_life_expectancy
set status = 'developing' 
where country IN (
		select distinct(country)
		from world_life_expectancy
		where status = 'developing'
) 
;

update world_life_expectancy t1
join world_life_expectancy t2
	ON t1.country = t2.country
set t1.status = 'developing' 
where t1.status = ''
AND t2.status <> '' 
AND t2.status = 'developing'
;


select *
from world_life_expectancy
where country = 'United States of America'
;

update world_life_expectancy t1
join world_life_expectancy t2
	ON t1.country = t2.country
set t1.status = 'Developed'
where t1.status = ''
AND t2.status <> '' 
AND t2.status = 'Developed'
;

-- find blank in life expectancy (LE)
select * 
from world_life_expectancy
where `Life expectancy` = ''
;

-- populate blank LE in Afghanistan  
select country, year, `Life expectancy`
from world_life_expectancy
# where `Life expectancy` = ''
;

select t1.country, t1.year, t1.`Life expectancy`,
	t2.country, t2.year, t2.`Life expectancy`,
    t3.country, t3.year, t3.`Life expectancy`,
   ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
from world_life_expectancy t1
join world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
join world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
where t1.`Life expectancy` = '' 
;


update world_life_expectancy t1
join world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
join world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
set t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
where t1.`Life expectancy` = ''
;