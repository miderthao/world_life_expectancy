# World Life Expectancy Data Cleaning

This SQL script is designed to clean and update data in a table named world_life_expectancy. It addresses issues such as duplicates, blank values, and updates the 'Status' and 'Life Expectancy' columns. Follow the steps below to understand and execute the script.

## Step 1: Connect to the Database
Make sure you are connected to the world_life_expectancy database:

```sql
use world_life_expectancy;
```

## Step 2: Identify Duplicates
Check for duplicates in the table based on the combination of 'country' and 'year':

```sql
select country, year, concat(country, year), count(concat(country, year))
from world_life_expectancy
group by country, year, concat(country, year)
having count(concat(country, year)) > 1;
```

## Step 3: Remove Duplicates
Remove duplicate rows from the table:

```sql
select *
from (
    select row_id, 
    concat(country, year),
    row_number() over(partition by concat(country, year) order by concat(country, year)) AS row_num
    from world_life_expectancy
) AS row_table
where row_num > 1;

delete from world_life_expectancy
where 
    row_id IN (
    select row_id
    from (
        select row_id, 
        concat(country, year),
        row_number() over(partition by concat(country, year) order by concat(country, year)) AS row_num
        from world_life_expectancy
    ) AS row_table
    where row_num > 1
);
```

## Step 4: Handle Blanks in 'Status' Column for Developing Countries
Identify and update blank values in the 'Status' column:

```sql
-- Find blanks in Status column 
select *
from world_life_expectancy
where status = '';

-- Update 'developing' status for countries with 'developing' status
update world_life_expectancy
set status = 'developing' 
where country IN (
        select distinct(country)
        from world_life_expectancy
        where status = 'developing'
    );
```

```sql
update world_life_expectancy t1
join world_life_expectancy t2
    ON t1.country = t2.country
set t1.status = 'developing' 
where t1.status = ''
AND t2.status <> '' 
AND t2.status = 'developing';
```

## Step 5: Update 'Status' Column for Developed Countries

```sql
update world_life_expectancy t1
join world_life_expectancy t2
    ON t1.country = t2.country
set t1.status = 'Developed'
where t1.status = ''
AND t2.status <> '' 
AND t2.status = 'Developed';
```

## Step 6: Handle Blanks in 'Life Expectancy' Column
Identify and update blank values in the 'Life Expectancy' column:

```sql
-- Find blank in life expectancy (LE)
select * 
from world_life_expectancy
where `Life expectancy` = '';

-- Populate blank LE in Afghanistan
select country, year, `Life expectancy`
from world_life_expectancy
# where `Life expectancy` = '';
```

## Step 7: Update 'Life Expectancy' for Blank Rows
Update 'Life Expectancy' column for rows with blank values by averaging the values from the previous and next years:

```sql
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
where t1.`Life expectancy` = '';

update world_life_expectancy t1
join world_life_expectancy t2
    ON t1.country = t2.country
    AND t1.year = t2.year - 1
join world_life_expectancy t3
    ON t1.country = t3.country
    AND t1.year = t3.year + 1
set t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
where t1.`Life expectancy` = '';
```
