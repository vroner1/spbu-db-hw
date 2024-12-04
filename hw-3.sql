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
   
CREATE TEMPORARY TABLE IF NOT EXISTS high_sales_products AS
SELECT p.name
FROM sales s 
LEFT JOIN products p ON p.product_id = s.product_id 
WHERE s.quantity > 10 AND s.sale_date::date >= NOW() - INTERVAL '7 days'

SELECT *
FROM high_sales_products
LIMIT 10;

WITH employee_sales_stats_1 AS (
SELECT e.name, 
	   SUM(s.quantity * p.price) AS total_sales
FROM employees e 
RIGHT JOIN sales s ON e.employee_id = s.employee_id
LEFT JOIN products p ON p.product_id = s.product_id 
WHERE s.sale_date::date >= NOW() - INTERVAL '30 days'
GROUP BY e.name),

employee_sales_stats_2 AS (
SELECT e.name, 
	   AVG(s.quantity * p.price) AS average_sales,
	    (SELECT AVG(s.quantity * p.price)
        FROM employees e 
        RIGHT JOIN sales s ON e.employee_id = s.employee_id
        LEFT JOIN products p ON p.product_id = s.product_id 
        WHERE e.employee_id IS NOT NULL) AS average_total_sales
FROM employees e 
RIGHT JOIN sales s ON e.employee_id = s.employee_id
LEFT JOIN products p ON p.product_id = s.product_id 
WHERE s.sale_date::date >= NOW() - INTERVAL '30 days'
GROUP BY e.name)


SELECT es1.name
FROM employee_sales_stats_1 es1 
INNER JOIN employee_sales_stats_2 es2 ON es1.name = es2.name
WHERE es1.total_sales > es2.average_total_sales
LIMIT 10; 

WITH RECURSIVE employee_hierarchy AS (
  SELECT 
    employee_id,
    manager_id,
    name,
    0 AS level
  FROM 
    employees
  WHERE 
    manager_id IS NULL  
  
  UNION ALL
  SELECT 
    e.employee_id,
    e.manager_id,
    e.name,
    eh.level + 1
  FROM 
    employees e
  JOIN 
    employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy;


WITH current_table AS (
SELECT DATE_TRUNC('month', "sale_date")::date,
	   p.name,
	   SUM(s.quantity * p.price) AS total_sales
	   
FROM sales s 
LEFT JOIN products p ON s.product_id = p.product_id
WHERE DATE_TRUNC('month', "sale_date")::date = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY p.name, DATE_TRUNC('month', "sale_date")::date
ORDER BY total_sales DESC
LIMIT 3), 

last_month_table AS (
SELECT DATE_TRUNC('month', "sale_date")::date,
	   p.name,
	   SUM(s.quantity * p.price) AS total_sales
	   
FROM sales s 
LEFT JOIN products p ON s.product_id = p.product_id
WHERE DATE_TRUNC('month', "sale_date")::date = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
GROUP BY p.name, DATE_TRUNC('month', "sale_date")::date
ORDER BY total_sales DESC
LIMIT 3)

SELECT *
FROM last_month_table
UNION ALL
SELECT * FROM current_table;

CREATE INDEX idx_employee_id_sale_date ON sales(employee_id, sale_date);

EXPLAIN ANALYZE
SELECT  p.name,
		SUM(s.quantity)
FROM sales s
LEFT JOIN products p ON s.product_id = p.product_id
GROUP BY p.name;

-- Ключевая колонка группы: p.name
-- Сортировка выполняется по полю p.name
-- Метод сортировки: quicksort
-- Используется память: 25kB
-- Хеш-сканирование таблицы sales показывает, что количество строк в этой таблице относительно небольшое
-- Сортировка выполняется в памяти, что является хорошим знаком для производительности