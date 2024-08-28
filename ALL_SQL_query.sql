SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO  layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,  industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company =  TRIM(company);

SELECT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
where industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
where industry like 'Crypto%';

SELECT distinct industry
FROM layoffs_staging2;

SELECT distinct industry
FROM layoffs_staging2;

SELECT country, TRIM(trailing '.'from country)
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country =  TRIM(trailing '.'from country)
where country like 'United States%';

SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` =  STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
where industry is null
or industry = '';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2 
   on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
    on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = '';

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

delete
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

alter table layoffs_staging2
drop column row_num;

SELECT max(total_laid_off), max(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

SELECT *
FROM layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_staging2;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select *
from layoffs_staging2;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 desc;

select company, sum(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select company, avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select substring(`date`,1,7) as `MONTH`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `MONTH`
order by 1 asc;

with Rolling_Total as
(
select substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `MONTH`
order by 1 asc
)
select `MONTH` ,total_off, sum(total_off) over(order by `MONTH`) AS Rolling_Total
from Rolling_Total;


select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;


select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by company asc;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 asc;


with Company_year (company, years, total_laid_off) As
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
)
select *,dense_rank() over (partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
order by ranking Asc;


with Company_year (company, years, total_laid_off) As
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), Company_Year_Rank as
(
select *,dense_rank() over (partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
)
select*
from Company_Year_Rank
where Ranking <=5
;