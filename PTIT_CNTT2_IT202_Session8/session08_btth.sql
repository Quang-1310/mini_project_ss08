DROP database session08_mini_project;
CREATE database session08_mini_project;

use session08_mini_project;

CREATE table customers(
	customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null unique
);

CREATE table categories(
	category_id int primary key auto_increment,
    category_name varchar(255) not null unique
);

CREATE table products(
	product_id int primary key auto_increment,
	category_id int not null,
    product_name varchar(255) not null unique,
    price decimal(10,2) not null check(price > 0)
);

CREATE table orders(
	order_id int primary key auto_increment,
    customer_id int not null,
    order_date Datetime,
    status enum('pending', 'completed', 'cancel')
);

CREATE table order_items(
	order_item_id int primary key auto_increment,
    order_id int,
    product_id int,
    quantity int not null check(quantity > 0)
);

INSERT INTO customers (customer_name, email, phone) VALUES
('Nguyen Van A', 'a.nguyen@gmail.com', '0901234567'),
('Tran Thi B', 'b.tran@gmail.com', '0912345678'),
('Le Van C', 'c.le@gmail.com', '0923456789'),
('Pham Minh D', 'd.pham@gmail.com', '0934567890'),
('Hoang Thi E', 'e.hoang@gmail.com', '0945678901'),
('Vu Van F', 'f.vu@gmail.com', '0956789012'),
('Dang Thi G', 'g.dang@gmail.com', '0967890123'),
('Bui Van H', 'h.bui@gmail.com', '0978901234');

INSERT INTO categories (category_name) VALUES
('Điện thoại'),
('Laptop'),
('Máy tính bảng'),
('Phụ kiện'),
('Âm thanh'),
('Đồng hồ'),
('Máy ảnh'),
('Đồ gia dụng');

INSERT INTO products (category_id, product_name, price) VALUES
(1, 'iPhone 15 Pro Max', 34990000),
(1, 'Samsung Galaxy S24', 22000000),
(2, 'MacBook Air M3', 27500000),
(2, 'Dell XPS 13', 31000000),
(3, 'iPad Pro M2', 19000000),
(4, 'Sạc dự phòng 20000mAh', 850000),
(5, 'Tai nghe Sony WH-1000XM5', 6500000),
(6, 'Apple Watch Series 9', 10500000);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2024-03-01 10:30:00', 'completed'),
(2, '2024-03-02 14:15:00', 'pending'),
(3, '2024-03-03 09:00:00', 'completed'),
(4, '2024-03-04 16:45:00', 'cancel'),
(1, '2024-03-05 11:20:00', 'completed'),
(2, '2024-03-06 13:10:00', 'pending'),
(7, '2024-03-07 15:30:00', 'completed'),
(8, '2024-03-08 08:45:00', 'completed');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1), 
(2, 3, 1),
(3, 7, 2), 
(5, 2, 1), 
(5, 6, 3), 
(7, 5, 1), 
(8, 8, 1), 
(8, 4, 1); 

-- PHẦN A
-- Lấy danh sách tất cả danh mục sản phẩm trong hệ thống.
SELECT * FROM categories;

-- Lấy danh sách đơn hàng có trạng thái là COMPLETED
SELECT * FROM orders 
WHERE status = 'completed';

-- Lấy danh sách sản phẩm và sắp xếp theo giá giảm dần
SELECT * FROM products 
ORDER BY price DESC;

-- Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
SELECT * FROM products 
ORDER BY price DESC 
LIMIT 5 OFFSET 2;

-- PHẦN B
-- Lấy danh sách sản phẩm kèm tên danh mục
SELECT product_name, category_name 
FROM products as p
JOIN categories as c ON p.category_id = c.category_id;

-- Lấy danh sách đơn hàng
SELECT order_id, order_date, customer_name, status
FROM orders as o
JOIN customers as c ON o.customer_id = c.customer_id;

-- Tính tổng số lượng sản phẩm trong từng đơn hàng
SELECT order_id, SUM(quantity)
FROM order_items
GROUP BY order_id;

-- Thống kê số đơn hàng của mỗi khách hàng
SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name;

-- Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2;

-- Thống kê giá trung bình, thấp nhất và cao nhất của sản phẩm theo danh mục
SELECT c.category_name, AVG(p.price) AS average_price, MIN(p.price) AS min_price, MAX(p.price) AS max_price
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;

-- PHẦN C
-- Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT * 
FROM products 
WHERE price > (SELECT avg(price) FROM products);

-- Lấy danh sách khách hàng đã từng đặt ít nhất một đơn hàng
SELECT * 
FROM customers
WHERE customer_id in (SELECT o.customer_id from orders as o group by o.customer_id);

-- Lấy đơn hàng có tổng số lượng sản phẩm lớn nhất.
SELECT order_id, SUM(quantity) as total
FROM order_items 
GROUP BY order_id
HAVING SUM(quantity) = (
						SELECT MAX(total)
						FROM (
							SELECT order_id, SUM(quantity) as total
							FROM order_items 
							GROUP BY order_id
						) as table_total_product
);

-- Lấy tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category_id IN (
    SELECT category_id
    FROM products
    GROUP BY category_id
    HAVING AVG(price) = (
        SELECT MAX(avg_price)
        FROM (
            SELECT AVG(price) AS avg_price 
            FROM products 
            GROUP BY category_id
        ) AS temp_avg
    )
);

-- Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng
SELECT 
    c.customer_name,(
						SELECT SUM(oi.quantity)
						FROM order_items oi
						WHERE oi.order_id IN (
							SELECT o.order_id 
							FROM orders o 
							WHERE o.customer_id = c.customer_id
						)
    ) AS total_product
FROM customers c;

-- Viết lại truy vấn lấy sản phẩm có giá cao nhất
SELECT *
FROM products
WHERE price = (
    SELECT MAX(price) 
    FROM products
);

