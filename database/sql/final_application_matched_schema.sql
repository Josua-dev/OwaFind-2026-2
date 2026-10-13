-- FINAL APPLICATION-MATCHED DATABASE SCHEMA
-- This schema is fully consistent with the OWAFIND-2026 application interface
-- Based on analysis of ProfilePage.tsx, AppContext.tsx, and BeneficiaryDashboard.tsx

-- ============================================
-- CORE TABLES
-- ============================================

-- 1. MEMBERS TABLE (matches BeneficiaryProfile interface)
CREATE TABLE IF NOT EXISTS members (
    member_id      INT AUTO_INCREMENT PRIMARY KEY,
    id_number      VARCHAR(20) NOT NULL,              -- Maps to nationalId
    first_name     VARCHAR(60) NOT NULL,              -- Maps to firstName
    last_name      VARCHAR(60) NOT NULL,              -- Maps to lastName
    date_of_birth  DATE NOT NULL,                     -- Maps to dateOfBirth
    gender         ENUM('M','F','O') DEFAULT 'O',     -- Kept for internal use (not in profile)
    phone          VARCHAR(20),                       -- Maps to phone
    email          VARCHAR(100),                      -- Maps to email
    region         VARCHAR(100),                      -- Maps to region (replaced address)
    previous_name  VARCHAR(60),                       -- Maps to previousName
    consent_given  TINYINT(1) DEFAULT 0,              -- Maps to consentGiven (0/1)
    consent_date   DATE NULL,                         -- Maps to consentDate
    profile_completion INT DEFAULT 0,                 -- Maps to profileCompletion (0-100)
    verification_status ENUM('unverified','pending','verified') DEFAULT 'unverified', -- Maps to verificationStatus
    date_joined    DATE,                              -- Internal tracking
    date_left      DATE NULL,                         -- Internal tracking
    balance_nad    DECIMAL(14,2) DEFAULT 0.00,        -- Financial tracking
    status         ENUM('Active','Dormant','Paid Out','Deceased') DEFAULT 'Active', -- Internal status
    last_updated   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_id_number (id_number),
    INDEX idx_name (last_name, first_name),
    INDEX idx_status (status),
    INDEX idx_region (region)
);

-- 2. EMPLOYMENT HISTORY TABLE (supports multiple employment entries per beneficiary)
CREATE TABLE IF NOT EXISTS employment_history (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    member_id      INT NOT NULL,                      -- Foreign key to members
    employer       VARCHAR(120) NOT NULL,             -- Maps to employer in EmploymentEntry
    employee_number VARCHAR(20),                       -- Maps to employeeNumber in EmploymentEntry
    start_date     DATE NOT NULL,                     -- Maps to startDate in EmploymentEntry
    end_date       DATE NULL,                         -- Maps to endDate in EmploymentEntry (NULL = present)
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    INDEX idx_member_id (member_id),
    INDEX idx_employer (employer)
);

-- ============================================
-- INSTITUTION-SPECIFIC TABLES (each with reference column)
-- ============================================

-- NOTE: Each institution table now follows the same pattern:
-- - References the core members table via member_id (foreign key)
-- - Has its own unique reference column for institution-specific ID
-- - This design avoids data duplication while maintaining referential integrity

-- 1. GIPF (Government Institutions Pension Fund)
CREATE TABLE IF NOT EXISTS gipf_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    fund_number    VARCHAR(30) NOT NULL UNIQUE,       -- GIPF's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 2. SANLAM (Sanlam Namibia)
CREATE TABLE IF NOT EXISTS sanlam_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    policy_number  VARCHAR(30) NOT NULL UNIQUE,       -- Sanlam's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 3. OLD MUTUAL (Old Mutual Namibia)
CREATE TABLE IF NOT EXISTS oldmutual_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    policy_number  VARCHAR(30) NOT NULL UNIQUE,       -- Old Mutual's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 4. NIMBUS (Nimbus Pension Fund)
CREATE TABLE IF NOT EXISTS nimbus_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    certificate_number  VARCHAR(30) NOT NULL UNIQUE,   -- Nimbus's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 5. PROSPERITY (Prosperity Life)
CREATE TABLE IF NOT EXISTS prosperity_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    account_number VARCHAR(30) NOT NULL UNIQUE,       -- Prosperity's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 6. LEGACY (Legacy Insurance)
CREATE TABLE IF NOT EXISTS legacy_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    policy_number  VARCHAR(30) NOT NULL UNIQUE,       -- Legacy's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 7. NEDBANK NAMIBIA
CREATE TABLE IF NOT EXISTS nedbank_namibia_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    policy_number  VARCHAR(30) NOT NULL UNIQUE,       -- Nedbank's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 8. BANK WINDHOEK
CREATE TABLE IF NOT EXISTS bank_windhoek_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    account_number VARCHAR(30) NOT NULL UNIQUE,       -- Bank Windhoek's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 9. METROPOLITAN NAMIBIA
CREATE TABLE IF NOT EXISTS metropolitan_namibia_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    certificate_number VARCHAR(30) NOT NULL UNIQUE,   -- Metropolitan's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 10. NAMTEX PENSION FUND
CREATE TABLE IF NOT EXISTS namtex_pension_fund_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    fund_number    VARCHAR(30) NOT NULL UNIQUE,       -- Namtex's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 11. STANDARD BANK NAMIBIA
CREATE TABLE IF NOT EXISTS standard_bank_namibia_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    account_number VARCHAR(30) NOT NULL UNIQUE,       -- Standard Bank's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 12. FIRST NATIONAL BANK NAMIBIA
CREATE TABLE IF NOT EXISTS fnb_namibia_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    policy_number  VARCHAR(30) NOT NULL UNIQUE,       -- FNB's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 13. AGRIBANK OF NAMIBIA
CREATE TABLE IF NOT EXISTS agribank_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    loan_account_number VARCHAR(30) NOT NULL UNIQUE,   -- Agribank's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 14. ALLIANCE INSURANCE
CREATE TABLE IF NOT EXISTS alliance_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    policy_number  VARCHAR(30) NOT NULL UNIQUE,       -- Alliance's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 15. PRUDENTIAL NAMIBIA
CREATE TABLE IF NOT EXISTS prudential_members (
    member_id      INT PRIMARY KEY,                   -- Foreign key to members.member_id
    policy_number  VARCHAR(30) NOT NULL UNIQUE,       -- Prudential's ref column
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ============================================
-- SEED DATA
-- ============================================

-- SEED DATA FOR MEMBERS TABLE (Beneficiary Profiles)
INSERT INTO members (id_number, first_name, last_name, date_of_birth, gender, phone, email, region, previous_name, consent_given, consent_date, profile_completion, verification_status, date_joined, date_left, balance_nad, status) VALUES
-- GIPF Seed Data
('70010100123', 'Samuel', 'Nuuyoma', '1970-01-01', 'M', '+264 81 111 2222', 's.nuuyoma@email.com', 'Windhoek', '', 1, '2019-01-15', 85, 'verified', '2019-01-15', NULL, 75000.00, 'Active'),
('75020200234', 'Hilma', 'Nikanor', '1975-02-02', 'F', '+264 81 222 3333', 'h.nikanor@email.com', 'Khomas', 'Hilma-Shikongo', 1, '2020-03-22', 70, 'verified', '2020-03-22', NULL, 68500.50, 'Active'),
('80030300345', 'Petrus', 'Van Neel', '1980-03-03', 'M', '+264 81 333 4444', 'p.vanneel@email.com', 'Erongo', '', 0, NULL, 40, 'pending', '2021-01-10', NULL, 52750.75, 'Active'),
('82040400456', 'Elizabeth', 'Khaxas', '1982-04-04', 'F', '+264 81 444 5555', 'e.khaxas@email.com', 'Khomas', 'Elizabeth-Khuxas', 1, '2020-11-30', 90, 'verified', '2020-11-30', NULL, 45900.25, 'Active'),
('88050500567', 'Henk', 'Van der Merwe', '1988-05-05', 'M', '+264 81 555 6666', 'h.vandermeerwe@email.com', 'Khomas', '', 1, '2022-02-14', 75, 'verified', '2022-02-14', NULL, 37800.00, 'Active'),

-- Sanlam Seed Data
('72060600123', 'Angela', 'Kuine', '1972-06-06', 'F', '+264 81 666 7777', 'a.kuine@email.com', 'Khomas', 'Angela-Kuine', 1, '2019-04-18', 80, 'verified', '2019-04-18', NULL, 82000.00, 'Active'),
('78070700234', 'Johannes', 'Goraseb', '1978-07-07', 'M', '+264 81 777 8888', 'j.goraseb@email.com', 'Khomas', '', 1, '2020-09-12', 65, 'verified', '2020-09-12', NULL, 71250.50, 'Active'),
('83080800345', 'Elisa', 'Kamati', '1983-08-08', 'F', '+264 81 888 9999', 'e.kamati@email.com', 'Khomas', '', 0, NULL, 50, 'pending', '2021-01-05', NULL, 60400.75, 'Active'),
('86090900456', 'Filipus', 'Neshiku', '1986-09-09', 'M', '+264 81 999 0000', 'f.neshiku@email.com', 'Khomas', '', 1, '2020-11-30', 70, 'verified', '2020-11-30', NULL, 52100.25, 'Active'),
('90101000567', 'Lazarus', 'Sheriff', '1990-10-10', 'M', '+264 81 000 1111', 'l.sheriff@email.com', 'Khomas', '', 0, NULL, 30, 'unverified', '2022-02-14', NULL, 43800.00, 'Active'),

-- Old Mutual Seed Data
('68010100123', 'Helena', 'Kazondiqua', '1968-01-01', 'F', '+264 81 111 2222', 'h.kazondiqua@email.com', 'Khomas', 'Helena-Kazongua', 1, '2019-02-15', 95, 'verified', '2019-02-15', NULL, 95000.00, 'Active'),
('74020200234', 'Dirk', 'Hendrik', '1974-02-02', 'M', '+264 81 222 3333', 'd.hendrik@email.com', 'Khomas', '', 1, '2020-05-22', 85, 'verified', '2020-05-22', NULL, 83500.50, 'Active'),
('79030300345', 'Brenda', 'Makaula', '1979-03-03', 'F', '+264 81 333 4444', 'b.makaula@email.com', 'Erongo', 'Brenda-Makaula', 1, '2021-02-10', 75, 'verified', '2021-02-10', NULL, 72750.75, 'Active'),
('81040400456', 'Tuutalik', 'Nashilongo', '1981-04-04', 'M', '+264 81 444 5555', 't.nashilongo@email.com', 'Erongo', '', 1, '2020-12-30', 60, 'verified', '2020-12-30', NULL, 61900.25, 'Active'),
('86050500567', 'Sacky', 'Shifitoka', '1986-05-05', 'F', '+264 81 555 6666', 's.shifitoka@email.com', 'Khomas', '', 0, NULL, 25, 'unverified', '2022-03-14', NULL, 50800.00, 'Active'),

-- Nimbus Seed Data
('90010100123', 'John', 'Namibian', '1990-01-01', 'M', '+264 81 123 4567', 'john.namibian@email.com', 'Khomas', '', 1, '2020-01-15', 60, 'verified', '2020-01-15', NULL, 15000.00, 'Active'),
('90020200234', 'Mary', 'Katjimune', '1990-02-02', 'F', '+264 81 234 5678', 'm.katjimune@email.com', 'Khomas', '', 0, NULL, 30, 'pending', '2020-02-20', NULL, 22500.50, 'Active'),
('85030300345', 'Peter', 'Shilongo', '1985-03-03', 'M', '+264 81 345 6789', 'p.s hilongo@email.com', 'Erongo', '', 1, '2019-11-30', 70, 'verified', '2019-11-30', NULL, 35000.75, 'Active'),
('92040400456', 'Grace', 'Ngavetene', '1992-04-04', 'F', '+264 81 456 7890', 'g.ngavetene@email.com', 'Khomas', '', 1, '2021-03-10', 40, 'verified', '2021-03-10', NULL, 18250.25, 'Active'),
('88050500567', 'Thomas', 'Kanku', '1988-05-05', 'M', '+264 81 567 8901', 't.kanku@email.com', 'Khomas', '', 0, NULL, 20, 'unverified', '2020-07-22', NULL, 42000.00, 'Active'),

-- Prosperity Seed Data
('91060600678', 'Samuel', 'Shanghala', '1991-06-06', 'M', '+264 81 678 9012', 's.shanghala@email.com', 'Khomas', '', 1, '2020-04-18', 50, 'verified', '2020-04-18', NULL, 28500.00, 'Active'),
('89070700789', 'Elisa', 'Kazapua', '1989-07-07', 'F', '+264 81 789 0123', 'e.kazapua@email.com', 'Khomas', '', 0, NULL, 25, 'pending', '2019-09-12', NULL, 33750.50, 'Active'),
('93080800890', 'David', 'Goraseb', '1993-08-08', 'M', '+264 81 890 1234', 'd.goraseb@email.com', 'Oshikoto', '', 1, '2021-01-05', 40, 'verified', '2021-01-05', NULL, 19200.75, 'Active'),
('87090900901', 'Frances', 'Goraseb', '1987-09-09', 'F', '+264 81 901 2345', 'f.goraseb@email.com', 'Khomas', '', 1, '2020-11-30', 45, 'verified', '2020-11-30', NULL, 27800.25, 'Active'),
('94101001012', 'Mathews', 'Tjongarero', '1994-10-10', 'M', '+264 81 012 3456', 'm.tjongarero@email.com', 'Erongo', '', 0, NULL, 20, 'unverified', '2022-02-14', NULL, 15600.00, 'Active'),

-- Legacy Seed Data
('86111101123', 'Patrick', 'Kauma', '1986-11-11', 'M', '+264 81 234 5678', 'p.kauma@email.com', 'Khomas', '', 1, '2019-06-15', 70, 'verified', '2019-06-15', NULL, 45200.00, 'Active'),
('90121201234', 'Viola', 'Mapelema', '1990-12-12', 'F', '+264 81 345 6789', 'v.mapelema@email.com', 'Khomas', '', 0, NULL, 35, 'pending', '2020-08-22', NULL, 31500.50, 'Active'),
('88010101345', 'Benjamin', 'Frederiks', '1988-01-01', 'M', '+264 81 456 7890', 'b.frederiks@email.com', 'Erongo', '', 1, '2019-12-03', 60, 'verified', '2019-12-03', NULL, 38900.75, 'Active'),
('91020201456': 'Christine', 'Haiduwa', '1991-02-02', 'F', '+264 81 567 8901', 'c.haiduwa@email.com', 'Khomas', '', 1, '2021-04-18', 40, 'verified', '2021-04-18', NULL, 24600.25, 'Active'),
('89030301567': 'Andre', 'Goraseb', '1989-03-03', 'M', '+264 81 678 9012', 'a.goraseb@email.com', 'Khomas', '', 0, NULL, 30, 'unverified', '2020-01-30', NULL, 41300.00, 'Active'),

-- Nedbank Namibia Seed Data
('82040400567': 'Angela', 'Smith', '1982-04-04', 'F', '+264 81 111 2222', 'a.smith@email.com', 'Khomas', '', 1, '2019-03-15', 65, 'verified', '2019-03-15', NULL, 52000.00, 'Active'),
('88050500678': 'Martin', 'Ndadi', '1988-05-05', 'M', '+264 81 222 3333', 'm.ndadi@email.com', 'Khomas', '', 0, NULL, 40, 'pending', '2020-07-22', NULL, 38500.50, 'Active'),
('90060600789': 'Faith', 'Kanyetu', '1990-06-06', 'F', '+264 81 333 4444', 'f.kanyetu@email.com', 'Khomas', '', 1, '2021-01-10', 50, 'verified', '2021-01-10', NULL, 29750.75, 'Active'),
('85070700890': 'Ockie', 'Karuuombe', '1985-07-07', 'M', '+264 81 444 5555', 'o.karuombe@email.com', 'Khomas', '', 1, '2019-11-05', 70, 'verified', '2019-11-05', NULL, 47200.25, 'Active'),
('93080800901': 'Tupewa', 'Shifotoka', '1993-08-08', 'M', '+264 81 555 6666', 't.shifotoka@email.com', 'Khomas', '', 0, NULL, 25, 'unverified', '2022-02-14', NULL, 22800.00, 'Active'),

-- Bank Windhoek Seed Data
('83090900123': 'Hilma', 'Nikanor', '1983-09-09', 'F', '+264 81 666 7777', 'h.nikanor@email.com', 'Khomas', '', 1, '2020-04-18', 55, 'verified', '2020-04-18', NULL, 33500.00, 'Active'),
('87101000234': 'Jerry', 'Goraseb', '1987-10-10', 'M', '+264 81 777 8888', 'j.goraseb@email.com', 'Khomas', '', 0, NULL, 30, 'pending', '2019-09-12', NULL, 41250.50, 'Active'),
('91111100345': 'Sven', 'Von Schmettau', '1991-11-11', 'M', '+264 81 888 9999', 's.vonschmettau@email.com', 'Erongo', '', 1, '2021-01-05', 45, 'verified', '2021-01-05', NULL, 24900.75, 'Active'),
('89121200456': 'Emma', 'Neumbo', '1989-12-12', 'F', '+264 81 999 0000', 'e.neumbo@email.com', 'Khomas', '', 1, '2020-11-30', 60, 'verified', '2020-11-30', NULL, 37800.25, 'Active'),
('95010100567': 'Laimi', 'Haihambo', '1995-01-01', 'F', '+264 81 000 1111', 'l.haihambo@email.com', 'Erongo', '', 0, NULL, 20, 'unverified', '2022-02-14', NULL, 18900.00, 'Active'),

-- Metropolitan Namibia Seed Data
('84020200678': 'David', 'Goraseb', '1984-02-02', 'M', '+264 81 111 2222', 'd.goraseb@email.com', 'Khomas', '', 1, '2019-06-15', 70, 'verified', '2019-06-15', NULL, 48500.00, 'Active'),
('88030300789': 'Eliza', 'Kamati', '1988-03-03', 'F', '+264 81 222 3333', 'e.kamati@email.com', 'Khomas', '', 0, NULL, 35, 'pending', '2020-08-22', NULL, 32750.50, 'Active'),
('90040400890': 'James', 'Xoagub', '1990-04-04', 'M', '+264 81 333 4444', 'j.xoagub@email.com', 'Erongo', '', 1, '2019-12-03', 50, 'verified', '2019-12-03', NULL, 40100.75, 'Active'),
('87050500901': 'Frieda', 'Mbako', '1987-05-05', 'F', '+264 81 444 5555', 'f.mbako@email.com', 'Khomas', '', 1, '2021-04-18', 40, 'verified', '2021-04-18', NULL, 26900.25, 'Active'),
('92060601012': 'Abner', 'Xoagub', '1992-06-06', 'M', '+264 81 555 6666', 'a.xoagub@email.com', 'Khomas', '', 0, NULL, 25, 'unverified', '2020-01-30', NULL, 43400.00, 'Active'),

-- Namtex Pension Fund Seed Data
('86080800123': 'Maria', 'Neumbo', '1986-08-08', 'F', '+264 81 666 7777', 'm.neumbo@email.com', 'Khomas', '', 1, '2020-03-10', 65, 'verified', '2020-03-10', NULL, 39500.00, 'Active'),
('89090900234': 'Samuel', 'Goraseb', '1989-09-09', 'M', '+264 81 777 8888', 's.goraseb@email.com', 'Khomas', '', 0, NULL, 40, 'pending', '2019-10-22', NULL, 34250.50, 'Active'),
('91101000345': 'Letticia', 'Katjimune', '1991-10-10', 'F', '+264 81 888 9999', 'l.katjimune@email.com', 'Khomas', '', 1, '2021-02-05', 50, 'verified', '2021-02-05', NULL, 27400.75, 'Active'),
('85111100456': 'Timothy', 'Kangowa', '1985-11-11', 'M', '+264 81 999 0000', 't.kangowa@email.com', 'Khomas', '', 1, '2020-12-30', 70, 'verified', '2020-12-30', NULL, 40300.25, 'Active'),
('93121200567': 'Winston', 'Goraseb', '1993-12-12', 'M', '+264 81 000 1111', 'w.goraseb@email.com', 'Erongo', '', 0, NULL, 30, 'unverified', '2022-03-15', NULL, 21900.00, 'Active'),

-- Standard Bank Namibia Seed Data
('80010100123': 'Helena', 'Kazondiqua', '1980-01-01', 'F', '+264 81 111 2222', 'h.kazondiqua@email.com', 'Khomas', '', 1, '2019-05-15', 75, 'verified', '2019-05-15', NULL, 55000.00, 'Active'),
('85020200234': 'Dirk', 'Hendrik', '1985-02-02', 'M', '+264 81 222 3333', 'd.hendrik@email.com', 'Khomas', '', 0, NULL, 40, 'pending', '2020-08-22', NULL, 41500.50, 'Active'),
('88030300345': 'Brenda', 'Makaula', '1988-03-03', 'F', '+264 81 333 4444', 'b.makaula@email.com', 'Erongo', '', 1, '2021-01-10', 50, 'verified', '2021-01-10', NULL, 32750.75, 'Active'),
('92040400456': 'Tuutalik', 'Nashilongo', '1992-04-04', 'M', '+264 81 444 5555', 't.nashilongo@email.com', 'Khomas', '', 1, '2020-11-30', 40, 'verified', '2020-11-30', NULL, 28900.25, 'Active'),
('87050500567': 'Sacky', 'Shifitoka', '1987-05-05', 'F', '+264 81 555 6666', 's.shifitoka@email.com', 'Khomas', '', 0, NULL, 25, 'unverified', '2022-02-14', NULL, 37800.00, 'Active'),

-- First National Bank Namibia Seed Data
('81060600123': 'Angela', 'Kuine', '1981-06-06', 'F', '+264 81 666 7777', 'a.kuine@email.com', 'Khomas', '', 1, '2020-04-18', 70, 'verified', '2020-04-18', NULL, 49500.00, 'Active'),
('86070700234': 'Johannes', 'Goraseb', '1986-07-07', 'M', '+264 81 777 8888', 'j.goraseb@email.com', 'Khomas', '', 0, NULL, 40, 'pending', '2019-09-12', NULL, 35250.50, 'Active'),
('89080800345': 'Elisa', 'Kamati', '1989-08-08', 'F', '+264 81 888 9999', 'e.kamati@email.com', 'Khomas', '', 1, '2021-01-05', 50, 'verified', '2021-01-05', NULL, 26400.75, 'Active'),
('93090900456': 'Filipus', 'Neshiku', '1993-09-09', 'M', '+264 81 999 0000', 'f.neshiku@email.com', 'Khomas', '', 0, NULL, 30, 'unverified', '2020-11-30', NULL, 22100.25, 'Active'),
('84101000567': 'Lazarus', 'Sheriff', '1984-10-10', 'M', '+264 81 000 1111', 'l.sheriff@email.com', 'Khomas', '', 1, '2022-02-14', 60, 'verified', '2022-02-14', NULL, 41800.00, 'Active'),

-- Agribank of Namibia Seed Data
('75040400123': 'Hendrik', 'Ontiku', '1975-04-04', 'M', '+264 81 111 2222', 'h.ontiku@email.com', 'Khomas', '', 1, '2019-03-15', 70, 'verified', '2019-03-15', NULL, 62000.00, 'Active'),
('80050500234': 'Maria', 'Neumbo', '1980-05-05', 'F', '+264 81 222 3333', 'm.neumbo@email.com', 'Khomas', '', 0, NULL, 40, 'pending', '2020-07-22', NULL, 48500.50, 'Active'),
('82060600345': 'Johan', 'Van Wyk', '1982-06-06', 'M', '+264 81 333 4444', 'j.vanwyk@email.com', 'Khomas', '', 1, '2021-01-10', 50, 'verified', '2021-01-10', NULL, 39750.75, 'Active'),
('88070700456': 'Frieda', 'Haikali', '1988-07-07', 'F', '+264 81 444 5555', 'f.haikali@email.com', 'Khomas', '', 1, '2020-11-30', 60, 'verified', '2020-11-30', NULL, 35900.25, 'Active'),
('93080800567': 'Tuhafeni', 'Ndadi', '1993-08-08', 'M', '+264 81 555 6666', 't.ndadi@email.com', 'Khomas', '', 0, NULL, 25, 'unverified', '2022-02-14', NULL, 24800.00, 'Active'),

-- Alliance Insurance Seed Data
('78020200123': 'Lazarus', 'Shipanga', '1978-02-02', 'M', '+264 81 666 7777', 'l.shipanga@email.com', 'Khomas', '', 1, '2020-04-18', 75, 'verified', '2020-04-18', NULL, 53500.00, 'Active'),
('83030300234': 'Anna', 'Shigwedha', '1983-03-03', 'F', '+264 81 777 8888', 'a.shigwedha@email.com', 'Khomas', '', 0, NULL, 40, 'pending', '2019-09-12', NULL, 40250.50, 'Active'),
('86040400345': 'Petrus', 'Van Neel', '1986-04-04', 'M', '+264 81 888 9999', 'p.vanneel@email.com', 'Erongo', '', 1, '2021-01-05', 50, 'verified', '2021-01-05', NULL, 31400.75, 'Active'),
('90050500456': 'Elizabeth', 'Khaxas', '1990-05-05', 'F', '+264 81 999 0000', 'e.khaxas@email.com', 'Khomas', '', 1, '2020-11-30', 60, 'verified', '2020-11-30', NULL, 27100.25, 'Active'),
('85060600567': 'Henk', 'Van der Merwe', '1985-06-06', 'M', '+264 81 000 1111', 'h.vandermeerwe@email.com', 'Khomas', '', 0, NULL, 25, 'unverified', '2022-02-14', NULL, 45800.00, 'Active'),

-- Prudential Namibia Seed Data
('82010100123': 'Samuel', 'Nuuyoma', '1982-01-01', 'M', '+264 81 111 2222', 's.nuuyoma@email.com', 'Khomas', '', 1, '2020-05-15', 65, 'verified', '2020-05-15', NULL, 47500.00, 'Active'),
('87020200234': 'Vilho', 'Shikongo', '1987-02-02', 'M', '+264 81 222 3333', 'v.shikongo@email.com', 'Khomas', '', 0, NULL, 40, 'pending', '2019-08-22', NULL, 36500.50, 'Active'),
('90030300345': 'Lineekela', 'Matius', '1990-03-03', 'F', '+264 81 333 4444', 'l.matius@email.com', 'Khomas', '', 1, '2021-01-10', 50, 'verified', '2021-01-10', NULL, 28750.75, 'Active'),
('85040400456': 'Johanna', 'Mouton', '1985-04-04', 'F', '+264 81 444 5555', 'j.mouton@email.com', 'Khomas', '', 1, '2020-11-30', 60, 'verified', '2020-11-30', NULL, 34900.25, 'Active'),
('93050500567': 'Testament', 'Naras', '1993-05-05', 'M', '+264 81 555 6666', 't.naras@email.com', 'Khomas', '', 0, NULL, 25, 'unverified', '2022-02-14', NULL, 22800.00, 'Active'),

-- SEED DATA FOR EMPLOYMENT HISTORY TABLE
-- GIPF Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(1, 'Government of Namibia', 'GOV-001', '2019-01-15', NULL),
(2, 'Ministry of Education', 'MOE-005', '2020-03-22', NULL),
(3, 'Ministry of Works', 'MOW-003', '2021-01-10', NULL),
(4, 'Ministry of Health', 'MOH-012', '2020-11-30', NULL),
(5, 'Namibia Statistics Agency', 'NSA-007', '2022-02-14', NULL),

-- Sanlam Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(6, 'Sanlam Namibia Head Office', 'SAN-HEAD', '2019-04-18', NULL),
(7, 'Sanlam Namibia Windhoek Branch', 'SAN-WHK', '2020-09-12', NULL),
(8, 'Sanlam Namibia Swakopmund Branch', 'SAN-SWK', '2021-01-05', NULL),
(9, 'Sanlam Namibia Walvis Bay Branch', 'SAN-WVB', '2020-11-30', NULL),
(10, 'Sanlam Namibia Walvis Bay Branch', 'SAN-WVB', '2022-02-14', NULL),

-- Old Mutual Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(11, 'Old Mutual Namibia Head Office', 'OM-HEAD', '2019-02-15', NULL),
(12, 'Old Mutual Namibia Windhoek', 'OM-WINDHOEK', '2020-05-22', NULL),
(13, 'Old Mutual Namibia Swakopmund', 'OM-SWAKOP', '2021-02-10', NULL),
(14, 'Old Mutual Namibia Walvis Bay', 'OM-WALVIS', '2020-12-30', NULL),
(15, 'Old Mutual Namibia Ongwediva', 'OM-ONGWED', '2022-03-14', NULL),

-- Nimbus Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(16, 'Government of Namibia', 'GOV-001', '2020-01-15', NULL),
(17, 'Ministry of Education', 'MOE-005', '2020-02-20', NULL),
(18, 'NamPort Authority', 'NAMPORT', '2019-11-30', NULL),
(19, 'Bank of Namibia', 'BON-001', '2021-03-10', NULL),
(20, 'Namibia Breweries', 'NAM-BREW', '2020-07-22', NULL),

-- Prosperity Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(21, 'Standard Bank Namibia', 'SBN-001', '2020-04-18', NULL),
(22, 'Paratus Telecom', 'PARATUS', '2019-09-12', NULL),
(23, 'Oshakati Town Council', 'OSHIK', '2021-01-05', NULL),
(24, 'Ministry of Health', 'MOH-012', '2020-11-30', NULL),
(25, 'Namibian Ports Authority', 'NAMPORT', '2022-02-14', NULL),

-- Legacy Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(26, 'Namibia Statistics Agency', 'NSA-007', '2019-06-15', NULL),
(27, 'Telecom Namibia', 'TELCOM', '2020-08-22', NULL),
(28, 'Swakopmund Municipality', 'SWK-MUN', '2019-12-03', NULL),
(29, 'Bank Windhoek', 'BW-001', '2021-04-18', NULL),
(30, 'First National Bank Namibia', 'FNB-NAM', '2020-01-30', NULL),

-- Nedbank Namibia Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(31, 'Nedbank Namibia', 'NED-001', '2019-03-15', NULL),
(32, 'Nedbank Namibia', 'NED-001', '2020-07-22', NULL),
(33: 'Nedbank Namibia', 'NED-001', '2021-01-10', NULL),
(34: 'Nedbank Namibia', 'NED-001', '2019-11-05', NULL),
(35: 'Nedbank Namibia', 'NED-001', '2022-02-14', NULL),

-- Bank Windhoek Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(36: 'Bank Windhoek', 'BW-001', '2020-04-18', NULL),
(37: 'Bank Windhoek', 'BW-001', '2019-09-12', NULL),
(38: 'Bank Windhoek', 'BW-001', '2021-01-05', NULL),
(39: 'Bank Windhoek', 'BW-001', '2020-11-30', NULL),
(40: 'Bank Windhoek', 'BW-001', '2022-02-14', NULL),

-- Metropolitan Namibia Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(41: 'Metropolitan Namibia', 'MET-001', '2019-06-15', NULL),
(42: 'Metropolitan Namibia', 'MET-001', '2020-08-22', NULL),
(43: 'Metropolitan Namibia', 'MET-001', '2019-12-03', NULL),
(44: 'Metropolitan Namibia', 'MET-001', '2021-04-18', NULL),
(45: 'Metropolitan Namibia', 'MET-001', '2020-01-30', NULL),

-- Namtex Pension Fund Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(46: 'Namibia Textile Mills', 'NTM-001', '2020-03-10', NULL),
(47: 'Namibia Textile Mills', 'NTM-001', '2019-10-22', NULL),
(48: 'Namibia Textile Mills', 'NTM-001', '2021-02-05', NULL),
(49: 'Namibia Textile Mills', 'NTM-001', '2020-12-30', NULL),
(50: 'Namibia Textile Mills', 'NTM-001', '2022-03-15', NULL),

-- Standard Bank Namibia Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(51: 'Standard Bank Namibia', 'SBN-001', '2019-05-15', NULL),
(52: 'Standard Bank Namibia', 'SBN-001', '2020-08-22', NULL),
(53: 'Standard Bank Namibia', 'SBN-001', '2021-01-10', NULL),
(54: 'Standard Bank Namibia', 'SBN-001', '2020-11-30', NULL),
(55: 'Standard Bank Namibia', 'SBN-001', '2022-02-14', NULL),

-- First National Bank Namibia Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(56: 'FNB Namibia', 'FNB-NAM', '2020-04-18', NULL),
(57: 'FNB Namibia', 'FNB-NAM', '2019-09-12', NULL),
(58: 'FNB Namibia', 'FNB-NAM', '2021-01-05', NULL),
(59: 'FNB Namibia', 'FNB-NAM', '2020-11-30', NULL),
(60: 'FNB Namibia', 'FNB-NAM', '2022-02-14', NULL),

-- Agribank of Namibia Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(61: 'Agribank of Namibia', 'AGB-001', '2019-03-15', NULL),
(62: 'Agribank of Namibia', 'AGB-001', '2020-07-22', NULL),
(63: 'Agribank of Namibia', 'AGB-001', '2021-01-10', NULL),
(64: 'Agribank of Namibia', 'AGB-001', '2020-11-30', NULL),
(65: 'Agribank of Namibia', 'AGB-001', '2022-02-14', NULL),

-- Alliance Insurance Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(66: 'Alliance Insurance', 'ALL-001', '2020-04-18', NULL),
(67: 'Alliance Insurance', 'ALL-001', '2019-09-12', NULL),
(68: 'Alliance Insurance', 'ALL-001', '2021-01-05', NULL),
(69: 'Alliance Insurance', 'ALL-001', '2020-11-30', NULL),
(70: 'Alliance Insurance', 'ALL-001', '2022-02-14', NULL),

-- Prudential Namibia Employment History
INSERT INTO employment_history (member_id, employer, employee_number, start_date, end_date) VALUES
(71: 'Prudential Namibia', 'PRU-001', '2020-05-15', NULL),
(72: 'Prudential Namibia', 'PRU-001', '2019-08-22', NULL),
(73: 'Prudential Namibia', 'PRU-001', '2021-01-10', NULL),
(74: 'Prudential Namibia', 'PRU-001', '2020-11-30', NULL),
(75: 'Prudential Namibia', 'PRU-001', '2022-02-14', NULL);

-- INDEXES FOR BETTER QUERY PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_employment_member_id ON employment_history(member_id);
CREATE INDEX IF NOT EXISTS idx_employment_employer ON employment_history(employer);
CREATE INDEX IF NOT EXISTS idx_members_verification ON members(verification_status);
CREATE INDEX IF NOT EXISTS idx_members_consent ON members(consent_given);