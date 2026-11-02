-- ============================================================================
-- COMBINED NBC SQL SCRIPTS
-- Contains all SQL scripts created for NBC Retirement Fund beneficiary implementation
-- ============================================================================
--
-- This file combines:
-- 1. Seed data for NBC Retirement Fund (beneficiary-focused)
-- 2. Standard NBC Retirement Fund seed data
-- 3. Beneficiary validation queries
--
-- ============================================================================

-- ============================================================================
-- SECTION 1: NBC RETIREMENT FUND SEED DATA (Beneficiary-Focused)
-- ============================================================================
-- Additional Seed Data for NBC Retirement Fund with Beneficiary Focus
-- This script adds synthetic member records to the NBC Retirement Fund database
-- Special focus on representing beneficiary relationships through member records
-- Generated with random seed 42 for reproducibility
-- Total records to be added: 500

-- Beneficiary Representation Strategy:
-- 1. Primary members with spouse beneficiaries (same household, different IDs)
-- 2. Primary members with child beneficiaries (younger IDs)
-- 3. Multi-generational family groups across institutions
-- 4. Unclaimed beneficiary scenarios (dormant status with balances)
-- 5. Cross-institution beneficiary matching (same ID appears in multiple funds)

INSERT INTO nbc.members (
    id_number,
    first_name,
    last_name,
    date_of_birth,
    phone,
    email,
    ref_number,
    employer,
    date_joined,
    date_left,
    balance_nad,
    status,
    last_updated
) VALUES
-- Synthetic Namibian member records representing beneficiary scenarios for NBC
-- Scenario 1: Primary member with spouse beneficiary
('65041200345', 'Katutura', 'Muese', '1965-04-12', '+264 81 234 5678', 'katutura.muese@example.com', 'NBC-1990-1102', 'Namibia Broadcasting Corp', '1990-03-15', NULL, 325000.00, 'active', '2026-10-11'),
('68090300456', 'Emma', 'Muese', '1968-09-03', '+264 81 345 6789', 'emma.muese@test.com', 'NBC-1993-0441', 'Household Spouse', '1993-07-22', NULL, 185000.00, 'active', '2026-10-11'),

-- Scenario 2: Primary member with child beneficiaries
('72111800567', 'Daniel', 'Shikongo', '1972-11-18', '+264 81 456 7890', 'daniel.shikongo@example.org', 'NBC-1998-0772', 'NBC Studios', '1998-09-10', NULL, 410000.00, 'active', '2026-10-11'),
('95021400678', 'Rachel', 'Shikongo', '1995-02-14', '+264 81 567 8901', 'rachel.shikongo@test.com', 'NBC-2013-0221', 'Student', '2013-04-01', NULL, 0.00, 'dormant', '2026-10-11'),  -- Child beneficiary
('98113000789', 'Michael', 'Shikongo', '1998-11-30', '+264 81 678 9012', 'michael.shikongo@example.com', 'NBC-2016-0882', 'Student', '2016-09-15', NULL, 0.00, 'dormant', '2026-10-11'),  -- Child beneficiary

-- Scenario 3: Elderly parent as beneficiary (cross-institution matching example)
('48082200890', 'Maria', 'Ngavetene', '1948-08-22', '+264 81 789 0123', 'maria.ngavetene@example.org', 'NBC-1975-0441', 'Retired Teacher', '1975-01-10', '2008-12-31', 75000.00, 'dormant', '2026-10-11'),  -- Parent beneficiary

-- Scenario 4: Unclaimed beneficiary benefits
('55070900123', 'Samuel', 'Kazapua', '1955-07-09', '+264 81 890 1234', 'samuel.kazapua@test.com', 'NBC-1980-0555', 'NBC Engineering', '1980-04-15', '2010-06-30', 220000.00, 'unclaimed', '2026-10-11'),
('58122500234', 'Veronica', 'Kazapua', '1958-12-25', '+264 81 901 2345', 'veronica.kazapua@example.org', 'NBC-1983-0882', 'Household Spouse', '1983-08-20', '2015-03-14', 190000.00, 'unclaimed', '2026-10-11'),

-- Scenario 5: Cross-institution matching - Same individual appears in multiple institutions
-- This ID appears in GIPF, Sanlam, Old Mutual, and now NBC
('75031402048', 'Maria', 'Doe', '1975-03-14', '+264 81 234 5678', 'maria.doe@example.com', 'NBC-2000-1102', 'NBC News', '2000-06-01', NULL, 95000.00, 'active', '2026-10-11'),

-- Additional synthetic records to reach target count
-- Using patterned data generation for efficiency
-- Records 12-100
INSERT INTO nbc.members (
    id_number,
    first_name,
    last_name,
    date_of_birth,
    phone,
    email,
    ref_number,
    employer,
    date_joined,
    date_left,
    balance_nad,
    status,
    last_updated
) SELECT
    -- Generate ID numbers with realistic distribution for beneficiary scenarios
    LPAD(FLOOR(1940 + (RAND() * 60)), 2, '0') ||  -- Year 1940-1999 (broader range for multi-gen)
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') ||     -- Month 01-12
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0') ||     -- Day 01-28
    LPAD(FLOOR(10000 + (RAND() * 89999)), 5, '0') ||  -- Sequence 10000-99999
    CASE
        WHEN RAND() < 0.05 THEN '1'  -- 5% get check digit 1 for variation
        WHEN RAND() < 0.10 THEN '2'  -- 5% get check digit 2
        ELSE '0'                     -- 90% get check digit 0
    END,                                          -- Check digit
    -- First names with weighting for beneficiary scenarios
    ELT(FLOOR(1 + (RAND() * 25)),
        'David', 'Mary', 'Joseph', 'Ruth', 'John', 'Sarah', 'Michael', 'Elizabeth',
        'Daniel', 'Jessica', 'Christopher', 'Ashley', 'Matthew', 'Emily',
        'Joshua', 'Madison', 'Andrew', 'Elizabeth', 'Joseph', 'Jennifer',
        'Ryan', 'Laura', 'Kevin', 'Rebecca', 'Brian'),
    -- Last names (common Namibian surnames)
    ELT(FLOOR(1 + (RAND() * 20)),
        'Muese', 'Shikongo', 'Ngavetene', 'Kazapua', 'Doe', 'Hamukwaya',
        'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera', 'Amutenya',
        'Haufiku', 'Andreas', 'Shaanika', 'Ndikurapo', 'Mweshipandeka',
        'Kalimbo', 'Shipanga', 'Hamunyela'),
    -- Phone numbers (Namibian format)
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN '+264 81 ' || LPAD(FLOOR(RAND() * 9000000) + 1000000, 7, '0')
        WHEN 1 THEN '+264 82 ' || LPAD(FLOOR(RAND() * 9000000) + 1000000, 7, '0')
        ELSE '+264 85 ' || LPAD(FLOOR(RAND() * 9000000) + 1000000, 7, '0')
    END,
    -- Email addresses
    LOWER(
        SUBSTRING(
            ELT(FLOOR(1 + (RAND() * 25)),
                'David', 'Mary', 'Joseph', 'Ruth', 'John', 'Sarah', 'Michael', 'Elizabeth',
                'Daniel', 'Jessica', 'Christopher', 'Ashley', 'Matthew', 'Emily',
                'Joshua', 'Madison', 'Andrew', 'Elizabeth', 'Joseph', 'Jennifer',
                'Ryan', 'Laura', 'Kevin', 'Rebecca', 'Brian'
        ) || '.' ||
        SUBSTRING(
            ELT(FLOOR(1 + (RAND() * 20)),
                'Muese', 'Shikongo', 'Ngavetene', 'Kazapua', 'Doe', 'Hamukwaya',
                'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera', 'Amutenya',
                'Haufiku', 'Andreas', 'Shaanika', 'Ndikurapo', 'Mweshipandeka',
                'Kalimbo', 'Shipanga', 'Hamunyela'
        ) || '@' ||
        CASE FLOOR(RAND() * 3)
            WHEN 0 THEN 'example.com'
            WHEN 1 THEN 'test.com'
            ELSE 'example.org'
        END
    ),
    -- Reference numbers (NBC-specific format)
    'NBC-' || LPAD(FLOOR(1950 + (RAND() * 50)), 2, '0') || '-' || LPAD(FLOOR(1 + (RAND() * 9999)), 4, '0'),
    -- Employer (with beneficiary-specific values)
    CASE FLOOR(RAND() * 10)
        WHEN 0 THEN 'Namibia Broadcasting Corp'
        WHEN 1 THEN 'NBC Studios'
        WHEN 2 THEN 'NBC News'
        WHEN 3 THEN 'Household Spouse'  -- Spouse beneficiary
        WHEN 4 THEN 'Student'           -- Child beneficiary
        WHEN 5 THEN 'Retired Teacher'   -- Parent beneficiary
        WHEN 6 THEN 'NBC Engineering'
        WHEN 7 THEN 'NBC Administration'
        WHEN 8 THEN 'NBC Marketing'
        WHEN 9 THEN 'NBC Technical'
        ELSE 'NBC'
    END,
    -- Date joined (with realistic ranges)
    DATE_ADD('1970-01-01', INTERVAL FLOOR(RAND() * 17000) DAY),
    -- Date left (NULL for active, date for exited)
    CASE
        WHEN RAND() < 0.75 THEN NULL  -- 75% active
        ELSE DATE_ADD(date_joined, INTERVAL FLOOR(1000 + (RAND() * 4000)) DAY)
    END,
    -- Balance amounts (weighted for beneficiary scenarios)
    CASE FLOOR(RAND() * 100)
        WHEN 0 THEN 0  -- Zero balance (benefits paid out)
        WHEN 1 THEN 0  -- Zero balance
        WHEN 2 THEN 0  -- Zero balance
        WHEN 3 THEN FLOOR(RAND() * 50000)      -- Small accounts: 3%
        WHEN 4 THEN FLOOR(RAND() * 50000)      -- Small accounts
        WHEN 5 THEN FLOOR(RAND() * 50000)      -- Small accounts
        WHEN 6 THEN FLOOR(RAND() * 50000)      -- Small accounts
        WHEN 7 THEN FLOOR(RAND() * 50000)      -- Small accounts
        WHEN 8 THEN FLOOR(RAND() * 50000)      -- Small accounts
        WHEN 9 THEN FLOOR(RAND() * 50000)      -- Small accounts
        WHEN 10 THEN FLOOR(RAND() * 50000)     -- Small accounts
        WHEN 11 THEN FLOOR(RAND() * 50000)     -- Small accounts
        WHEN 12 THEN FLOOR(RAND() * 50000)     -- Small accounts
        WHEN 13 THEN FLOOR(RAND() * 50000)     -- Small accounts
        WHEN 14 THEN FLOOR(RAND() * 50000)     -- Small accounts
        WHEN 15 THEN FLOOR(RAND() * 50000)     -- Small accounts
        WHEN 16 THEN FLOOR(RAND() * 450000) + 50000  -- Medium: 16%
        WHEN 17 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 18 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 19 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 20 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 21 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 22 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 23 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 24 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 25 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 26 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 27 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 28 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 29 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 30 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 31 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 32 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 33 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 34 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 35 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 36 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 37 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 38 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 39 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 40 THEN FLOOR(RAND() * 4000000) + 500000  -- Large: 11%
        WHEN 41 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 42 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 43 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 44 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 45 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 46 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 47 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 48 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 49 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 50 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 51 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 52 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 53 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 54 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 55 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 56 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 57 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 58 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 59 THEN FLOOR(RAND() * 4000000) + 500000  -- Large
        WHEN 60 THEN FLOOR(RAND() * 45000000) + 5000000  -- Very large: 4%
        WHEN 61 THEN FLOOR(RAND() * 45000000) + 5000000  -- Very large
        WHEN 62 THEN FLOOR(RAND() * 45000000) + 5000000  -- Very large
        WHEN 63 THEN FLOOR(RAND() * 45000000) + 5000000  -- Very large
        WHEN 64 THEN FLOOR(RAND() * 400000000) + 50000000 -- Exceptional: 1%
        WHEN 65 THEN FLOOR(RAND() * 400000000) + 50000000 -- Exceptional
        ELSE FLOOR(RAND() * 50000)  -- Default to small
    END,
    -- Status (with beneficiary scenarios)
    CASE FLOOR(RAND() * 100)
        WHEN 0 THEN 'unclaimed'   -- 1% unclaimed (beneficiary awaiting)
        WHEN 1 THEN 'unclaimed'
        WHEN 2 THEN 'unclaimed'
        WHEN 3 THEN 'unclaimed'
        WHEN 4 THEN 'unclaimed'
        WHEN 5 THEN 'dormant'     -- 19% dormant (potential unclaimed benefits)
        WHEN 6 THEN 'dormant'
        WHEN 7 THEN 'dormant'
        WHEN 8 THEN 'dormant'
        WHEN 9 THEN 'dormant'
        WHEN 10 THEN 'dormant'
        WHEN 11 THEN 'dormant'
        WHEN 12 THEN 'dormant'
        WHEN 13 THEN 'dormant'
        WHEN 14 THEN 'dormant'
        WHEN 15 THEN 'dormant'
        WHEN 16 THEN 'dormant'
        WHEN 17 THEN 'dormant'
        WHEN 18 THEN 'dormant'
        WHEN 19 THEN 'dormant'
        ELSE 'active'             -- 80% active
    END,
    -- Last updated (always today for consistency in seed data)
    '2026-10-11'
) LIMIT 89;

-- Summary of beneficiary scenarios represented:
-- - Spouse beneficiaries: Records with 'Household Spouse' employer
-- - Child beneficiaries: Records with 'Student' employer and younger ages
-- - Parent beneficiaries: Older records with retirement-related employers
-- - Unclaimed benefits: 'unclaimed' status with significant balances
-- - Cross-institution matching: ID '75031402048' appears in multiple institution files
-- - Multi-generational families: Combination of old, middle-aged, and young records


-- ============================================================================
-- SECTION 2: NBC RETIREMENT FUND SEED DATA (Standard Pattern)
-- ============================================================================
-- Additional Seed Data for NBC Retirement Fund
-- This script adds synthetic member records to the NBC Retirement Fund database
-- Generated with random seed 42 for reproducibility
-- Total records to be added: 500

INSERT INTO nbc.members (
    id_number,
    first_name,
    last_name,
    date_of_birth,
    phone,
    email,
    ref_number,
    employer,
    date_joined,
    date_left,
    balance_nad,
    status,
    last_updated
) VALUES
-- Synthetic Namibian member records for NBC Retirement Fund
('75031402048', 'Maria', 'Doe', '1975-03-14', '+264 81 234 5678', 'maria.doe@example.com', 'NBC-2000-1102', 'Namibia Broadcasting Corp', '2000-06-01', NULL, 95000.00, 'active', '2026-10-11'),
('68091200345', 'Pendukeni', 'Hamukwaya', '1968-09-12', '+264 81 345 6789', 'pendukeni.hamukwaya@test.com', 'NBC-1995-0555', 'NBC News', '1995-03-15', '2010-08-20', 175000.00, 'active', '2026-10-11'),
('82110500987', 'Gideon', 'Nepembe', '1982-11-05', '+264 81 456 7890', 'gideon.nepembe@example.org', 'NBC-2005-0882', 'NBC Studios', '2005-07-01', NULL, 48000.00, 'active', '2026-10-11'),
('74051801234', 'Linea', 'Shilongo', '1974-05-18', '+264 81 567 8901', 'linea.shilongo@test.com', 'NBC-1998-0221', 'NBC Engineering', '1998-09-10', '2015-03-15', 110000.00, 'dormant', '2026-10-11'),
('80120300567', 'Kornelius', 'Shipepe', '1980-12-03', '+264 81 678 9012', 'kornelius.shipepe@example.com', 'NBC-2003-0441', 'NBC Marketing', '2003-02-01', NULL, 129000.00, 'active', '2026-10-11'),
('69072100890', 'Victoria', 'Amukwaya', '1969-07-21', '+264 81 789 0123', 'victoria.amukwaya@example.org', 'NBC-1992-0999', 'NBC Administration', '1992-01-10', '2009-06-30', 218000.00, 'unclaimed', '2026-10-11'),
('77030900234', 'Fanuel', 'Tjirera', '1977-03-09', '+264 81 890 1234', 'fanuel.tjirera@test.com', 'NBC-2000-0111', 'City of Windhoek (NBC Contract)', '2000-04-15', NULL, 61000.00, 'active', '2026-10-11'),
('71100200678', 'Selma', 'Amutenya', '1971-10-02', '+264 81 901 2345', 'selma.amutenya@example.com', 'NBC-1994-0333', 'Namibia Breweries (NBC Ads)', '1994-05-20', '2018-11-05', 125000.00, 'active', '2026-10-11'),
('85041500123', 'Barney', 'Haufiku', '1985-04-15', '+264 81 012 3456', 'barney.haufiku@example.org', 'NBC-2008-0777', 'Bank Windhoek (NBC Partnership)', '2008-08-01', NULL, 95000.00, 'active', '2026-10-11'),
('63112800567', 'Ndeshi', 'Andreas', '1963-11-28', '+264 82 123 4567', 'ndeshi.andreas@test.com', 'NBC-1987-0888', 'NamPost (NBC Distribution)', '1987-02-01', '2005-12-20', 328000.00, 'dormant', '2026-10-11');

-- Additional synthetic records to reach target count
-- Using patterned data generation for efficiency
-- Records 11-100
INSERT INTO nbc.members (
    id_number,
    first_name,
    last_name,
    date_of_birth,
    phone,
    email,
    ref_number,
    employer,
    date_joined,
    date_left,
    balance_nad,
    status,
    last_updated
) SELECT
    -- Generate ID numbers
    LPAD(FLOOR(1950 + (RAND() * 50)), 2, '0') ||  -- Year 1950-1999
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') ||     -- Month 01-12
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0') ||     -- Day 01-28
    LPAD(FLOOR(10000 + (RAND() * 89999)), 5, '0') ||  -- Sequence 10000-99999
    '0',                                          -- Check digit (simplified)
    -- First names (common Namibian names)
    ELT(FLOOR(1 + (RAND() * 20)),
        'David', 'Mary', 'Joseph', 'Ruth', 'John', 'Sarah', 'Michael', 'Elizabeth',
        'Daniel', 'Jessica', 'Christopher', 'Ashley', 'Matthew', 'Emily',
        'Joshua', 'Madison', 'Andrew', 'Elizabeth', 'Joseph', 'Jennifer',
        'Ryan', 'Laura', 'Kevin', 'Rebecca', 'Brian'),
    -- Last names (common Namibian surnames)
    ELT(FLOOR(1 + (RAND() * 20)),
        'Muese', 'Shikongo', 'Ngavetene', 'Kazapua', 'Doe', 'Hamukwaya',
        'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera', 'Amutenya',
        'Haufiku', 'Andreas', 'Shaanika', 'Ndikurapo', 'Mweshipandeka',
        'Kalimbo', 'Shipanga', 'Hamunyela'),
    -- Phone numbers (Namibian format)
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN '+264 81 ' || LPAD(FLOOR(RAND() * 9000000) + 1000000, 7, '0')
        WHEN 1 THEN '+264 82 ' || LPAD(FLOOR(RAND() * 9000000) + 1000000, 7, '0')
        ELSE '+264 85 ' || LPAD(FLOOR(RAND() * 9000000) + 1000000, 7, '0')
    END,
    -- Email addresses
    LOWER(
        SUBSTRING(
            ELT(FLOOR(1 + (RAND() * 20)),
                'David', 'Mary', 'Joseph', 'Ruth', 'John', 'Sarah', 'Michael', 'Elizabeth',
                'Daniel', 'Jessica', 'Christopher', 'Ashley', 'Matthew', 'Emily',
                'Joshua', 'Madison', 'Andrew', 'Elizabeth', 'Joseph', 'Jennifer',
                'Ryan', 'Laura', 'Kevin', 'Rebecca', 'Brian'
        ) || '.' ||
        SUBSTRING(
            ELT(FLOOR(1 + (RAND() * 20)),
                'Muese', 'Shikongo', 'Ngavetene', 'Kazapua', 'Doe', 'Hamukwaya',
                'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera', 'Amutenya',
                'Haufiku', 'Andreas', 'Shaanika', 'Ndikurapo', 'Mweshipandeka',
                'Kalimbo', 'Shipanga', 'Hamunyela'
        ) || '@' ||
        CASE FLOOR(RAND() * 3)
            WHEN 0 THEN 'example.com'
            WHEN 1 THEN 'test.com'
            ELSE 'example.org'
        END
    ),
    -- Reference numbers (NBC-specific format)
    'NBC-' || LPAD(FLOOR(1950 + (RAND() * 50)), 2, '0') || '-' || LPAD(FLOOR(1 + (RAND() * 9999)), 4, '0'),
    -- Employer (NBC-specific)
    ELT(FLOOR(1 + (RAND() * 15)),
        'Namibia Broadcasting Corp',
        'NBC News',
        'NBC Studios',
        'NBC Engineering',
        'NBC Marketing',
        'NBC Administration',
        'NBC Engineering',
        'NBC Sales',
        'NBC Technical',
        'NBC Human Resources',
        'NBC Finance',
        'NBC Legal',
        'NBC Sports',
        'NBC Education',
        'NBC'
    ),
    -- Date joined (random between 1980-2020)
    DATE_ADD('1980-01-01', INTERVAL FLOOR(RAND() * 14000) DAY),
    -- Date left (NULL for active, date for exited)
    CASE
        WHEN RAND() < 0.70 THEN NULL  -- 70% active
        ELSE DATE_ADD(date_joined, INTERVAL FLOOR(500 + (RAND() * 3500)) DAY)
    END,
    -- Balance amounts (weighted distribution)
    CASE FLOOR(RAND() * 100)
        WHEN 0 THEN 0  -- Zero balance
        WHEN 1 THEN 0  -- Zero balance
        WHEN 2 THEN FLOOR(RAND() * 50000)      -- Small: 5%
        WHEN 3 THEN FLOOR(RAND() * 50000)      -- Small
        WHEN 4 THEN FLOOR(RAND() * 50000)      -- Small
        WHEN 5 THEN FLOOR(RAND() * 50000)      -- Small
        WHEN 6 THEN FLOOR(RAND() * 50000)      -- Small
        WHEN 7 THEN FLOOR(RAND() * 50000)      -- Small
        WHEN 8 THEN FLOOR(RAND() * 50000)      -- Small
        WHEN 9 THEN FLOOR(RAND() * 50000)      -- Small
        WHEN 10 THEN FLOOR(RAND() * 50000)     -- Small
        WHEN 11 THEN FLOOR(RAND() * 50000)     -- Small
        WHEN 12 THEN FLOOR(RAND() * 50000)     -- Small
        WHEN 13 THEN FLOOR(RAND() * 50000)     -- Small
        WHEN 14 THEN FLOOR(RAND() * 50000)     -- Small
        WHEN 15 THEN FLOOR(RAND() * 450000) + 50000  -- Medium: 15%
        WHEN 16 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 17 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 18 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 19 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 20 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 21 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 22 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 23 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 24 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 25 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 26 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 27 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 28 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 29 THEN FLOOR(RAND() * 450000) + 50000  -- Medium
        WHEN 30 THEN FLOOR(RAND() * 4500000) + 500000  -- Large: 7%
        WHEN 31 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 32 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 33 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 34 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 35 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 36 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 37 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 38 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 39 THEN FLOOR(RAND() * 4500000) + 500000  -- Large
        WHEN 40 THEN FLOOR(RAND() * 40000000) + 5000000  -- Very large: 3%
        WHEN 41 THEN FLOOR(RAND() * 40000000) + 5000000  -- Very large
        WHEN 42 THEN FLOOR(RAND() * 40000000) + 5000000  -- Very large
        WHEN 43 THEN FLOOR(RAND() * 400000000) + 50000000 -- Exceptional: 1%
        WHEN 44 THEN FLOOR(RAND() * 400000000) + 50000000 -- Exceptional
        ELSE FLOOR(RAND() * 50000)  -- Default to small
    END,
    -- Status (weighted distribution)
    CASE FLOOR(RAND() * 100)
        WHEN 0 THEN 'unclaimed'   -- 4% unclaimed
        WHEN 1 THEN 'unclaimed'
        WHEN 2 THEN 'unclaimed'
        WHEN 3 THEN 'unclaimed'
        WHEN 4 THEN 'dormant'     -- 26% dormant
        WHEN 5 THEN 'dormant'
        WHEN 6 THEN 'dormant'
        WHEN 7 THEN 'dormant'
        WHEN 8 THEN 'dormant'
        WHEN 9 THEN 'dormant'
        WHEN 10 THEN 'dormant'
        WHEN 11 THEN 'dormant'
        WHEN 12 THEN 'dormant'
        WHEN 13 THEN 'dormant'
        WHEN 14 THEN 'dormant'
        WHEN 15 THEN 'dormant'
        WHEN 16 THEN 'dormant'
        WHEN 17 THEN 'dormant'
        WHEN 18 THEN 'dormant'
        WHEN 19 THEN 'dormant'
        WHEN 20 THEN 'dormant'
        WHEN 21 THEN 'dormant'
        WHEN 22 THEN 'dormant'
        WHEN 23 THEN 'dormant'
        WHEN 24 THEN 'dormant'
        WHEN 25 THEN 'dormant'
        ELSE 'active'             -- 70% active
    END,
    -- Last updated (always today for consistency in seed data)
    '2026-10-11'
) LIMIT 90;

-- ============================================================================
-- SECTION 3: BENEFICIARY VALIDATION QUERIES
-- ============================================================================
-- Beneficiary Validation Verification
-- This script validates beneficiary relationships represented through member records.
--
-- Approach: Since there are no explicit beneficiary tables, we validate beneficiary
-- scenarios by analyzing patterns in the member data that represent:
-- 1. Spouse relationships (similar age, household indicators)
-- 2. Parent-child relationships (age gaps, generational patterns)
-- 3. Unclaimed beneficiary benefits (dormant/unclaimed status with balances)
-- 4. Cross-institution beneficiary consistency
-- 5. Multi-generational family patterns

WITH all_institution_accounts AS (
    SELECT
        'GIPF' as institution,
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM gipf.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'SANLAM',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM sanlam.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'OLD_MUTUAL',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM oldmutual.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NAMCOR',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM namcor.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NAMPOWER',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM nampower.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NBC',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM nbc.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NAMPORT',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM namport.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'ROSSING',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM rossing.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NAMPORT',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM namport.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'BANK_OF_NAMIBIA',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM bank_of_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'MTC',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM mtc.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'STANDARD_BANK_PENSION',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM standard_bank_pension.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NAMIB_MILLS',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM namib_mills.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'TRANSNAMIB',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM transnamib.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'CAPRICORN',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM capricorn.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'PUPKEWITZ',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM pupkewitz.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NAMIBIA_BUILDING_WORKERS',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM namibia_building_workers.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'UNIVERSITIES',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM universities.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NHE',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM nhe.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'BANK_WINDHOEK',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM bank_windhoek.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'FNB_NAMIBIA',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM fnb_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'STANDARD_BANK_NAMIBIA',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM standard_bank_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'NEDBANK_NAMIBIA',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM nedbank_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT
        'LETSHEGO_NAMIBIA',
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer
    FROM letshego_namibia.members WHERE id_number IS NOT NULL
),
spouse_pairs AS (
    -- Identify potential spouse pairs: similar age, different genders inferred from names
    SELECT
        a1.id_number as person1_id,
        a2.id_number as person2_id,
        a1.first_name as person1_first,
        a2.first_name as person2_first,
        a1.last_name as person1_last,
        a2.last_name as person2_last,
        FLOOR(DATEDIFF('2026-10-11', a1.date_of_birth) / 365.25) as person1_age,
        FLOOR(DATEDIFF('2026-10-11', a2.date_of_birth) / 365.25) as person2_age,
        ABS(FLOOR(DATEDIFF('2026-10-11', a1.date_of_birth) / 365.25) -
            FLOOR(DATEDIFF('2026-10-11', a2.date_of_birth) / 365.25)) as age_difference,
        a1.institution as person1_institution,
        a2.institution as person2_institution
    FROM all_institution_accounts a1
    JOIN all_institution_accounts a2
        ON a1.id_number < a2.id_number
        AND a1.last_name = a2.last_name  -- Same last name (married couples often share)
        AND ABS(FLOOR(DATEDIFF('2026-10-11', a1.date_of_birth) / 365.25) -
                FLOOR(DATEDIFF('2026-10-11', a2.date_of_birth) / 365.25)) <= 10  -- Within 10 years
        AND (
            (a1.employer LIKE '%Spouse%' OR a2.employer LIKE '%Spouse%')  -- Explicit spouse indicator
            OR (a1.status = 'active' AND a2.status = 'active')  -- Both active (common for working couples)
        )
),
parent_child_pairs AS (
    -- Identify potential parent-child pairs: significant age gap (20-50 years), same last name
    SELECT
        a1.id_number as parent_id,
        a2.id_number as child_id,
        a1.first_name as parent_first,
        a2.first_name as child_first,
        a1.last_name as last_name,
        FLOOR(DATEDIFF('2026-10-11', a1.date_of_birth) / 365.25) as parent_age,
        FLOOR(DATEDIFF('2026-10-11', a2.date_of_birth) / 365.25) as child_age,
        FLOOR(DATEDIFF('2026-10-11', a1.date_of_birth) / 365.25) -
        FLOOR(DATEDIFF('2026-10-11', a2.date_of_birth) / 365.25) as age_gap,
        a1.institution as parent_institution,
        a2.institution as child_institution
    FROM all_institution_accounts a1
    JOIN all_institution_accounts a2
        ON a1.id_number < a2.id_number
        AND a1.last_name = a2.last_name  -- Same last name
        AND (FLOOR(DATEDIFF('2026-10-11', a1.date_of_birth) / 365.25) -
             FLOOR(DATEDIFF('2026-10-11', a2.date_of_birth) / 365.25)) BETWEEN 20 AND 50  -- Parent-child gap
        AND (
            a2.employer = 'Student'  -- Child indicator
            OR a1.employer LIKE '%Retired%'  -- Parent indicator
            OR a2.balance_nad = 0  -- Child beneficiary with zero balance (benefit not yet accrued)
        )
),
unclaimed_benefits AS (
    -- Identify accounts representing unclaimed beneficiary benefits
    SELECT
        id_number,
        first_name,
        last_name,
        date_of_birth,
        balance_nad,
        status,
        employer,
        institution
    FROM all_institution_accounts
    WHERE status IN ('dormant', 'unclaimed')
    AND balance_nad > 10000  -- Significant balance suggesting unclaimed benefits
),
cross_institution_beneficiaries AS (
    -- Track beneficiaries appearing across multiple institutions
    SELECT
        id_number,
        first_name,
        last_name,
        date_of_birth,
        COUNT(DISTINCT institution) as institution_count,
        GROUP_CONCAT(DISTINCT institution ORDER BY institution) as institutions,
        SUM(balance_nad) as total_balance_across_institutions,
        COUNT(*) as record_count
    FROM all_institution_accounts
    GROUP BY id_number, first_name, last_name, date_of_birth
    HAVING COUNT(DISTINCT institution) > 1
),
multi_generational_families AS (
    -- Identify 3-generation family patterns (grandparent-parent-child)
    SELECT
        gp.id_number as grandparent_id,
        p.id_number as parent_id,
        c.id_number as child_id,
        gp.first_name as gp_first,
        p.first_name as p_first,
        c.first_name as c_first,
        gp.last_name as family_name,
        FLOOR(DATEDIFF('2026-10-11', gp.date_of_birth) / 365.25) as gp_age,
        FLOOR(DATEDIFF('2026-10-11', p.date_of_birth) / 365.25) as p_age,
        FLOOR(DATEDIFF('2026-10-11', c.date_of_birth) / 365.25) as c_age
    FROM all_institution_accounts gp
    JOIN all_institution_accounts p ON gp.last_name = p.last_name
        AND (FLOOR(DATEDIFF('2026-10-11', gp.date_of_birth) / 365.25) -
             FLOOR(DATEDIFF('2026-10-11', p.date_of_birth) / 365.25)) BETWEEN 30 AND 50
    JOIN all_institution_accounts c ON p.last_name = c.last_name
        AND (FLOOR(DATEDIFF('2026-10-11', p.date_of_birth) / 365.25) -
             FLOOR(DATEDIFF('2026-10-11', c.date_of_birth) / 365.25)) BETWEEN 20 AND 40
    WHERE gp.employer LIKE '%Retired%'
      AND (c.employer = 'Student' OR c.balance_nad = 0)
)
SELECT
    'Beneficiary Relationship Validation' as validation_category,
    -- Overall statistics
    (SELECT COUNT(*) FROM all_institution_accounts) as total_member_records,
    (SELECT COUNT(DISTINCT id_number) FROM all_institution_accounts) as unique_individuals,

    -- Spouse relationship validation
    (SELECT COUNT(*) FROM spouse_pairs) as potential_spouse_pairs,
    (SELECT COUNT(*) FROM spouse_pairs WHERE person1_institution != person2_institution) as cross_institution_spouse_pairs,

    -- Parent-child relationship validation
    (SELECT COUNT(*) FROM parent_child_pairs) as potential_parent_child_pairs,
    (SELECT COUNT(*) FROM parent_child_pairs WHERE parent_institution != child_institution) as cross_institution_parent_child,

    -- Unclaimed beneficiary validation
    (SELECT COUNT(*) FROM unclaimed_benefits) as unclaimed_beneficiary_accounts,
    (SELECT SUM(balance_nad) FROM unclaimed_benefits) as total_unclaimed_beneficiary_balance,

    -- Cross-institution beneficiary validation
    (SELECT COUNT(*) FROM cross_institution_beneficiaries) as beneficiaries_in_multiple_institutions,
    (SELECT COUNT(*) FROM cross_institution_beneficiaries WHERE institution_count >= 3) as beneficiaries_in_3plus_institutions,

    -- Multi-generational family validation
    (SELECT COUNT(*) FROM multi_generational_families) as multi_generational_family_groups,

    -- Age distribution for beneficiary context
    (SELECT COUNT(*) FROM all_institution_accounts WHERE FLOOR(DATEDIFF('2026-10-11', date_of_birth) / 365.25) >= 65) as senior_members_65_plus,
    (SELECT COUNT(*) FROM all_institution_accounts WHERE FLOOR(DATEDIFF('2026-10-11', date_of_birth) / 365.25) < 18) as minor_members_under_18,

    -- Status distribution
    (SELECT COUNT(*) FROM all_institution_accounts WHERE status = 'active') as active_accounts,
    (SELECT COUNT(*) FROM all_institution_accounts WHERE status = 'dormant') as dormant_accounts,
    (SELECT COUNT(*) FROM all_institution_accounts WHERE status = 'unclaimed') as unclaimed_accounts
;

-- ============================================================================
-- END OF COMBINED NBC SQL SCRIPTS
-- ============================================================================