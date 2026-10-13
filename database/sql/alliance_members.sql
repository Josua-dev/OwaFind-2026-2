-- Alliance Insurance members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    policy_number  VARCHAR(30) NOT NULL UNIQUE,   -- Alliance's ref column
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

-- Seed data for Alliance Insurance
INSERT INTO members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('78020200123', 'ALL-0001', 'Lazarus', 'Shipanga', '1978-02-02', 'M', '+264 81 666 7777', 'l.shipanga@email.com', '606 Independence Ave, Windhoek', 'Alliance Insurance', '2020-04-18', 53500.00, 'Active'),
('83030300234', 'ALL-0002', 'Anna', 'Shigwedha', '1983-03-03', 'F', '+264 81 777 8888', 'a.shigwedha@email.com', '707 Sam Nujoma Dr, Windhoek', 'Alliance Insurance', '2019-09-12', 40250.50, 'Active'),
('86040400345', 'ALL-0003', 'Petrus', 'Van Neel', '1986-04-04', 'M', '+264 81 888 9999', 'p.vanneel@email.com', '808 Mandela Street, Swakopmund', 'Alliance Insurance', '2021-01-05', 31400.75, 'Active'),
('90050500456', 'ALL-0004', 'Elizabeth', 'Khaxas', '1990-05-05', 'F', '+264 81 999 0000', 'e.khaxas@email.com', '909 Gerehu Street, Windhoek', 'Alliance Insurance', '2020-11-30', 27100.25, 'Active'),
('85060600567', 'ALL-0005', 'Henk', 'Van der Merwe', '1985-06-06', 'M', '+264 81 000 1111', 'h.vandermeerwe@email.com', '1010 Airport Road, Walvis Bay', 'Alliance Insurance', '2022-02-14', 45800.00, 'Active');