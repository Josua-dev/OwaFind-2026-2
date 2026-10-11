-- Metropolitan Namibia members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    certificate_number VARCHAR(30) NOT NULL UNIQUE,   -- Metropolitan's ref column
    first_name     VARCHAR(60),
    last_name      VARCHAR(60),
    date_of_birth  DATE,
    gender         ENUM('M','F','O') DEFAULT 'O',
    phone          VARCHAR(20),
    email          VARCHAR(100),
    address        VARCHAR(255),
    employer       VARCHAR(120),
    date_joined    DATE,
    date_left      DATE NULL,
    balance_nad    DECIMAL(14,2) DEFAULT 0.00,
    status         ENUM('Active','Dormant','Paid Out','Deceased') DEFAULT 'Active',
    last_updated   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id     (id_number),
    INDEX idx_name   (last_name, first_name),
    INDEX idx_status (status)
);

-- Seed data for Metropolitan Namibia
INSERT INTO members (id_number, certificate_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('84020200678', 'MET-0001', 'David', 'Goraseb', '1984-02-02', 'M', '+264 81 111 2222', 'd.goraseb@email.com', '202 Independence Ave, Windhoek', 'Metropolitan Namibia', '2019-06-15', 48500.00, 'Active'),
('88030300789', 'MET-0002', 'Eliza', 'Kamati', '1988-03-03', 'F', '+264 81 222 3333', 'e.kamati@email.com', '303 Sam Nujoma Dr, Windhoek', 'Metropolitan Namibia', '2020-08-22', 32750.50, 'Active'),
('90040400890', 'MET-0003', 'James', 'Xoagub', '1990-04-04', 'M', '+264 81 333 4444', 'j.xoagub@email.com', '404 Mandela Street, Swakopmund', 'Metropolitan Namibia', '2019-12-03', 40100.75, 'Active'),
('87050500901', 'MET-0004', 'Frieda', 'Mbako', '1987-05-05', 'F', '+264 81 444 5555', 'f.mbako@email.com', '505 Gerehu Street, Windhoek', 'Metropolitan Namibia', '2021-04-18', 26900.25, 'Active'),
('92060601012', 'MET-0005', 'Abner', 'Xoagub', '1992-06-06', 'M', '+264 81 555 6666', 'a.xoagub@email.com', '606 Maerua Mall, Windhoek', 'Metropolitan Namibia', '2020-01-30', 43400.00, 'Active');