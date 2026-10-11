-- Nedbank Namibia members table
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    policy_number  VARCHAR(30) NOT NULL UNIQUE,   -- Nedbank's ref column
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

-- Seed data for Nedbank Namibia
INSERT INTO members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer, date_joined, balance_nad, status) VALUES
('82040400567', 'NED-0001', 'Angela', 'Smith', '1982-04-04', 'F', '+264 81 111 2222', 'a.smith@email.com', '101 Kavango Street, Windhoek', 'Nedbank Namibia', '2019-03-15', 52000.00, 'Active'),
('88050500678', 'NED-0002', 'Martin', 'Ndadi', '1988-05-05', 'M', '+264 81 222 3333', 'm.ndadi@email.com', '202 Independence Ave, Windhoek', 'Nedbank Namibia', '2020-07-22', 38500.50, 'Active'),
('90060600789', 'NED-0003', 'Faith', 'Kanyetu', '1990-06-06', 'F', '+264 81 333 4444', 'f.kanyetu@email.com', '303 Fidel Castro St, Windhoek', 'Nedbank Namibia', '2021-01-10', 29750.75, 'Active'),
('85070700890', 'NED-0004', 'Ockie', 'Karuuombe', '1985-07-07', 'M', '+264 81 444 5555', 'o.karuombe@email.com', '404 Maerua Mall, Windhoek', 'Nedbank Namibia', '2019-11-05', 47200.25, 'Active'),
('93080800901', 'NED-0005', 'Tupewa', 'Shifotoka', '1993-08-08', 'M', '+264 81 555 6666', 't.shifotoka@email.com', '505 Oniipa Road, Ondangwa', 'Nedbank Namibia', '2022-02-14', 22800.00, 'Active');