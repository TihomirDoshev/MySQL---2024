CREATE DATABASE SoftUni_Taxi_Company ;

#01. Table Design

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(100) NOT NULL
);

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(10) NOT NULL
);
CREATE TABLE clients(
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR (50) NOT NULL,
phone_number VARCHAR (20) NOT NULL
);
CREATE TABLE drivers(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (30) NOT NULL,
last_name VARCHAR (30) NOT NULL,
age INT NOT NULL,
rating FLOAT DEFAULT 5.5
);

CREATE TABLE cars(
id INT PRIMARY KEY AUTO_INCREMENT,
make VARCHAR (20) NOT NULL,
model VARCHAR (20) ,
year INT DEFAULT 0 NOT NULL,
mileage INT DEFAULT 0,
`condition` CHAR (1) NOT NULL ,
category_id INT NOT NULL
);

CREATE TABLE courses (
id INT PRIMARY KEY AUTO_INCREMENT,
from_address_id INT NOT NULL,
start DATETIME NOT NULL,
bill DECIMAL(10,2) DEFAULT 10,
car_id INT NOT NULL,
client_id INT NOT NULL
);

CREATE TABLE cars_drivers(
car_id INT NOT NULL,
driver_id INT NOT NULL
);

ALTER TABLE courses
ADD CONSTRAINT fk_c_a
FOREIGN KEY (from_address_id)
REFERENCES addresses(id),

ADD CONSTRAINT fk_c_c
FOREIGN KEY (client_id)
REFERENCES clients(id),

ADD CONSTRAINT fk_c_cars
FOREIGN KEY (car_id)
REFERENCES cars(id)
;
ALTER TABLE cars
ADD CONSTRAINT fk_cars_categories
FOREIGN KEY (category_id)
REFERENCES categories(id)
;
ALTER TABLE cars_drivers
ADD CONSTRAINT pk_cars_drivers
PRIMARY KEY (driver_id,car_id),

ADD CONSTRAINT fk_cars_drivers_drivers
FOREIGN KEY (driver_id)
REFERENCES drivers(id),

ADD CONSTRAINT fk_cars_drivers_cars
FOREIGN KEY (car_id)
REFERENCES cars(id)
;

#02. Insert

INSERT INTO clients (full_name, phone_number)

SELECT 
CONCAT(first_name,' ',last_name),
CONCAT('(088) 9999',id * 2) 
FROM drivers
WHERE id BETWEEN 10 AND 20
;

#03. Update

UPDATE cars
SET `condition` = 'C' 
WHERE mileage >= 800000 OR mileage IS NULL 
AND year <= 2010 
AND make != 'Mercedes-Benz'
;

#04. Delete

DELETE c FROM clients AS c
LEFT JOIN courses AS cou ON cou.client_id = c.id
WHERE cou.id IS NULL AND CHAR_LENGTH(c.full_name) > 3
;

#05. Cars

SELECT 
make,model,`condition`
FROM cars
ORDER BY id
;
#06. Drivers and Cars
 SELECT 
 d.first_name,
 d.last_name,
 c.make,
 c.model,
 c.mileage
 
 FROM cars AS c
 JOIN cars_drivers AS cd ON c.id = cd.car_id
 JOIN drivers AS d ON cd.driver_id = d.id
 WHERE  c.mileage IS NOT NULL
 ORDER BY c.mileage DESC, d.first_name
 ;
 
 #07. Number of courses
 
 SELECT
 c.id AS car_id, c.make, c.mileage,
 COUNT(co.id) AS count_of_courses,
 ROUND(AVG(co.bill),2) AS avg_bill
 FROM cars AS c
 LEFT JOIN courses AS co ON co.car_id = c.id
 GROUP BY c.id
 HAVING count_of_courses !=2
 ORDER BY count_of_courses DESC,c.id
 ;
 
 #08. Regular clients
 
 SELECT cl.full_name,
 COUNT(c.id) AS count_of_cars,
 SUM(co.bill) AS total_sum
 FROM cars AS c
 JOIN courses AS co ON co.car_id = c.id
 JOIN clients AS cl ON cl.id = co.client_id
 GROUP BY cl.id
 HAVING count_of_cars > 1 AND SUBSTRING(cl.full_name,2,1) = 'a'
 ORDER BY cl.full_name
 ;
 
 #09. Full info for courses
 
 SELECT 
 adr.name,
 IF(HOUR(cou.start) BETWEEN 6 AND 20,
        'Day',
        'Night') AS day_time,
 cou.bill,
 cl.full_name,
 c.make,
 c.model,
 cat.name AS category_name 

 FROM cars AS c
 JOIN categories AS cat ON c.category_id = cat.id
 JOIN courses AS cou ON cou.car_id = c.id
 JOIN addresses AS adr ON cou.from_address_id = adr.id
 JOIN clients AS cl ON cl.id = cou.client_id
 ORDER BY cou.id
 ;
 
 #10. Find all courses by client’s phone number
 
 DELIMITER $
 CREATE FUNCTION udf_courses_by_client (phone_num VARCHAR (20))
 RETURNS INT
 DETERMINISTIC
 BEGIN
 DECLARE result INT;
 SET result := ( SELECT 
 COUNT(cou.id) 
 FROM clients AS c
 JOIN courses AS cou ON cou.client_id = c.id
 
 );
 RETURN result;
 END $
 DELIMITER ;
 
 
 
 








