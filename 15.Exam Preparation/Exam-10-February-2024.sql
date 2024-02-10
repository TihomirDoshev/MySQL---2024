CREATE DATABASE preserves_db;

#01. Table Design

CREATE TABLE continents(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE
);
CREATE TABLE countries(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE,
country_code VARCHAR(10) NOT NULL UNIQUE,
continent_id INT NOT NULL
);

CREATE TABLE preserves(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(255) NOT NULL UNIQUE,
latitude DECIMAL(9,6),
longitude DECIMAL(9,6),
area INT,
type VARCHAR(20),
established_on DATE
);
CREATE TABLE positions(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE,
description TEXT,
is_dangerous TINYINT(1) NOT NULL
);

CREATE TABLE workers(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(40) NOT NULL,
last_name VARCHAR(40) NOT NULL,
age INT,
personal_number VARCHAR(20) NOT NULL UNIQUE,
salary DECIMAL(19,2),
is_armed TINYINT(1) NOT NULL,
start_date DATE,
preserve_id INT,
position_id INT NOT NULL 

);
CREATE TABLE countries_preserves(
country_id INT NOT NULL,
preserve_id INT NOT NULL
);

ALTER TABLE countries
ADD CONSTRAINT fk_contries_contonents
FOREIGN KEY (continent_id)
REFERENCES continents (id)
;
ALTER TABLE countries_preserves
ADD CONSTRAINT fk_countries_preserve_countries
FOREIGN KEY (country_id)
REFERENCES countries(id),

ADD CONSTRAINT fk_countries_preserve_preserves
FOREIGN KEY (preserve_id)
REFERENCES preserves(id)
;
ALTER TABLE workers
ADD CONSTRAINT fk_workers_position
FOREIGN KEY (position_id)
REFERENCES positions(id),

ADD CONSTRAINT fk_workers_preserves
FOREIGN KEY (preserve_id)
REFERENCES preserves(id)
;

#02. Insert

INSERT INTO preserves (name ,latitude ,longitude ,area ,type ,established_on )
SELECT 
CONCAT(name,' ','is in South Hemisphere'),
latitude,
longitude,
area * id,
LOWER(type),
established_on
FROM preserves 
WHERE latitude < 0
;

#03. Update

UPDATE workers
SET salary = salary + 500
WHERE position_id IN (5,8,11,13)
;

#04. Delete

DELETE FROM preserves
WHERE established_on IS NULL
;

#05. Most experienced workers

SELECT 
    CONCAT(first_name,' ',last_name) AS full_name,
    DATEDIFF('2024-01-01', start_date) AS days_of_experience
FROM 
    workers
WHERE 
    DATEDIFF('2024-01-01', start_date) > 1825 
ORDER BY 
    days_of_experience DESC
LIMIT 10;

#06. Workers salary

SELECT 
w.id,w.first_name,w.last_name,p.name,c.country_code
FROM workers AS w
JOIN preserves AS p ON w.preserve_id = p.id
JOIN countries_preserves AS cp ON p.id = cp.preserve_id
JOIN countries AS c ON cp.country_id = c.id
WHERE salary > 5000 AND age < 50
ORDER BY c.country_code
;

#07. Armed workers count

SELECT 
p.name,
COUNT(w.id) AS armed_workers
FROM preserves AS p
JOIN workers AS w ON p.id = w.preserve_id
WHERE w.is_armed = 1
GROUP BY p.name
ORDER BY armed_workers DESC , p.name 
;

#08. Oldest preserves
SELECT p.name, 
       c.country_code, 
       YEAR(established_on) AS founded_in
FROM preserves AS p
JOIN countries_preserves AS cp ON p.id = cp.preserve_id
JOIN countries AS c ON cp.country_id = c.id
WHERE EXTRACT(MONTH FROM established_on) = 5
ORDER BY established_on ASC
LIMIT 5;

#09. Preserve categories

SELECT id, name,
  CASE
    WHEN area <= 100 THEN 'very small'
    WHEN area <= 1000 THEN 'small'
    WHEN area <= 10000 THEN 'medium'
    WHEN area <= 50000 THEN 'large'
    ELSE 'very large'
  END AS category
FROM preserves
ORDER BY area DESC;

#10. Extract average salary

DELIMITER $

CREATE FUNCTION udf_average_salary_by_position_name (name VARCHAR(40))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE result DECIMAL(10, 2);
    SET result :=(SELECT AVG(w.salary)FROM workers AS w
    JOIN positions AS p ON w.position_id = p.id
    WHERE p.name = name
    GROUP BY p.name
    );
    RETURN result;
END $
DELIMITER ;

DELIMITER $
CREATE PROCEDURE udp_increase_salaries_by_country (country_name VARCHAR(40))
BEGIN
UPDATE workers AS w
JOIN preserves AS p ON w.preserve_id = p.id
JOIN countries_preserves AS cp ON p.id = cp.preserve_id
JOIN countries AS c ON cp.country_id = c.id
SET w.salary = w.salary * 1.05
WHERE c.name = country_name
;
END $
DELIMITER ;








