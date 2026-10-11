-- Nimbus Pension Fund members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    certificate_number  VARCHAR(30) NOT NULL UNIQUE,   -- Nimbus's ref column
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

-- Seed data for Nimbus Pension Fund
INSERT INTO members (id_number, certificate_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('90010100123', 'NMB-0001', 'John', 'Namibian', '1990-01-01', 'M', '+264 81 123 4567', 'john.namibian@email.com', '123 Independence Ave, Windhoek', 'Government of Namibia', '2020-01-15', 15000.00, 'Active'),
('90020200234', 'NMB-0002', 'Mary', 'Katjimune', '1990-02-02', 'F', '+264 81 234 5678', 'm.katjimune@email.com', '456 Sam Nujoma Dr, Windhoek', 'Ministry of Education', '2020-02-20', 22500.50, 'Active'),
('85030300345', 'NMB-0003', 'Peter', 'Shilongo', '1985-03-03', 'M', '+264 81 345 6789', 'p.s hilongo@email.com', '789 Mandela Street, Swakopmund', 'NamPort Authority', '2019-11-30', 35000.75, 'Active'),
('92040400456', 'NMB-0004', 'Grace', 'Ngavetene', '1992-04-04', 'F', '+264 81 456 7890', 'g.ngavetene@email.com', '321 Gerehu Street, Windhoek', 'Bank of Namibia', '2021-03-10', 18250.25, 'Active'),
('88050500567', 'NMB-0005', 'Thomas', 'Kanku', '1988-05-05', 'M', '+264 81 567 8901', 't.kanku@email.com', '654 Maerua Mall, Windhoek', 'Namibia Breweries', '2020-07-22', 42000.00, 'Active');