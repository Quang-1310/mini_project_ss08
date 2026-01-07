CREATE DATABASE mini_project_ss08;
USE mini_project_ss08;

-- Xóa bảng nếu đã tồn tại (để chạy lại nhiều lần)
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS guests;

-- Bảng khách hàng
CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_name VARCHAR(100),
    phone VARCHAR(20)
);

-- Bảng phòng
CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_type VARCHAR(50),
    price_per_day DECIMAL(10,0)
);

-- Bảng đặt phòng
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

INSERT INTO guests (guest_name, phone) VALUES
('Nguyễn Văn An', '0901111111'),
('Trần Thị Bình', '0902222222'),
('Lê Văn Cường', '0903333333'),
('Phạm Thị Dung', '0904444444'),
('Hoàng Văn Em', '0905555555');

INSERT INTO rooms (room_type, price_per_day) VALUES
('Standard', 500000),
('Standard', 500000),
('Deluxe', 800000),
('Deluxe', 800000),
('VIP', 1500000),
('VIP', 2000000);

INSERT INTO bookings (guest_id, room_id, check_in, check_out) VALUES
(1, 1, '2024-01-10', '2024-01-12'), -- 2 ngày
(1, 3, '2024-03-05', '2024-03-10'), -- 5 ngày
(2, 2, '2024-02-01', '2024-02-03'), -- 2 ngày
(2, 5, '2024-04-15', '2024-04-18'), -- 3 ngày
(3, 4, '2023-12-20', '2023-12-25'), -- 5 ngày
(3, 6, '2024-05-01', '2024-05-06'), -- 5 ngày
(4, 1, '2024-06-10', '2024-06-11'); -- 1 ngày



-- PHẦN I
-- Liệt kê tên khách và số điện thoại của tất cả khách hàng
SELECT guest_name 'Tên khách hàng', phone 'Số điện thoại' FROM guests;

-- Liệt kê các loại phòng khác nhau trong khách sạn
SELECT distinct room_type 'Loại phòng' FROM rooms;  

-- Hiển thị loại phòng và giá thuê theo ngày, sắp xếp theo giá tăng dần
SELECT room_type 'Loại phòng', price_per_day 'Giá thuê' FROM rooms order by price_per_day asc;  

-- Hiển thị các phòng có giá thuê lớn hơn 1.000.000
SELECT room_type 'Loại phòng', price_per_day 'Giá thuê' FROM rooms where price_per_day > 1000000;  

-- Liệt kê các lần đặt phòng diễn ra trong năm 2024
SELECt * from bookings where check_in like '2024%';

-- Cho biết số lượng phòng của từng loại phòng
SELECT room_type as 'Loại phòng', COUNT(room_type) as 'Tổng số phòng'
FROM rooms
GROUP BY room_type;

-- PHẦN II 
-- Hãy liệt kê danh sách các lần đặt phòng, Với mỗi lần đặt phòng, hãy hiển thị Tên khách hàng, Loại phòng đã đặt, Ngày nhận phòng (check_in)
SELECT g.guest_name AS 'Tên khách hàng', r.room_type AS 'Loại phòng đặt', b.check_in AS 'Ngày nhận phòng'
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id;

-- Cho biết mỗi khách đã đặt phòng bao nhiêu lần
SELECT g.guest_name as 'Tên khách hàng', COUNT(b.guest_id) as 'Số lần đặt phòng'
FROM guests as g
JOIN bookings as b ON b.guest_id = g.guest_id
GROUP BY b.guest_id;

-- Tính doanh thu của mỗi phòng, với công thức: “Doanh thu = số ngày ở× giá thuê theo ngày”
SELECT  b.booking_id 'ID phòng', g.guest_name 'Tên khách hàng', r.room_type 'Loại phòng',
    DATEDIFF(b.check_out, b.check_in) AS 'Số ngày ở',
    (DATEDIFF(b.check_out, b.check_in) * r.price_per_day) AS 'Doanh thu'
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id;

-- Hiển thị tổng doanh thu của từng loại phòng
SELECT r.room_type AS 'Loại phòng', SUM(DATEDIFF(b.check_out, b.check_in) * r.price_per_day) AS 'Tổng doanh thu'
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
GROUP BY r.room_type;

-- Tìm những khách đã đặt phòng từ 2 lần trở lên
SELECT g.guest_name as 'Tên khách hàng', COUNT(b.guest_id) as 'Số lần đặt phòng'
FROM guests as g
JOIN bookings as b ON b.guest_id = g.guest_id
GROUP BY b.guest_id
HAVING COUNT(b.guest_id) >= 2;

-- Tìm loại phòng có số lượt đặt phòng nhiều nhất