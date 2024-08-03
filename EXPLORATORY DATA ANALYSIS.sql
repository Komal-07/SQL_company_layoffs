-- EXPLORATORY DATA ANALYSIS

SELECT DISTINCT
    *
FROM
    layoff_staging2
WHERE
    company = '2TM';

-- CHECKING THE MAX total_laid_off and percentage_laid_off value
SELECT 
    MAX(total_laid_off), MAX(percentage_laid_off)
FROM
    layoff_staging2;

-- COMPANY THAT LAID OFF THE MAXIMUM NUMBER OF EMPLOYEES
SELECT 
    company, SUM(total_laid_off) AS sum_laid_off
FROM
    layoff_staging2
WHERE
    total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC; -- AMAZON

-- WHICH INDUSTRY LAID OFF THE HIGHEST NUMBER OF EMPLOYEES
SELECT * FROM layoff_staging2;

SELECT 
    industry, SUM(total_laid_off) AS sum_laid_off
FROM
    layoff_staging2
WHERE
    total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;  -- CONSUMER

-- WHICH COUNTRY LAID OFF THE HIGHEST NUMBER OF EMPLOYEES
SELECT 
    country, SUM(total_laid_off) AS sum_laid_off
FROM
    layoff_staging2
WHERE
    total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;  -- UNITED STATES

-- WHICH YEAR HAD THE HIGHEST NUMBER OF LAYOFFS
SELECT 
     YEAR(`date`), SUM(total_laid_off) AS sum_laid_off
FROM
    layoff_staging2
WHERE
    total_laid_off IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;   -- 2022

-- CALCULATING THE ROLLING TOTAL OF LAYOFFS
SELECT * FROM layoff_staging2;

SELECT 
     MONTH(`date`) as `month`, SUM(total_laid_off) AS sum_laid_off
FROM
    layoff_staging2
WHERE
    total_laid_off IS NOT NULL
    AND MONTH(`date`) IS NOT NULL
GROUP BY  MONTH(`date`)
ORDER BY 1;

SELECT 
     SUBSTRING(`date`,1,7) as `year_month`, SUM(total_laid_off) AS sum_laid_off
FROM
    layoff_staging2
WHERE
    total_laid_off IS NOT NULL
    AND SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY  SUBSTRING(`date`,1,7)
ORDER BY 1;


WITH ROLLING_CTE AS(
SELECT 
     SUBSTRING(`date`,1,7) as `year_month`, SUM(total_laid_off) AS sum_laid_off
FROM
    layoff_staging2
WHERE
    total_laid_off IS NOT NULL
    AND SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY  SUBSTRING(`date`,1,7)
ORDER BY 1)
SELECT `year_month`, SUM(sum_laid_off) OVER(ORDER BY `year_month`) as rolling_total 
from ROLLING_CTE ;


-- CALCULATING THE RANK OF THE COMPANY LAYOFFS

SELECT * FROM layoff_staging2;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, YEAR(`date`)
HAVING SUM(total_laid_off) IS NOT NULL;

WITH COMPANY_YEAR AS
( SELECT company, YEAR(`date`) as `year`, SUM(total_laid_off) as sum_laid_off
FROM layoff_staging2
GROUP BY company, YEAR(`date`)
HAVING SUM(total_laid_off) IS NOT NULL),
COMPANY_YEAR_RANK AS (
SELECT * , DENSE_RANK() OVER (PARTITION BY `year` ORDER BY sum_laid_off DESC)  as ranking
FROM COMPANY_YEAR
WHERE `year` IS NOT NULL)
SELECT * FROM COMPANY_YEAR_RANK
WHERE ranking <= 5;




































