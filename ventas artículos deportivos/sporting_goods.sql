-- Crear la base de datos 
CREATE DATABASE sporting_goods;

-- Crear las tablas vacías

-- Crear tabla products
CREATE TABLE products (
    product_id int NOT NULL, 
    product_name varchar(100) NOT NULL,
    category varchar(50),
    price DECIMAL(6, 2) NOT NULL,
    stock_quantity int NOT NULL,
    PRIMARY KEY(product_id),
    UNIQUE (product_id)
);

-- Crear tabla customers
CREATE TABLE customers (
    customer_id int NOT NULL,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    email varchar(100) NOT NULL,
    join_date DATE,
    location varchar(50),
    PRIMARY KEY(customer_id),
    UNIQUE (customer_id)
);

-- Crear tabla sales
CREATE TABLE sales (
    sale_id int,
    product_id int,
    customer_id int,
    quantity_sold int,
    sale_date DATE,
    total_price DECIMAL(10, 2),
    PRIMARY KEY(sale_id)
);

-- Cargar datos en la tabla products
LOAD DATA LOCAL INFILE '/home/delil/Documentos/Portafolio_DS/Articulos_deportivos/raw_data/productos.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(`product_id`, `product_name`, `category`, `price`, `stock_quantity`);

-- Cargar datos en la tabla customers
LOAD DATA LOCAL INFILE '/home/delil/Documentos/Portafolio_DS/Articulos_deportivos/raw_data/clientes_actualizado.csv' 
INTO TABLE customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(`customer_id`, `first_name`, `last_name`, `email`, `join_date`, `location`);


-- Cargar datos en la tabla sales
LOAD DATA LOCAL INFILE '/home/delil/Documentos/Portafolio_DS/Articulos_deportivos/raw_data/ventas.csv' 
INTO TABLE sales 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS 
(`sale_id`, `product_id`, `customer_id`, `quantity_sold`, `sale_date`, `total_price`);

-- Añadir llaves foráneas
ALTER TABLE sales
ADD FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE sales
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Top 5 productos más vendidos en cantidad
SELECT products.product_name, SUM(sales.quantity_sold) AS number_of_sales, SUM(sales.total_price) AS total_sold
FROM products
JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY number_of_sales DESC
LIMIT 5;

-- Top 5 productos más vendidos en valores monetarios
SELECT products.product_name, SUM(sales.total_price) AS total_sold, SUM(sales.quantity_sold) AS number_of_sales
FROM products
JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_name
ORDER BY total_sold DESC
LIMIT 5;

-- Departamento que genera más ingresos y número de ventas por departamento
SELECT products.category, SUM(sales.total_price) AS total_per_category, SUM(sales.quantity_sold) AS number_per_category
FROM products
JOIN sales ON products.product_id = sales.product_id
GROUP BY products.category
ORDER BY total_per_category DESC;

-- Clientes más frecuentes (Top 10)
SELECT CONCAT(customers.first_name,' ',customers.last_name) AS fullname, COUNT(sales.customer_id) AS sales_per_customer
FROM customers
JOIN sales ON customers.customer_id = sales.customer_id
GROUP BY fullname
ORDER BY sales_per_customer DESC
LIMIT 10;

-- Clientes que han generado más ingresos (Top 10)
SELECT CONCAT(customers.first_name,' ',customers.last_name) AS fullname, SUM(sales.total_price) AS total_per_customer
FROM customers
JOIN sales ON customers.customer_id = sales.customer_id
GROUP BY fullname
ORDER BY total_per_customer DESC
LIMIT 10;

-- Actividad por día de la semana
SELECT DAYNAME(sale_date) AS week_day, COUNT(*) AS total_sales
FROM sales
GROUP BY week_day
ORDER BY FIELD(week_day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Número de compras por estado
SELECT customers.location, COUNT(customers.location) AS purchases_by_state, SUM(sales.total_price) AS total_by_state
FROM customers
JOIN sales ON customers.customer_id = sales.customer_id
GROUP BY customers.location
ORDER BY purchases_by_state DESC;
