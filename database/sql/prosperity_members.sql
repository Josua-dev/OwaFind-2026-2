-- Prosperity Life members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    account_number VARCHAR(30) NOT NULL UNIQUE,   -- Prosperity's ref column
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

-- Seed data for Prosperity Life
INSERT INTO members (id_number, account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('91060600678', 'PROS-0001', 'Samuel', 'Shanghala', '1991-06-06', 'M', '+264 81 678 9012', 's.shanghala@email.com', '987 Independence Ave, Windhoek', 'Standard Bank Namibia', '2020-04-18', 28500.00, 'Active'),
('89070700789', 'PROS-0002', 'Elisa', 'Kazapua', '1989-07-07', 'F', '+264 81 789 0123', 'e.kazapua@email.com', '654 Fidel Castro St, Windhoek', 'Paratus Telecom', '2019-09-12', 33750.50, 'Active'),
('93080800890', 'PROS-0003', 'David', 'Goraseb', '1993-08-08', 'M', '+264 81 890 1234', 'd.goraseb@email.com', '321 Ondonga Street, Ongwediva', 'Oshakati Town Council', '2021-01-05', 19200.75, 'Active'),
('87090900901', 'PROS-0004', 'Frances', 'Goraseb', '1987-09-09', 'F', '+264 81 901 2345', 'f.goraseb@email.com', '147 Omulunga Road, Oshakati', 'Ministry of Health', '2020-11-30', 27800.25, 'Active'),
('94101001012', 'PROS-0005', 'Mathews', 'Tjongarero', '1994-10-10', 'M', '+264 81 012 3456', 'm.tjongarero@email.com', '258 Airport Road, Walvis Bay', 'Namibian Ports Authority', '2022-02-14', 15600.00, 'Active');