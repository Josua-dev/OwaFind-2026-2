-- Prudential Namibia members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    policy_number  VARCHAR(30) NOT NULL UNIQUE,   -- Prudential's ref column
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

-- Seed data for Prudential Namibia
INSERT INTO members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('82010100123', 'PRU-0001', 'Samuel', 'Nuuyoma', '1982-01-01', 'M', '+264 81 111 2222', 's.nuuyoma@email.com', '111 Independence Ave, Windhoek', 'Prudential Namibia', '2020-05-15', 47500.00, 'Active'),
('87020200234', 'PRU-0002', 'Vilho', 'Shikongo', '1987-02-02', 'M', '+264 81 222 3333', 'v.shikongo@email.com', '202 Sam Nujoma Dr, Windhoek', 'Prudential Namibia', '2019-08-22', 36500.50, 'Active'),
('90030300345', 'PRU-0003', 'Lineekela', 'Matius', '1990-03-03', 'F', '+264 81 333 4444', 'l.matius@email.com', '303 Mandela Street, Swakopmund', 'Prudential Namibia', '2021-01-10', 28750.75, 'Active'),
('85040400456', 'PRU-0004', 'Johanna', 'Mouton', '1985-04-04', 'F', '+264 81 444 5555', 'j.mouton@email.com', '404 Gerehu Street, Windhoek', 'Prudential Namibia', '2020-11-30', 34900.25, 'Active'),
('93050500567', 'PRU-0005', 'Testament', 'Naras', '1993-05-05', 'M', '+264 81 555 6666', 't.naras@email.com', '505 Maerua Mall, Windhoek', 'Prudential Namibia', '2022-02-14', 22800.00, 'Active');