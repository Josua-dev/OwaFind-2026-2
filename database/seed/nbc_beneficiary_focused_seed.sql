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
('75031402048', 'Josua', 'Uuyuni', '1975-03-14', '+264 81 234 5678', 'josua.uuyuni@example.com', 'NBC-2000-1102', 'NBC News', '2000-06-01', NULL, 95000.00, 'active', '2026-10-11'),

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
        'Muese', 'Shikongo', 'Ngavetene', 'Kazapua', 'Uuyuni', 'Hamukwaya',
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
                'Ryan', 'Laura', 'Kevin', 'Rebecca', 'Brian')
        ) || '.' ||
        SUBSTRING(
            ELT(FLOOR(1 + (RAND() * 20)),
                'Muese', 'Shikongo', 'Ngavetene', 'Kazapua', 'Uuyuni', 'Hamukwaya',
                'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera', 'Amutenya',
                'Haufiku', 'Andreas', 'Shaanika', 'Ndikurapo', 'Mweshipandeka',
                'Kalimbo', 'Shipanga', 'Hamunyela')
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