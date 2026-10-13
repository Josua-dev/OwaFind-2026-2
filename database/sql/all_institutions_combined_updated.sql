-- Combined SQL script for all 15 institutions (UPDATED with employer_number field)
-- Each institution has its own table named {institution}_members

-- 1. GIPF (Government Institutions Pension Fund)
CREATE TABLE IF NOT EXISTS gipf_members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    fund_number    VARCHAR(30) NOT NULL UNIQUE,   -- GIPF's ref column
    first_name     VARCHAR(60),
    last_name      VARCHAR(60),
    date_of_birth  DATE,
    gender         ENUM('M','F','O') DEFAULT 'O',
    phone          VARCHAR(20),
    email          VARCHAR(100),
    address        VARCHAR(255),
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
    date_joined    DATE,
    date_left      DATE NULL,
    balance_nad    DECIMAL(14,2) DEFAULT 0.00,
    status         ENUM('Active','Dormant','Paid Out','Deceased') DEFAULT 'Active',
    last_updated   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id     (id_number),
    INDEX idx_name   (last_name, first_name),
    INDEX idx_status (status)
);

-- Seed data for GIPF
INSERT INTO gipf_members (id_number, fund_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('70010100123', 'GIPF-0001', 'Samuel', 'Nuuyoma', '1970-01-01', 'M', '+264 81 111 2222', 's.nuuyoma@email.com', '101 Independence Ave, Windhoek', 'GOV-001', 'Government of Namibia', '2019-01-15', 75000.00, 'Active'),
('75020200234', 'GIPF-0002', 'Hilma', 'Nikanor', '1975-02-02', 'F', '+264 81 222 3333', 'h.nikanor@email.com', '202 Sam Nujoma Dr, Windhoek', 'MOE-005', 'Ministry of Education', '2020-03-22', 68500.50, 'Active'),
('80030300345', 'GIPF-0003', 'Petrus', 'Van Neel', '1980-03-03', 'M', '+264 81 333 4444', 'p.vanneel@email.com', '303 Mandela Street, Swakopmund', 'MOW-003', 'Ministry of Works', '2021-01-10', 52750.75, 'Active'),
('82040400456', 'GIPF-0004', 'Elizabeth', 'Khaxas', '1982-04-04', 'F', '+264 81 444 5555', 'e.khaxas@email.com', '404 Gerehu Street, Windhoek', 'MOH-012', 'Ministry of Health', '2020-11-30', 45900.25, 'Active'),
('88050500567', 'GIPF-0005', 'Henk', 'Van der Merwe', '1988-05-05', 'M', '+264 81 555 6666', 'h.vandermeerwe@email.com', '505 Maerua Mall, Windhoek', 'NSA-007', 'Namibia Statistics Agency', '2022-02-14', 37800.00, 'Active');

-- 2. SANLAM (Sanlam Namibia)
CREATE TABLE IF NOT EXISTS sanlam_members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    policy_number  VARCHAR(30) NOT NULL UNIQUE,   -- Sanlam's ref column
    first_name     VARCHAR(60),
    last_name      VARCHAR(60),
    date_of_birth  DATE,
    gender         ENUM('M','F','O') DEFAULT 'O',
    phone          VARCHAR(20),
    email          VARCHAR(100),
    address        VARCHAR(255),
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
    date_joined    DATE,
    date_left      DATE NULL,
    balance_nad    DECIMAL(14,2) DEFAULT 0.00,
    status         ENUM('Active','Dormant','Paid Out','Deceased') DEFAULT 'Active',
    last_updated   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id     (id_number),
    INDEX idx_name   (last_name, first_name),
    INDEX idx_status (status)
);

-- Seed data for Sanlam Namibia
INSERT INTO sanlam_members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('72060600123', 'SAN-0001', 'Angela', 'Kuine', '1972-06-06', 'F', '+264 81 666 7777', 'a.kuine@email.com', '606 Independence Ave, Windhoek', 'SAN-HEAD', 'Sanlam Namibia Head Office', '2019-04-18', 82000.00, 'Active'),
('78070700234', 'SAN-0002', 'Johannes', 'Goraseb', '1978-07-07', 'M', '+264 81 777 8888', 'j.goraseb@email.com', '707 Sam Nujoma Dr, Windhoek', 'SAN-WHK', 'Sanlam Namibia Windhoek Branch', '2020-09-12', 71250.50, 'Active'),
('83080800345', 'SAN-0003', 'Elisa', 'Kamati', '1983-08-08', 'F', '+264 81 888 9999', 'e.kamati@email.com', '808 Mandela Street, Swakopmund', 'SAN-SWK', 'Sanlam Namibia Swakopmund Branch', '2021-01-05', 60400.75, 'Active'),
('86090900456', 'SAN-0004', 'Filipus', 'Neshiku', '1986-09-09', 'M', '+264 81 999 0000', 'f.neshiku@email.com', '909 Gerehu Street, Windhoek', 'SAN-WVB', 'Sanlam Namibia Walvis Bay Branch', '2020-11-30', 52100.25, 'Active'),
('90101000567', 'SAN-0005', 'Lazarus', 'Sheriff', '1990-10-10', 'M', '+264 81 000 1111', 'l.sheriff@email.com', '1010 Airport Road, Walvis Bay', 'SAN-WVB', 'Sanlam Namibia Walvis Bay Branch', '2022-02-14', 43800.00, 'Active');

-- 3. OLD MUTUAL (Old Mutual Namibia)
CREATE TABLE IF NOT EXISTS oldmutual_members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    policy_number  VARCHAR(30) NOT NULL UNIQUE,   -- Old Mutual's ref column
    first_name     VARCHAR(60),
    last_name      VARCHAR(60),
    date_of_birth  DATE,
    gender         ENUM('M','F','O') DEFAULT 'O',
    phone          VARCHAR(20),
    email          VARCHAR(100),
    address        VARCHAR(255),
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
    date_joined    DATE,
    date_left      DATE NULL,
    balance_nad    DECIMAL(14,2) DEFAULT 0.00,
    status         ENUM('Active','Dormant','Paid Out','Deceased') DEFAULT 'Active',
    last_updated   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id     (id_number),
    INDEX idx_name   (last_name, first_name),
    INDEX idx_status (status)
);

-- Seed data for Old Mutual Namibia
INSERT INTO oldmutual_members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('68010100123', 'OM-0001', 'Helena', 'Kazondiqua', '1968-01-01', 'F', '+264 81 111 2222', 'h.kazondiqua@email.com', '101 Independence Ave, Windhoek', 'OM-HEAD', 'Old Mutual Namibia Head Office', '2019-02-15', 95000.00, 'Active'),
('74020200234', 'OM-0002', 'Dirk', 'Hendrik', '1974-02-02', 'M', '+264 81 222 3333', 'd.hendrik@email.com', '202 Sam Nujoma Dr, Windhoek', 'OM-WINDHOEK', 'Old Mutual Namibia Windhoek', '2020-05-22', 83500.50, 'Active'),
('79030300345', 'OM-0003', 'Brenda', 'Makaula', '1979-03-03', 'F', '+264 81 333 4444', 'b.makaula@email.com', '303 Mandela Street, Swakopmund', 'OM-SWAKOP', 'Old Mutual Namibia Swakopmund', '2021-02-10', 72750.75, 'Active'),
('81040400456', 'OM-0004', 'Tuutalik', 'Nashilongo', '1981-04-04', 'M', '+264 81 444 5555', 't.nashilongo@email.com', '404 Gerehu Street, Windhoek', 'OM-WALVIS', 'Old Mutual Namibia Walvis Bay', '2020-12-30', 61900.25, 'Active'),
('86050500567', 'OM-0005', 'Sacky', 'Shifitoka', '1986-05-05', 'F', '+264 81 555 6666', 's.shifitoka@email.com', '505 Maerua Mall, Windhoek', 'OM-ONGWED', 'Old Mutual Namibia Ongwediva', '2022-03-14', 50800.00, 'Active');

-- 4. NIMBUS (Nimbus Pension Fund)
CREATE TABLE IF NOT EXISTS nimbus_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO nimbus_members (id_number, certificate_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('90010100123', 'NMB-0001', 'John', 'Namibian', '1990-01-01', 'M', '+264 81 123 4567', 'john.namibian@email.com', '123 Independence Ave, Windhoek', 'GOV-001', 'Government of Namibia', '2020-01-15', 15000.00, 'Active'),
('90020200234', 'NMB-0002', 'Mary', 'Katjimune', '1990-02-02', 'F', '+264 81 234 5678', 'm.katjimune@email.com', '456 Sam Nujoma Dr, Windhoek', 'MOE-005', 'Ministry of Education', '2020-02-20', 22500.50, 'Active'),
('85030300345', 'NMB-0003', 'Peter', 'Shilongo', '1985-03-03', 'M', '+264 81 345 6789', 'p.s hilongo@email.com', '789 Mandela Street, Swakopmund', 'NAMPORT', 'NamPort Authority', '2019-11-30', 35000.75, 'Active'),
('92040400456', 'NMB-0004', 'Grace', 'Ngavetene', '1992-04-04', 'F', '+264 81 456 7890', 'g.ngavetene@email.com', '321 Gerehu Street, Windhoek', 'BON-001', 'Bank of Namibia', '2021-03-10', 18250.25, 'Active'),
('88050500567', 'NMB-0005', 'Thomas', 'Kanku', '1988-05-05', 'M', '+264 81 567 8901', 't.kanku@email.com', '654 Maerua Mall, Windhoek', 'NAM-BREW', 'Namibia Breweries', '2020-07-22', 42000.00, 'Active');

-- 5. PROSPERITY (Prosperity Life)
CREATE TABLE IF NOT EXISTS prosperity_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO prosperity_members (id_number, account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('91060600678', 'PROS-0001', 'Samuel', 'Shanghala', '1991-06-06', 'M', '+264 81 678 9012', 's.shanghala@email.com', '987 Independence Ave, Windhoek', 'SBN-001', 'Standard Bank Namibia', '2020-04-18', 28500.00, 'Active'),
('89070700789', 'PROS-0002', 'Elisa', 'Kazapua', '1989-07-07', 'F', '+264 81 789 0123', 'e.kazapua@email.com', '654 Fidel Castro St, Windhoek', 'PARATUS', 'Paratus Telecom', '2019-09-12', 33750.50, 'Active'),
('93080800890', 'PROS-0003', 'David', 'Goraseb', '1993-08-08', 'M', '+264 81 890 1234', 'd.goraseb@email.com', '321 Ondonga Street, Ongwediva', 'OSHIK', 'Oshakati Town Council', '2021-01-05', 19200.75, 'Active'),
('87090900901': 'PROS-0004', 'Frances', 'Goraseb', '1987-09-09', 'F', '+264 81 901 2345', 'f.goraseb@email.com', '147 Omulunga Road, Oshakati', 'MOH-012', 'Ministry of Health', '2020-11-30', 27800.25, 'Active'),
('94101001012': 'PROS-0005', 'Mathews', 'Tjongarero', '1994-10-10', 'M', '+264 81 012 3456', 'm.tjongarero@email.com', '258 Airport Road, Walvis Bay', 'NAMPORT', 'Namibian Ports Authority', '2022-02-14', 15600.00, 'Active');

-- 6. LEGACY (Legacy Insurance)
CREATE TABLE IF NOT EXISTS legacy_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO legacy_members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('86111101123', 'LEG-0001', 'Patrick', 'Kauma', '1986-11-11', 'M', '+264 81 234 5678', 'p.kauma@email.com', '369 Independence Ave, Windhoek', 'NSA-007', 'Namibia Statistics Agency', '2019-06-15', 45200.00, 'Active'),
('90121201234', 'LEG-0002', 'Viola', 'Mapelema', '1990-12-12', 'F', '+264 81 345 6789', 'v.mapelema@email.com', '258 Sam Nujoma Dr, Windhoek', 'TELCOM', 'Telecom Namibia', '2020-08-22', 31500.50, 'Active'),
('88010101345', 'LEG-0003', 'Benjamin', 'Frederiks', '1988-01-01', 'M', '+264 81 456 7890', 'b.frederiks@email.com', '147 Mandela Street, Swakopmund', 'SWK-MUN', 'Swakopmund Municipality', '2019-12-03', 38900.75, 'Active'),
('91020201456': 'LEG-0004', 'Christine', 'Haiduwa', '1991-02-02', 'F', '+264 81 567 8901', 'c.haiduwa@email.com', '963 Gerehu Street, Windhoek', 'BW-001', 'Bank Windhoek', '2021-04-18', 24600.25, 'Active'),
('89030301567': 'LEG-0005', 'Andre', 'Goraseb', '1989-03-03', 'M', '+264 81 678 9012', 'a.goraseb@email.com', '852 Maerua Mall, Windhoek', 'FNB-NAM', 'First National Bank Namibia', '2020-01-30', 41300.00, 'Active');

-- 7. NEDBANK NAMIBIA
CREATE TABLE IF NOT EXISTS nedbank_namibia_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO nedbank_namibia_members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('82040400567', 'NED-0001', 'Angela', 'Smith', '1982-04-04', 'F', '+264 81 111 2222', 'a.smith@email.com', '101 Kavango Street, Windhoek', 'NED-001', 'Nedbank Namibia', '2019-03-15', 52000.00, 'Active'),
('88050500678', 'NED-0002', 'Martin', 'Ndadi', '1988-05-05', 'M', '+264 81 222 3333', 'm.ndadi@email.com', '202 Independence Ave, Windhoek', 'NED-001', 'Nedbank Namibia', '2020-07-22', 38500.50, 'Active'),
('90060600789', 'NED-0003', 'Faith', 'Kanyetu', '1990-06-06', 'F', '+264 81 333 4444', 'f.kanyetu@email.com', '303 Fidel Castro St, Windhoek', 'NED-001', 'Nedbank Namibia', '2021-01-10', 29750.75, 'Active'),
('85070700890', 'NED-0004', 'Ockie', 'Karuuombe', '1985-07-07', 'M', '+264 81 444 5555', 'o.karuombe@email.com', '404 Maerua Mall, Windhoek', 'NED-001', 'Nedbank Namibia', '2019-11-05', 47200.25, 'Active'),
('93080800901', 'NED-0005', 'Tupewa', 'Shifotoka', '1993-08-08', 'M', '+264 81 555 6666', 't.shifotoka@email.com', '505 Oniipa Road, Ondangwa', 'NED-001', 'Nedbank Namibia', '2022-02-14', 22800.00, 'Active');

-- 8. BANK WINDHOEK
CREATE TABLE IF NOT EXISTS bank_windhoek_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO bank_windhoek_members (id_number, account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('83090900123', 'BW-0001', 'Hilma', 'Nikanor', '1983-09-09', 'F', '+264 81 666 7777', 'h.nikanor@email.com', '606 Independence Ave, Windhoek', 'BW-001', 'Bank Windhoek', '2020-04-18', 33500.00, 'Active'),
('87101000234', 'BW-0002', 'Jerry', 'Goraseb', '1987-10-10', 'M', '+264 81 777 8888', 'j.goraseb@email.com', '707 Sam Nujoma Dr, Windhoek', 'BW-001', 'Bank Windhoek', '2019-09-12', 41250.50, 'Active'),
('91111100345', 'BW-0003', 'Sven', 'Von Schmettau', '1991-11-11', 'M', '+264 81 888 9999', 's.vonschmettau@email.com', '808 Mandela Street, Swakopmund', 'BW-001', 'Bank Windhoek', '2021-01-05', 24900.75, 'Active'),
('89121200456': 'BW-0004', 'Emma', 'Neumbo', '1989-12-12', 'F', '+264 81 999 0000', 'e.neumbo@email.com', '909 Gerehu Street, Windhoek', 'BW-001', 'Bank Windhoek', '2020-11-30', 37800.25, 'Active'),
('95010100567': 'BW-0005', 'Laimi', 'Haihambo', '1995-01-01', 'F', '+264 81 000 1111', 'l.haihambo@email.com', '1010 Airport Road, Walvis Bay', 'BW-001', 'Bank Windhoek', '2022-02-14', 18900.00, 'Active');

-- 9. METROPOLITAN NAMIBIA
CREATE TABLE IF NOT EXISTS metropolitan_namibia_members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    certificate_number VARCHAR(30) NOT NULL UNIQUE,   -- Metropolitan's ref column
    first_name     VARCHAR(60),
    last_name      VARCHAR(60),
    date_of_birth  DATE,
    gender         ENUM('M','F','O') DEFAULT 'O',
    phone          VARCHAR(20),
    email          VARCHAR(100),
    address        VARCHAR(255),
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
    date_joined    DATE,
    date_left      DATE NULL,
    balance_nad    DECIMAL(14,2) DEFAULT 0.00,
    status         ENUM('Active','Dormant','Paid Out','Deceased') DEFAULT 'Active',
    last_updated   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id     (id_number),
    INDEX idx_name   (last_name, first_name),
    INDEX idx_status (status)
);

-- Seed data for Metropolitan Namibia
INSERT INTO metropolitan_namibia_members (id_number, certificate_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('84020200678': 'MET-0001', 'David', 'Goraseb', '1984-02-02', 'M', '+264 81 111 2222', 'd.goraseb@email.com', '202 Independence Ave, Windhoek', 'MET-001', 'Metropolitan Namibia', '2019-06-15', 48500.00, 'Active'),
('88030300789': 'MET-0002', 'Eliza', 'Kamati', '1988-03-03', 'F', '+264 81 222 3333', 'e.kamati@email.com', '303 Sam Nujoma Dr, Windhoek', 'MET-001', 'Metropolitan Namibia', '2020-08-22', 32750.50, 'Active'),
('90040400890': 'MET-0003', 'James', 'Xoagub', '1990-04-04', 'M', '+264 81 333 4444', 'j.xoagub@email.com', '404 Mandela Street, Swakopmund', 'MET-001', 'Metropolitan Namibia', '2019-12-03', 40100.75, 'Active'),
('87050500901': 'MET-0004', 'Frieda', 'Mbako', '1987-05-05', 'F', '+264 81 444 5555', 'f.mbako@email.com', '505 Gerehu Street, Windhoek', 'MET-001', 'Metropolitan Namibia', '2021-04-18', 26900.25, 'Active'),
('92060601012': 'MET-0005', 'Abner', 'Xoagub', '1992-06-06', 'M', '+264 81 555 6666', 'a.xoagub@email.com', '606 Maerua Mall, Windhoek', 'MET-001', 'Metropolitan Namibia', '2020-01-30', 43400.00, 'Active');

-- 10. NAMTEX PENSION FUND
CREATE TABLE IF NOT EXISTS namtex_pension_fund_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO namtex_pension_fund_members (id_number, fund_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('86080800123': 'NAMTEX-001', 'Maria', 'Neumbo', '1986-08-08', 'F', '+264 81 666 7777', 'm.neumbo@email.com', '707 Independence Ave, Windhoek', 'NTM-001', 'Namibia Textile Mills', '2020-03-10', 39500.00, 'Active'),
('89090900234': 'NAMTEX-002', 'Samuel', 'Goraseb', '1989-09-09', 'M', '+264 81 777 8888', 's.goraseb@email.com', '808 Sam Nujoma Dr, Windhoek', 'NTM-001', 'Namibia Textile Mills', '2019-10-22', 34250.50, 'Active'),
('91101000345': 'NAMTEX-003', 'Letticia', 'Katjimune', '1991-10-10', 'F', '+264 81 888 9999', 'l.katjimune@email.com', '909 Mandela Street, Swakopmund', 'NTM-001', 'Namibia Textile Mills', '2021-02-05', 27400.75, 'Active'),
('85111100456': 'NAMTEX-004', 'Timothy', 'Kangowa', '1985-11-11', 'M', '+264 81 999 0000', 't.kangowa@email.com', '1010 Gerehu Street, Windhoek', 'NTM-001', 'Namibia Textile Mills', '2020-12-30', 40300.25, 'Active'),
('93121200567': 'NAMTEX-005', 'Winston', 'Goraseb', '1993-12-12', 'M', '+264 81 000 1111', 'w.goraseb@email.com', '1111 Airport Road, Walvis Bay', 'NTM-001', 'Namibia Textile Mills', '2022-03-15', 21900.00, 'Active');

-- 11. STANDARD BANK NAMIBIA
CREATE TABLE IF NOT EXISTS standard_bank_namibia_members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,
    account_number VARCHAR(30) NOT NULL UNIQUE,   -- Standard Bank's ref column
    first_name     VARCHAR(60),
    last_name      VARCHAR(60),
    date_of_birth  DATE,
    gender         ENUM('M','F','O') DEFAULT 'O',
    phone          VARCHAR(20),
    email          VARCHAR(100),
    address        VARCHAR(255),
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
    date_joined    DATE,
    date_left      DATE NULL,
    balance_nad    DECIMAL(14,2) DEFAULT 0.00,
    status         ENUM('Active','Dormant','Paid Out','Deceased') DEFAULT 'Active',
    last_updated   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id     (id_number),
    INDEX idx_name   (last_name, first_name),
    INDEX idx_status (status)
);

-- Seed data for Standard Bank Namibia
INSERT INTO standard_bank_namibia_members (id_number, account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('80010100123': 'SBN-0001', 'Helena', 'Kazondiqua', '1980-01-01', 'F', '+264 81 111 2222', 'h.kazondiqua@email.com', '101 Independence Ave, Windhoek', 'SBN-001', 'Standard Bank Namibia', '2019-05-15', 55000.00, 'Active'),
('85020200234': 'SBN-0002', 'Dirk', 'Hendrik', '1985-02-02', 'M', '+264 81 222 3333', 'd.hendrik@email.com', '202 Independence Ave, Windhoek', 'SBN-001', 'Standard Bank Namibia', '2020-08-22', 41500.50, 'Active'),
('88030300345': 'SBN-0003', 'Brenda', 'Makaula', '1988-03-03', 'F', '+264 81 333 4444', 'b.makaula@email.com', '303 Mandela Street, Swakopmund', 'SBN-001', 'Standard Bank Namibia', '2021-01-10', 32750.75, 'Active'),
('92040400456': 'SBN-0004', 'Tuutalik', 'Nashilongo', '1992-04-04', 'M', '+264 81 444 5555', 't.nashilongo@email.com', '404 Gerehu Street, Windhoek', 'SBN-001', 'Standard Bank Namibia', '2020-11-30', 28900.25, 'Active'),
('87050500567': 'SBN-0005', 'Sacky', 'Shifitoka', '1987-05-05', 'F', '+264 81 555 6666', 's.shifitoka@email.com', '505 Maerua Mall, Windhoek', 'SBN-001', 'Standard Bank Namibia', '2022-02-14', 37800.00, 'Active');

-- 12. FIRST NATIONAL BANK NAMIBIA
CREATE TABLE IF NOT EXISTS fnb_namibia_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO fnb_namibia_members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('81060600123': 'FNB-0001', 'Angela', 'Kuine', '1981-06-06', 'F', '+264 81 666 7777', 'a.kuine@email.com', '606 Independence Ave, Windhoek', 'FNB-NAM', 'FNB Namibia', '2020-04-18', 49500.00, 'Active'),
('86070700234': 'FNB-0002', 'Johannes', 'Goraseb', '1986-07-07', 'M', '+264 81 777 8888', 'j.goraseb@email.com', '707 Sam Nujoma Dr, Windhoek', 'FNB-NAM', 'FNB Namibia', '2019-09-12', 35250.50, 'Active'),
('89080800345': 'FNB-0003', 'Elisa', 'Kamati', '1989-08-08', 'F', '+264 81 888 9999', 'e.kamati@email.com', '808 Mandela Street, Swakopmund', 'FNB-NAM', 'FNB Namibia', '2021-01-05', 26400.75, 'Active'),
('93090900456': 'FNB-0004', 'Filipus', 'Neshiku', '1993-09-09', 'M', '+264 81 999 0000', 'f.neshiku@email.com', '909 Gerehu Street, Windhoek', 'FNB-NAM', 'FNB Namibia', '2020-11-30', 22100.25, 'Active'),
('84101000567': 'FNB-0005', 'Lazarus', 'Sheriff', '1984-10-10', 'M', '+264 81 000 1111', 'l.sheriff@email.com', '1010 Airport Road, Walvis Bay', 'FNB-NAM', 'FNB Namibia', '2022-02-14', 41800.00, 'Active');

-- 13. AGRIBANK OF NAMIBIA
CREATE TABLE IF NOT EXISTS agribank_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO agribank_members (id_number, loan_account_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('75040400123': 'AGB-0001', 'Hendrik', 'Ontiku', '1975-04-04', 'M', '+264 81 111 2222', 'h.ontiku@email.com', '101 Independence Ave, Windhoek', 'AGB-001', 'Agribank of Namibia', '2019-03-15', 62000.00, 'Active'),
('80050500234': 'AGB-0002', 'Maria', 'Neumbo', '1980-05-05', 'F', '+264 81 222 3333', 'm.neumbo@email.com', '202 Sam Nujoma Dr, Windhoek', 'AGB-001', 'Agribank of Namibia', '2020-07-22', 48500.50, 'Active'),
('82060600345': 'AGB-0003', 'Johan', 'Van Wyk', '1982-06-06', 'M', '+264 81 333 4444', 'j.vanwyk@email.com', '303 Mandela Street, Swakopmund', 'AGB-001', 'Agribank of Namibia', '2021-01-10', 39750.75, 'Active'),
('88070700456': 'AGB-0004', 'Frieda', 'Haikali', '1988-07-07', 'F', '+264 81 444 5555', 'f.haikali@email.com', '404 Gerehu Street, Windhoek', 'AGB-001', 'Agribank of Namibia', '2020-11-30', 35900.25, 'Active'),
('93080800567': 'AGB-0005', 'Tuhafeni', 'Ndadi', '1993-08-08', 'M', '+264 81 555 6666', 't.ndadi@email.com', '505 Maerua Mall, Windhoek', 'AGB-001', 'Agribank of Namibia', '2022-02-14', 24800.00, 'Active');

-- 14. ALLIANCE INSURANCE
CREATE TABLE IF NOT EXISTS alliance_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO alliance_members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('78020200123': 'ALL-0001', 'Lazarus', 'Shipanga', '1978-02-02', 'M', '+264 81 666 7777', 'l.shipanga@email.com', '606 Independence Ave, Windhoek', 'ALL-001', 'Alliance Insurance', '2020-04-18', 53500.00, 'Active'),
('83030300234': 'ALL-0002', 'Anna', 'Shigwedha', '1983-03-03', 'F', '+264 81 777 8888', 'a.shigwedha@email.com', '707 Sam Nujoma Dr, Windhoek', 'ALL-001', 'Alliance Insurance', '2019-09-12', 40250.50, 'Active'),
('86040400345': 'ALL-0003', 'Petrus', 'Van Neel', '1986-04-04', 'M', '+264 81 888 9999', 'p.vanneel@email.com', '808 Mandela Street, Swakopmund', 'ALL-001', 'Alliance Insurance', '2021-01-05', 31400.75, 'Active'),
('90050500456': 'ALL-0004', 'Elizabeth', 'Khaxas', '1990-05-05', 'F', '+264 81 999 0000', 'e.khaxas@email.com', '909 Gerehu Street, Windhoek', 'ALL-001', 'Alliance Insurance', '2020-11-30', 27100.25, 'Active'),
('85060600567': 'ALL-0005', 'Henk', 'Van der Merwe', '1985-06-06', 'M', '+264 81 000 1111', 'h.vandermeerwe@email.com', '1010 Airport Road, Walvis Bay', 'ALL-001', 'Alliance Insurance', '2022-02-14', 45800.00, 'Active');

-- 15. PRUDENTIAL NAMIBIA
CREATE TABLE IF NOT EXISTS prudential_members (
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
    employer_number VARCHAR(20),     -- Employer number/code (NEW)
    employer       VARCHAR(120),     -- Employer name
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
INSERT INTO prudential_members (id_number, policy_number, first_name, last_name, date_of_birth, gender, phone, email, address, employer_number, employer, date_joined, balance_nad, status) VALUES
('82010100123': 'PRU-0001', 'Samuel', 'Nuuyoma', '1982-01-01', 'M', '+264 81 111 2222', 's.nuuyoma@email.com', '111 Independence Ave, Windhoek', 'PRU-001', 'Prudential Namibia', '2020-05-15', 47500.00, 'Active'),
('87020200234': 'PRU-0002', 'Vilho', 'Shikongo', '1987-02-02', 'M', '+264 81 222 3333', 'v.shikongo@email.com', '202 Sam Nujoma Dr, Windhoek', 'PRU-001', 'Prudential Namibia', '2019-08-22', 36500.50, 'Active'),
('90030300345': 'PRU-0003', 'Lineekela', 'Matius', '1990-03-03', 'F', '+264 81 333 4444', 'l.matius@email.com', '303 Mandela Street, Swakopmund', 'PRU-001', 'Prudential Namibia', '2021-01-10', 28750.75, 'Active'),
('85040400456': 'PRU-0004', 'Johanna', 'Mouton', '1985-04-04', 'F', '+264 81 444 5555', 'j.mouton@email.com', '404 Gerehu Street, Windhoek', 'PRU-001', 'Prudential Namibia', '2020-11-30', 34900.25, 'Active'),
('93050500567': 'PRU-0005', 'Testament', 'Naras', '1993-05-05', 'M', '+264 81 555 6666', 't.naras@email.com', '505 Maerua Mall, Windhoek', 'PRU-001', 'Prudential Namibia', '2022-02-14', 22800.00, 'Active');