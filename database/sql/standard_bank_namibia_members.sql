-- Standard Bank Namibia members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    account_number VARCHAR(30) NOT NULL UNIQUE,   -- Standard Bank's ref column
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

-- Seed data for Standard Bank Namibia
INSERT INTO members (id_number, account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('80010100123', 'SBN-0001', 'Helena', 'Kazondiqua', '1980-01-01', 'F', '+264 81 111 2222', 'h.kazondiqua@email.com', '101 Independence Ave, Windhoek', 'Standard Bank Namibia', '2019-05-15', 55000.00, 'Active'),
('85020200234', 'SBN-0002', 'Dirk', 'Hendrik', '1985-02-02', 'M', '+264 81 222 3333', 'd.hendrik@email.com', '202 Sam Nujoma Dr, Windhoek', 'Standard Bank Namibia', '2020-08-22', 41500.50, 'Active'),
('88030300345', 'SBN-0003', 'Brenda', 'Makaula', '1988-03-03', 'F', '+264 81 333 4444', 'b.makaula@email.com', '303 Mandela Street, Swakopmund', 'Standard Bank Namibia', '2021-01-10', 32750.75, 'Active'),
('92040400456', 'SBN-0004', 'Tuutalik', 'Nashilongo', '1992-04-04', 'M', '+264 81 444 5555', 't.nashilongo@email.com', '404 Gerehu Street, Windhoek', 'Standard Bank Namibia', '2020-11-30', 28900.25, 'Active'),
('87050500567', 'SBN-0005', 'Sacky', 'Shifitoka', '1987-05-05', 'F', '+264 81 555 6666', 's.shifitoka@email.com', '505 Maerua Mall, Windhoek', 'Standard Bank Namibia', '2022-02-14', 37800.00, 'Active');