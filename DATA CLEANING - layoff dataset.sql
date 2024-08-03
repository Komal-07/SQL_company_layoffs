-- DATA CLEANING

SELECT 
    *
FROM
    LAYOFFS;

-- STEP 1 Remove Duplicates
-- STEP 2 Stnadardize the Data
-- STEP 3 Null Values or Blank Values
-- STEP 4 Remove the unecessary columns if required

CREATE TABLE layoff_staging LIKE layoffs;-- database table created

SELECT 
    *
FROM
    layoff_staging;  

INSERT layoff_staging 
SELECT * FROM layoffs;   -- data insertion from original table


-- STEP 1 Checking the Duplicates
WITH duplicate_cte as 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, 
funds_raised_millions) as row_num FROM layoff_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

-- We cannot directly delete the duplicates from table duplicate_cte, hence we will create one more table layoff_staging2
CREATE TABLE `layoff_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

SELECT 
    *
FROM
    layoff_staging2;

-- insert the data of duplicate_cte into layoff_staging2
INSERT INTO `world_layoffs`.`layoff_staging2`
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, 
funds_raised_millions) as row_num FROM layoff_staging;

SELECT 
    *
FROM
    layoff_staging2
WHERE
    row_num > 1;

-- delete the duplicates value
DELETE FROM layoff_staging2 
WHERE
    row_num > 1;

-- now we have data without duplicates!
SELECT 
    *
FROM
    layoff_staging2;

-- STEP 2 Standardization
SELECT DISTINCT
    company, TRIM(COMPANY)
FROM
    layoff_staging2;

-- Remove the space from the starting of the company name
UPDATE layoff_staging2 
SET 
    company = TRIM(company);

SELECT 
    *
FROM
    layoff_staging2;

SELECT DISTINCT
    industry
FROM
    layoff_staging2
ORDER BY industry;

-- Merge the industry name which seems to be same
UPDATE layoff_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';

SELECT DISTINCT
    country
FROM
    layoff_staging2
ORDER BY 1;

-- Removing the trailing dot from country column
UPDATE layoff_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';

SELECT 
    *
FROM
    layoff_staging2
WHERE
    country LIKE 'United States%';

SELECT 
    *
FROM
    layoff_staging2;

-- Changing the date formats 
SELECT 
    `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM
    layoff_staging2;

UPDATE layoff_staging2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT 
    *
FROM
    layoff_staging2;

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

-- STEP 3 Handling Null Values and Blank Values
SELECT 
    *
FROM
    layoff_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

SELECT 
    *
FROM
    layoff_staging2
WHERE
    industry IS NULL OR industry = ''
ORDER BY industry;

SELECT DISTINCT
    *
FROM
    layoff_staging2
WHERE
    company = 'Carvana';

SELECT DISTINCT
    *
FROM
    layoff_staging2 tab1
        JOIN
    layoff_staging2 tab2 ON tab1.company = tab2.company
WHERE
    ((tab1.industry IS NULL)
        AND (tab2.industry IS NOT NULL));

-- Coverting the blank values into null values
UPDATE layoff_staging2 
SET 
    industry = NULL
WHERE
    industry = '';

-- populating null values of industry with relavant industry name based on the company
UPDATE layoff_staging2 tab1
        JOIN
    layoff_staging2 tab2 ON tab1.company = tab2.company 
SET 
    tab1.industry = tab2.industry
WHERE
    ((tab1.industry IS NULL)
        AND (tab2.industry IS NOT NULL));

SELECT 
    *
FROM
    layoff_staging2;

-- STEP 4 Remove all the unncessary columns

SELECT 
    *
FROM
    layoff_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

-- deleting the rows that has total laid off and percentage laid off both as null
DELETE FROM layoff_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

SELECT 
    *
FROM
    layoff_staging2;

-- drop the column row_num as it's not needed any more 
ALTER TABLE layoff_staging2
DROP COLUMN row_num;

-- END OF CODE --

 






























































