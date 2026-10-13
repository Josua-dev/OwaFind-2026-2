-- Legacy Insurance members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    policy_number  VARCHAR(30) NOT NULL UNIQUE,   -- Legacy's ref column
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

-- Seed data for Legacy Insurance
INSERT INTO members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('86111101123', 'LEG-0001', 'Patrick', 'Kauma', '1986-11-11', 'M', '+264 81 234 5678', 'p.kauma@email.com', '369 Independence Ave, Windhoek', 'Namibia Statistics Agency', '2019-06-15', 45200.00, 'Active'),
('90121201234', 'LEG-0002', 'Viola', 'Mapelema', '1990-12-12', 'F', '+264 81 345 6789', 'v.mapelema@email.com', '258 Sam Nujoma Dr, Windhoek', 'Telecom Namibia', '2020-08-22', 31500.50, 'Active'),
('88010101345', 'LEG-0003', 'Benjamin', 'Frederiks', '1988-01-01', 'M', '+264 81 456 7890', 'b.frederiks@email.com', '147 Mandela Street, Swakopmund', 'Swakopmund Municipality', '2019-12-03', 38900.75, 'Active'),
('91020201456', 'LEG-0004', 'Christine', 'Haiduwa', '1991-02-02', 'F', '+264 81 567 8901', 'c.haiduwa@email.com', '963 Gerehu Street, Windhoek', 'Bank Windhoek', '2021-04-18', 24600.25, 'Active'),
('89030301567', 'LEG-0005', 'Andre', 'Goraseb', '1989-03-03', 'M', '+264 81 678 9012', 'a.goraseb@email.com', '852 Maerua Mall, Windhoek', 'First National Bank Namibia', '2020-01-30', 41300.00, 'Active');