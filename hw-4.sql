CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);



INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, 3),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);
   
CREATE TABLE IF NOT EXISTS managers (
manager_id SERIAL PRIMARY KEY,
name VARCHAR(50) NOT NULL
);

INSERT INTO managers (name)
VALUES
('Emily Wilson'),
('Liam Thompson'),
('Ava Garcia'),
('Ethan Lee'),
('Sophia Patel');

   
   
CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);


INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-10-21'),
    (2, 2, 15, '2024-10-14'),
    (3, 1, 27, '2024-11-21'),
    (3, 3, 25, '2024-11-15'),
    (4, 2, 11, '2024-11-17'),
    (2, 1, 12, '2024-11-01');

CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);
   
   
CREATE OR REPLACE FUNCTION check_department()
RETURNS TRIGGER AS $$
BEGIN 
	IF NEW.department NOT IN ('Sales', 'IT')
	THEN RAISE EXCEPTION 'Сотрудник не принадлежит ни одному из имеющихся подразделений';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER department_check_trigger
AFTER INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION check_department();




CREATE OR REPLACE FUNCTION log_insert()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Добавлена новая строка в таблицу %', sales;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER log_insert_trigger
AFTER INSERT ON sales
FOR EACH ROW EXECUTE FUNCTION log_insert(); -- Пример с логированием 



CREATE OR REPLACE FUNCTION prevent_insert()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Запрещено добавление новых строк в эту таблицу';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_insert_on_table
BEFORE INSERT ON products
FOR EACH ROW
EXECUTE FUNCTION prevent_insert(); -- Пример операционного триггера
   

BEGIN;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Dora', 'Manager', 'Marketing', 45000, NULL);

СOMMIT;

ROLLBACK; -- фейловая транзакция, такого департамента нет
   

BEGIN;
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Dora', 'Manager', 'Sales', 45000, NULL);
COMMIT; -- успешная транзакция

BEGIN;
INSERT INTO products (name, price)
VALUES ('Product E', 240.00);
COMMIT;
ROLLBACK; -- фейловая транзакция, запрет на добавление новых строк с таблицу