-- Namtex Pension Fund members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    fund_number    VARCHAR(30) NOT NULL UNIQUE,   -- Namtex's ref column
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

-- Seed data for Namtex Pension Fund
INSERT INTO members (id_number, fund_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('86080800123', 'NAMTEX-001', 'Maria', 'Neumbo', '1986-08-08', 'F', '+264 81 666 7777', 'm.neumbo@email.com', '707 Independence Ave, Windhoek', 'Namibia Textile Mills', '2020-03-10', 39500.00, 'Active'),
('89090900234', 'NAMTEX-002', 'Samuel', 'Goraseb', '1989-09-09', 'M', '+264 81 777 8888', 's.goraseb@email.com', '808 Sam Nujoma Dr, Windhoek', 'Namibia Textile Mills', '2019-10-22', 34250.50, 'Active'),
('91101000345', 'NAMTEX-003', 'Letticia', 'Katjimune', '1991-10-10', 'F', '+264 81 888 9999', 'l.katjimune@email.com', '909 Mandela Street, Swakopmund', 'Namibia Textile Mills', '2021-02-05', 27400.75, 'Active'),
('85111100456', 'NAMTEX-004', 'Timothy', 'Kangowa', '1985-11-11', 'M', '+264 81 999 0000', 't.kangowa@email.com', '1010 Gerehu Street, Windhoek', 'Namibia Textile Mills', '2020-12-30', 40300.25, 'Active'),
('93121200567', 'NAMTEX-005', 'Winston', 'Goraseb', '1993-12-12', 'M', '+264 81 000 1111', 'w.goraseb@email.com', '1111 Airport Road, Walvis Bay', 'Namibia Textile Mills', '2022-03-15', 21900.00, 'Active');