CREATE DATABASE restaurant_db ;

#Section 1: Data Definition Language (DDL) – 40 pts

CREATE TABLE products(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30) NOT NULL UNIQUE,
type VARCHAR(30) NOT NULL,
price DECIMAL(10,2) NOT NULL
);

CREATE TABLE clients(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
birthdate DATE NOT NULL,
card VARCHAR(50),
review TEXT
);

CREATE TABLE tables(
id INT PRIMARY KEY AUTO_INCREMENT,
floor INT NOT NULL,
reserved TINYINT(1),
capacity INT NOT NULL
);

CREATE TABLE waiters(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR (50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(50) NOT NULL,
phone VARCHAR(50),
salary DECIMAL(10,2)
);

CREATE TABLE orders(
id INT PRIMARY KEY AUTO_INCREMENT,
table_id INT NOT NULL,
waiter_id INT NOT NULL,
order_time TIME NOT NULL,
payed_status TINYINT(1)

);

CREATE TABLE orders_clients(
order_id INT,
client_id INT
);

CREATE TABLE orders_products (
order_id INT ,
product_id INT
);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_waiters
FOREIGN KEY (waiter_id)
REFERENCES waiters(id),

ADD CONSTRAINT fk_orders_tables
FOREIGN KEY (table_id)
REFERENCES tables(id)
;

ALTER TABLE orders_products
ADD CONSTRAINT fk_orders_products_products
FOREIGN KEY (product_id)
REFERENCES products(id),

ADD CONSTRAINT fk_orders_products_orders
FOREIGN KEY (order_id) 
REFERENCES orders(id)
;

ALTER TABLE orders_clients
ADD CONSTRAINT fk_orders_clients_orders
FOREIGN KEY (order_id)
REFERENCES orders(id),

ADD CONSTRAINT fk_orders_clients_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
;

#Section 2: Data Manipulation Language (DML) – 30 pts

INSERT INTO products (name ,type ,price)
SELECT 
CONCAT(last_name,' ','specialty') AS name,
'Cocktail' AS type,
CEILING (salary * 0.01) AS price
FROM waiters
WHERE id > 6
;

UPDATE orders
SET table_id = table_id - 1
WHERE id BETWEEN 12 AND 23
;

DELETE w FROM waiters AS w
LEFT JOIN orders AS o ON o.waiter_id = w.id
WHERE o.table_id IS NULL
; 


# Section 3: Querying – 50 pts

SELECT * FROM clients
ORDER BY birthdate DESC, id DESC
;

SELECT first_name,last_name,birthdate,review
FROM clients 
WHERE card IS NULL AND YEAR(birthdate) BETWEEN 1978 AND 1993
ORDER BY last_name DESC, id
LIMIT 5
;

SELECT 
CONCAT(last_name,first_name,CHAR_LENGTH(first_name),'Restaurant')
AS username ,
REVERSE(SUBSTRING(email,2,12)) AS password 
FROM waiters
WHERE salary IS NOT NULL
ORDER BY password DESC
;

 

SELECT p.id,p.name,COUNT(o.table_id) AS count
FROM products AS p
JOIN orders_products AS op ON op.product_id = p.id
JOIN orders AS o ON op.order_id = o.id
GROUP BY p.name
HAVING count >= 5
ORDER BY count DESC, p.name
;

SELECT t.id AS table_id , 
t.capacity, 
COUNT(c.first_name) AS count_clients,
CASE
WHEN t.capacity > COUNT(c.first_name) THEN 'Free seats'
WHEN  t.capacity = COUNT(c.first_name) THEN 'Full'
ELSE 'Extra seats'
END AS availability 
FROM tables AS t
JOIN orders AS o ON o.table_id = t.id
JOIN orders_clients AS oc ON oc.order_id = o.id
JOIN clients AS c ON c.id = oc.client_id
WHERE t.floor = 1
GROUP BY t.id
ORDER BY table_id DESC 
;

#Section 4: Programmability – 30 pts

DELIMITER $
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
RETURNS DECIMAL(10,2) 
DETERMINISTIC
BEGIN
DECLARE result DECIMAL(10,2);
SET result := (SELECT SUM(p.price) AS bill
FROM clients AS c 
JOIN orders_clients AS oc ON c.id = oc.client_id
JOIN orders AS o  ON o.id = oc.order_id
JOIN orders_products AS op ON o.id = op.order_id
JOIN products AS p ON p.id = op.product_id
WHERE CONCAT(first_name,' ',last_name) = full_name
GROUP BY c.id
);
RETURN result ;
END $
DELIMITER ;

DELIMITER $
CREATE PROCEDURE udp_happy_hour (type VARCHAR(50))
BEGIN
UPDATE products AS p
SET p.price = p.price - p.price * 0.2
WHERE p.type = type AND p.price >= 10;

END $
DELIMITER ;








