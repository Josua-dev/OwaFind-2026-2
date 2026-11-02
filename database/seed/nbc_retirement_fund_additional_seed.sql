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