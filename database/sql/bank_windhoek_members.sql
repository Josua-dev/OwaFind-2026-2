-- Bank Windhoek members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    account_number VARCHAR(30) NOT NULL UNIQUE,   -- Bank Windhoek's ref column
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

-- Seed data for Bank Windhoek
INSERT INTO members (id_number, account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('83090900123', 'BW-0001', 'Hilma', 'Nikanor', '1983-09-09', 'F', '+264 81 666 7777', 'h.nikanor@email.com', '606 Independence Ave, Windhoek', 'Bank Windhoek', '2020-04-18', 33500.00, 'Active'),
('87101000234', 'BW-0002', 'Jerry', 'Goraseb', '1987-10-10', 'M', '+264 81 777 8888', 'j.goraseb@email.com', '707 Sam Nujoma Dr, Windhoek', 'Bank Windhoek', '2019-09-12', 41250.50, 'Active'),
('91111100345', 'BW-0003', 'Sven', 'Von Schmettau', '1991-11-11', 'M', '+264 81 888 9999', 's.vonschmettau@email.com', '808 Mandela Street, Swakopmund', 'Bank Windhoek', '2021-01-05', 24900.75, 'Active'),
('89121200456', 'BW-0004', 'Emma', 'Neumbo', '1989-12-12', 'F', '+264 81 999 0000', 'e.neumbo@email.com', '909 Gerehu Street, Windhoek', 'Bank Windhoek', '2020-11-30', 37800.25, 'Active'),
('95010100567', 'BW-0005', 'Laimi', 'Haihambo', '1995-01-01', 'F', '+264 81 000 1111', 'l.haihambo@email.com', '1010 Airport Road, Walvis Bay', 'Bank Windhoek', '2022-02-14', 18900.00, 'Active');