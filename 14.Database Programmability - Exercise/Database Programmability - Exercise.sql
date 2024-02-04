#01. Employees with Salary Above 35000

DELIMITER $
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
SELECT first_name, last_name
FROM employees
WHERE salary > 35000
ORDER BY first_name,last_name,employee_id;
END$
DELIMITER ;
;
#02. Employees with Salary Above Number

DELIMITER $
CREATE PROCEDURE usp_get_employees_salary_above (target_salary DECIMAL(20,4))
BEGIN
SELECT first_name , last_name
FROM employees
WHERE salary >= target_salary
ORDER BY first_name,last_name,employee_id;
END$
DELIMITER ;
;
#03. Town Names Starting With

DELIMITER $

CREATE PROCEDURE usp_get_towns_starting_with (start_text VARCHAR (50)) 
BEGIN
SELECT name FROM towns
WHERE name LIKE CONCAT(start_text, '%')
ORDER BY name ;

END$

DELIMITER ;
;
#04. Employees from Town

DELIMITER $

CREATE PROCEDURE usp_get_employees_from_town (town_name VARCHAR(50))
BEGIN
SELECT e.first_name , e.last_name FROM employees AS e
JOIN addresses AS a ON e.address_id = a.address_id
JOIN towns AS t ON a.town_id = t.town_id
WHERE t.name = town_name
ORDER BY first_name,last_name,employee_id;

END$
DELIMITER ;
;

#05. Salary Level Function

DELIMITER $

CREATE FUNCTION ufn_get_salary_level (search_salary DECIMAL(19,4))
RETURNS VARCHAR (10)
DETERMINISTIC
BEGIN
	RETURN (
    CASE 
    WHEN search_salary <30000 THEN 'Low'
    WHEN search_salary <=50000 THEN 'Average'
    ELSE 'High' END
    ) ;
    
END$
DELIMITER ;
;

#06. Employees by Salary Level

DELIMITER $

CREATE PROCEDURE usp_get_employees_by_salary_level (salary_level VARCHAR (10))
BEGIN
SELECT first_name, last_name FROM employees
WHERE ufn_get_salary_level(salary) = salary_level
ORDER BY first_name DESC, last_name DESC;

END$

DELIMITER ;
;

#07. Define Function

CREATE FUNCTION  ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
RETURNS BIT
RETURN word REGEXP (CONCAT('^[', set_of_letters, ']+$'));


#08. Find Full Name

DELIMITER $
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
SELECT CONCAT_WS(' ',first_name, last_name) AS full_name
FROM account_holders
ORDER BY `full_name`, id;
END $

DELIMITER ;
;

# 9. People with Balance Higher Than (not included in final score)
DELIMITER $
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(total_balance DECIMAL(19, 4))
BEGIN
SELECT ah.first_name, ah.last_name
FROM account_holders AS ah
JOIN accounts AS a ON ah.id  = a.account_holder_id
GROUP BY a.account_holder_id
HAVING SUM(a.balance) > total_balance
ORDER BY a.account_holder_id;
END $

DELIMITER ;



#10. Future Value Function
DELIMITER $
CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19, 4), yearly_interest_rate DOUBLE, number_of_years INT)
RETURNS DECIMAL(19, 4)
RETURN sum * POW((1 + yearly_interest_rate), number_of_years);
END$
DELIMITER ;

#11. Calculating Interest
DELIMITER $
CREATE PROCEDURE  usp_calculate_future_value_for_account(account_id INT, interest_rate DECIMAL(19, 4))
BEGIN
SELECT a.id,
ah.first_name,
ah.last_name,
a.balance AS current_balance,
ufn_calculate_future_value(a.balance , interest_rate, 5) AS balance_in_5_years
FROM accounts AS a
JOIN account_holders AS ah ON  a.account_holder_id = ah.id
WHERE a.id = account_id ;
END $

DELIMITER ;

#12. Deposit Money
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT , money_amount DECIMAL(19, 4))
BEGIN
START TRANSACTION;
IF (money_amount <= 0)
THEN ROLLBACK;
ELSE
UPDATE accounts AS a
SET a.balance = a.balance + money_amount
WHERE a.id = account_id;
END IF;
END $$

DELIMITER ;

#13. Withdraw Money
DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
IF (money_amount > 0)
THEN START TRANSACTION;
UPDATE accounts AS a 
SET 
    a.balance = a.balance - money_amount
WHERE
    a.id = account_id;
    IF (SELECT balance FROM accounts WHERE id = account_id) < 0
    THEN ROLLBACK;
	ELSE COMMIT;
    END IF;
END IF;
END $$

DELIMITER ;

# 14. Money Transfer
DELIMITER $$
CREATE PROCEDURE  usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19, 4))
BEGIN
	IF amount > 0
	   AND (SELECT id FROM accounts WHERE id = from_account_id) IS NOT NULL
       AND (SELECT id FROM accounts WHERE id = to_account_id) IS NOT NULL
       AND (SELECT balance FROM accounts WHERE id = from_account_id) >= amount
       AND (from_account_id <> to_account_id)
	THEN START TRANSACTION;
UPDATE accounts AS a 
SET 
    a.balance = a.balance - amount
WHERE
    a.id = from_account_id;
UPDATE accounts AS a 
SET 
    a.balance = a.balance + amount
WHERE
    a.id = to_account_id;
     END IF;
END $$

DELIMITER ;

#15. Log Accounts Trigger (not included in final score)
CREATE TABLE logs(
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT NOT NULL,
old_sum DECIMAL(19, 4) NOT NULL,
new_sum DECIMAL(19, 4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_changed_account_balance
AFTER UPDATE
ON accounts
FOR EACH ROW
BEGIN
	IF OLD.balance <> NEW.balance
    THEN
        INSERT INTO logs(account_id, old_sum, new_sum)
		VALUE (OLD.id, OLD.balance, NEW.balance);
	END IF;
END $$

DELIMITER ;

#16. Emails Trigger (not included in final score)
CREATE TABLE notification_emails(
id INT PRIMARY KEY AUTO_INCREMENT,
recipient INT NOT NULL,
subject VARCHAR(50) NOT NULL,
body TEXT NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_create_notification_email
  AFTER INSERT
  ON logs
  FOR EACH ROW
BEGIN
  INSERT INTO notification_emails(recipient, subject, body)
  VALUE(NEW.account_id,
  CONCAT('Balance change for account: ', NEW.account_id),
  CONCAT_WS(' ', 'On', DATE_FORMAT(NOW(), '%M %e %Y at %r'), 'your balance was changed from', NEW.old_sum, 'to', NEW.new_sum));
END $$

DELIMITER ;









