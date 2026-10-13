-- Agribank of Namibia members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    loan_account_number VARCHAR(30) NOT NULL UNIQUE,   -- Agribank's ref column
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

-- Seed data for Agribank of Namibia
INSERT INTO members (id_number, loan_account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('75040400123', 'AGB-0001', 'Hendrik', 'Ontiku', '1975-04-04', 'M', '+264 81 111 2222', 'h.ontiku@email.com', '101 Independence Ave, Windhoek', 'Agribank of Namibia', '2019-03-15', 62000.00, 'Active'),
('80050500234', 'AGB-0002', 'Maria', 'Neumbo', '1980-05-05', 'F', '+264 81 222 3333', 'm.neumbo@email.com', '202 Sam Nujoma Dr, Windhoek', 'Agribank of Namibia', '2020-07-22', 48500.50, 'Active'),
('82060600345', 'AGB-0003', 'Johan', 'Van Wyk', '1982-06-06', 'M', '+264 81 333 4444', 'j.vanwyk@email.com', '303 Mandela Street, Swakopmund', 'Agribank of Namibia', '2021-01-10', 39750.75, 'Active'),
('88070700456', 'AGB-0004', 'Frieda', 'Haikali', '1988-07-07', 'F', '+264 81 444 5555', 'f.haikali@email.com', '404 Gerehu Street, Windhoek', 'Agribank of Namibia', '2020-11-30', 35900.25, 'Active'),
('93080800567', 'AGB-0005', 'Tuhafeni', 'Ndadi', '1993-08-08', 'M', '+264 81 555 6666', 't.ndadi@email.com', '505 Maerua Mall, Windhoek', 'Agribank of Namibia', '2022-02-14', 24800.00, 'Active');