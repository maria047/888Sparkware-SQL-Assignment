CREATE OR REPLACE TABLE MASTER_DB.SHOP.Products
(
product_id INT AUTOINCREMENT START 1 INCREMENT 1,
product_name VARCHAR (50) NOT NULL,
product_category VARCHAR (50),
creation_day DATE NOT NULL,
update_date DATE
);

INSERT INTO MASTER_DB.SHOP.Products 

(product_name,
product_category,
creation_day,
update_date)

VALUES
--January 2022
('Rose', 'Flowers', '2022-01-20', '2022-04-20'),
('Horse', null, '2022-01-23', '2023-02-23'),
('Beetle', 'Bugs', '2022-01-29', '2023-06-14'),
--February 2022
('Cat', 'Animals', '2022-02-13', '2023-02-12'),
('Ladybug', 'Bugs', '2022-02-19', '2022-03-23'),
('Lily','Flowers', '2022-02-17', '2023-07-11'),
('Begonia', 'Flowers', '2022-02-22', '2023-03-02'),
--March 2022
('Parrot', 'Animals', '2022-03-09', '2023-08-18'),
('Crocodile', 'Animals', '2022-03-15', '2023-04-01'),
--April 2022
('Cactus', 'Flowers', '2022-04-19', '2023-02-13'),
('Cactus', 'Flowers', '2022-04-19', '2023-02-13'),
--January 2023
('Butterfly', null, '2023-01-09', '2023-07-07'),
('Magnolia', 'Flowers', '2023-01-14', '2023-05-07'),
--February 2023
('Hippo', 'Animals', '2023-02-15', '2023-04-03'),
('Giraffe', null, '2023-02-12', '2023-06-20'),
--March 2023
('Spider', 'Bugs', '2023-03-01', '2023-04-11'),
('Spider', 'Bugs', '2023-03-01', '2023-04-11'),
--April 2023
('Dandelion', 'Flowers', '2023-04-23', '2023-08-18'),
('Dandelion', 'Flowers', '2023-04-23', '2023-08-18'),
--May 2023
('Cricket', 'Bugs', '2023-05-12', '2023-07-14'),
('Bull', 'Animals', '2023-05-30', '2023-08-17'),
('Poppy', 'Flowers', '2023-05-30', '2023-08-04'),
--April 2023
('Honeybee', 'Bugs', '2023-06-04', '2023-08-17'),
('Hibibscus', 'Flowers', '2023-06-19', null);

--1. Get the month from the last year that have the highest number of products created;

WITH products_per_month AS 
--Select AVG (product_count) FROM
(SELECT TO_VARCHAR(creation_day, 'MMMM') AS year_month,
       COUNT(*) AS product_count
FROM MASTER_DB.SHOP.PRODUCTS
WHERE year(creation_day) = 2022
GROUP BY year_month), --;

maxim AS (SELECT max (product_count) AS products_max FROM products_per_month)

SELECT year_month, products_max FROM products_per_month JOIN maxim ON product_count=products_max;

--2. Get the last product created; (how would you get the last one updated or created - when a product is created there is NULL as update_date);

SELECT * FROM master_db.shop.products
WHERE creation_day = (SELECT MAX(creation_day) FROM master_db.shop.products);
--WHERE update_date = (SELECT MAX(update_date) FROM master_db.shop.products); -> if last update_date

--3. Get the products that have no product_category set (null);

SELECT * FROM master_db.shop.products
WHERE product_category is null;

--AND EXTRACT (MONTH FROM creation_day)=01;
--AND EXTRACT (YEAR FROM creation_day)=2022; -> extra if we need records from a specific year or month

--4.  Get the number of products updated in a specific period;

SELECT COUNT (*) update_date 
FROM MASTER_DB.SHOP.PRODUCTS
WHERE update_date between '2023-01-01' and '2023-08-30';

--5. Get the products that were not updated for more than a year;

SELECT * FROM master_db.shop.products
WHERE update_date <= DATEADD (YEAR, -1, current_date);

--6. Get the duplications by product_name;(how would you remove the duplicates? )

SELECT product_name, COUNT(product_name) AS Number_of_records
FROM master_db.shop.products
GROUP BY product_name
HAVING COUNT(product_name) > 1;

SELECT * --p1.product_id, p1.product_name, p1.product_category, p1.creation_day, p1.update_date
FROM master_db.shop.products p1;
JOIN (
    SELECT product_name, MIN(product_id) AS min_product_id
    FROM master_db.shop.products
    GROUP BY product_name
    HAVING COUNT(*) > 1
    ) p2 
    ON p1.product_name = p2.product_name
   AND p1.product_id != p2.min_product_id;

DELETE FROM master_db.shop.products
WHERE product_id IN (
    SELECT p1.product_id
    FROM master_db.shop.products p1
    JOIN (
        SELECT product_name, MIN(product_id) AS min_product_id
        FROM master_db.shop.products
        GROUP BY product_name
        HAVING COUNT(*) > 1
        ) p2 
        ON p1.product_name = p2.product_name
       AND p1.product_id != p2.min_product_id);

--If a point-in-time copy of the Products table was created, named Products_20230711, how would you check for all the differences between the two tables ?

CREATE OR REPLACE TABLE MASTER_DB.SHOP.Products_20230711
(
product_id INT AUTOINCREMENT START 1 INCREMENT 1,
product_name VARCHAR (50) NOT NULL,
product_category VARCHAR (50),
creation_day DATE NOT NULL,
update_date DATE
);

INSERT INTO MASTER_DB.SHOP.Products_20230711

(product_name,
product_category,
creation_day,
update_date)

VALUES
--January 2022
('Rose', 'Flowers', '2022-01-20', '2022-04-20'),
('Horse', null, '2022-01-23', '2023-02-23'),
('Beetle', 'Bugs', '2022-01-29', '2023-06-14'),
--February 2022
('Cat', 'Animals', '2022-02-13', '2023-02-12'),
('Ladybug', 'Bugs', '2022-02-19', '2022-03-23'),
('Lily','Flowers', '2022-02-17', '2023-07-11'),
('Begonia', 'Flowers', '2022-02-22', '2023-03-02'),
--March 2022
('Parrot', 'Animals', '2022-03-09', '2023-08-18'),
('Crocodile', 'Animals', '2022-03-15', '2023-04-01'),
--April 2022
('Cactus', 'Flowers', '2022-04-19', '2023-02-13'),
('Pizza', 'Food', '2022-04-19', '2023-02-13'), --extra item
--January 2023
('Butterfly', null, '2023-01-09', '2023-07-07'),
('Magnolia', 'Flowers', '2023-01-14', '2023-05-07'),
--February 2023
('Hippo', 'Animals', '2023-02-15', '2023-04-03'),
('Giraffe', null, '2023-02-12', '2023-06-20'),
--March 2023
('Spider', 'Bugs', '2023-03-01', '2023-04-11'),
('Burger', 'Food', '2023-03-01', '2023-04-11'), --extra item
--April 2023
('Dandelion', 'Flowers', '2023-04-23', '2023-08-18'),
('Pasta', 'Food', '2023-04-23', '2023-08-18'), --extra item
--May 2023
('Cricket', 'Bugs', '2023-05-12', '2023-07-14'),
('Bull', 'Animals', '2023-05-30', '2023-08-17'),
('Poppy', 'Flowers', '2023-05-30', '2023-08-04'),
--April 2023
('Honeybee', 'Bugs', '2023-06-04', '2023-08-17'),
('Hibibscus', 'Flowers', '2023-06-19', null);

SELECT * FROM master_db.shop.Products_20230711
EXCEPT
SELECT * FROM master_db.shop.Products;

Select t1.product_id, t1.product_name, t2.*
From master_db.shop.Products_20230711 AS t1 Left Join master_db.shop.Products AS t2 
ON t1.product_id = t2.product_id
WHERE t2.product_id is null;
-----
SELECT TO_VARCHAR(creation_day, 'MMMM') AS year_month,
       COUNT(*) AS product_count
FROM MASTER_DB.SHOP.PRODUCTS
WHERE year(creation_day) = year (current_date ())-1
GROUP BY year_month
ORDER BY product_count DESC
Limit 1;