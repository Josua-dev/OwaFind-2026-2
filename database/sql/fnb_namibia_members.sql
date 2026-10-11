-- First National Bank Namibia members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    policy_number  VARCHAR(30) NOT NULL UNIQUE,   -- FNB's ref column
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

-- Seed data for First National Bank Namibia
INSERT INTO members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('81060600123', 'FNB-0001', 'Angela', 'Kuine', '1981-06-06', 'F', '+264 81 666 7777', 'a.kuine@email.com', '606 Independence Ave, Windhoek', 'FNB Namibia', '2020-04-18', 49500.00, 'Active'),
('86070700234', 'FNB-0002', 'Johannes', 'Goraseb', '1986-07-07', 'M', '+264 81 777 8888', 'j.goraseb@email.com', '707 Sam Nujoma Dr, Windhoek', 'FNB Namibia', '2019-09-12', 35250.50, 'Active'),
('89080800345', 'FNB-0003', 'Elisa', 'Kamati', '1989-08-08', 'F', '+264 81 888 9999', 'e.kamati@email.com', '808 Mandela Street, Swakopmund', 'FNB Namibia', '2021-01-05', 26400.75, 'Active'),
('93090900456', 'FNB-0004', 'Filipus', 'Neshiku', '1993-09-09', 'M', '+264 81 999 0000', 'f.neshiku@email.com', '909 Gerehu Street, Windhoek', 'FNB Namibia', '2020-11-30', 22100.25, 'Active'),
('84101000567', 'FNB-0005', 'Lazarus', 'Sheriff', '1984-10-10', 'M', '+264 81 000 1111', 'l.sheriff@email.com', '1010 Airport Road, Walvis Bay', 'FNB Namibia', '2022-02-14', 41800.00, 'Active');