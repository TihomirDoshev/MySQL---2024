CREATE DATABASE real_estate_db’s ;

#Section 1: Data Definition Language (DDL) – 40 pts

CREATE TABLE cities(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE property_types(
id INT PRIMARY KEY AUTO_INCREMENT,
type VARCHAR(40) NOT NULL UNIQUE,
description TEXT
);

CREATE TABLE properties(
id INT PRIMARY KEY AUTO_INCREMENT,
address VARCHAR(80) NOT NULL UNIQUE,
price DECIMAL(19,2) NOT NULL,
area DECIMAL(19,2),
property_type_id INT,
city_id INT
);

CREATE TABLE agents(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(40) NOT NULL,
last_name VARCHAR(40) NOT NULL,
phone VARCHAR(20) NOT NULL UNIQUE,
email VARCHAR(50) NOT NULL UNIQUE,
city_id INT
);

CREATE TABLE buyers(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(40) NOT NULL,
last_name VARCHAR(40) NOT NULL,
phone VARCHAR(20) NOT NULL UNIQUE,
email VARCHAR(50) NOT NULL UNIQUE,
city_id INT
);

CREATE TABLE property_offers(
property_id INT NOT NULL,
agent_id INT NOT NULL,
price DECIMAL(19,2) NOT NULL,
offer_datetime DATETIME
);
CREATE TABLE property_transactions(
id INT PRIMARY KEY AUTO_INCREMENT,
property_id INT NOT NULL,
buyer_id INT NOT NULL,
transaction_date DATE,
bank_name VARCHAR(30),
iban VARCHAR(40) UNIQUE,
is_successful TINYINT(1)
);

ALTER TABLE  buyers
ADD CONSTRAINT fk_buyers_cities
FOREIGN KEY (city_id)
REFERENCES cities(id)
;
ALTER TABLE agents
ADD CONSTRAINT fk_agents_cities
FOREIGN KEY (city_id)
REFERENCES cities(id)
;

ALTER TABLE property_offers
ADD CONSTRAINT fk_property_offers_agents
FOREIGN KEY (agent_id)
REFERENCES agents(id),

ADD CONSTRAINT fk_property_offers_properties
FOREIGN KEY (property_id)
REFERENCES properties(id)
;

ALTER TABLE properties
ADD CONSTRAINT fk_properties_property_type
FOREIGN KEY (property_type_id)
REFERENCES property_types(id),

ADD CONSTRAINT fk_properties_cities
FOREIGN KEY (city_id)
REFERENCES cities(id)
;

ALTER TABLE property_transactions
ADD CONSTRAINT fk_property_transactions_buyers
FOREIGN KEY (buyer_id)
REFERENCES buyers(id),

ADD CONSTRAINT fk_property_transactions_properties
FOREIGN KEY(property_id)
REFERENCES properties(id)
;


#Section 2: Data Manipulation Language (DML) – 30 pts

INSERT INTO property_transactions(property_id ,buyer_id ,transaction_date,bank_name,iban ,is_successful)
SELECT
	p.agent_id + DAY(p.offer_datetime),
    p.agent_id + MONTH(p.offer_datetime),
    DATE(p.offer_datetime),
    CONCAT("Bank ",p.agent_id),
    CONCAT('BG',p.price,p.agent_id),
    1
FROM property_offers AS p
WHERE p.agent_id <= 2;   

UPDATE properties
SET price = price - 50000
WHERE price >= 800000;

DELETE  FROM property_transactions
WHERE is_successful = 0;

#Section 3: Querying – 50 pts

SELECT * FROM agents
ORDER BY city_id DESC,phone DESC;

SELECT * FROM property_offers
WHERE YEAR(offer_datetime) = 2021
ORDER BY price
LIMIT 10;

SELECT SUBSTRING(p.address,1,6) AS agent_name,
CHAR_LENGTH(p.address) * 5430 AS price
FROM properties AS p
LEFT JOIN property_offers AS po 
ON p.id = po.property_id
WHERE po.agent_id IS NULL
ORDER BY agent_name DESC , price DESC; 

SELECT bank_name, COUNT(*)  AS count FROM property_transactions
GROUP BY bank_name
HAVING count >=9
ORDER BY count DESC, bank_name;

SELECT address,area,
CASE
WHEN area <= 100 THEN 'small'
WHEN area <= 200 THEN 'medium'
WHEN area <= 500 then 'large'
ELSE 'extra large'
END AS size
FROM properties
ORDER BY area ,address DESC;

#Section 4: Programmability – 30 pts

DELIMITER $
CREATE FUNCTION udf_offers_from_city_name (cityName VARCHAR(50))
RETURNS iNT
DETERMINISTIC
BEGIN 
	DECLARE offers_count INT;
	SET offers_count := (
    SELECT COUNT(po.property_id) AS offers_count
    FROM property_offers AS po
    JOIN properties AS p ON po.property_id = p.id
    JOIN cities AS c ON p.city_id = c.id
    WHERE c.name = cityName
    );
    RETURN offers_count;
END $
DELIMITER ;


DELIMITER $
CREATE PROCEDURE udp_special_offer (first_name VARCHAR(50))
BEGIN
	UPDATE property_offers AS po
    JOIN agents AS a ON po.agent_id = a.id
	SET po.price = po.price - po.price * 0.1
    WHERE a.first_name = first_name; 
END$

DELIMITER ;




















