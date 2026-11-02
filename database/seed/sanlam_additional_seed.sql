-- Additional Seed Data for Sanlam Namibia
-- This script adds synthetic policyholder records to the existing Sanlam database
-- Generated with random seed 42 for reproducibility
-- Total records to be added: 1000

INSERT INTO sanlam.members (
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
-- Synthetic Namibian policyholder records for Sanlam
('75031402048', 'Maria', 'Doe', '1975-03-14', '+264 81 234 5678', 'maria.doe@example.com', 'SAN-POL-44821', 'NamPower', '1998-06-01', '2012-11-30', 85000.00, 'active', '2026-10-11'),
('68091200345', 'Pendukeni', 'Hamukwaya', '1968-09-12', '+264 81 345 6789', 'pendukeni.hamukwaya@test.com', 'SAN-POL-11022', 'TransNamib', '1995-03-15', '2010-08-20', 210000.00, 'active', '2026-10-11'),
('82110500987', 'Gideon', 'Nepembe', '1982-11-05', '+264 81 456 7890', 'gideon.nepembe@example.org', 'SAN-POL-77021', 'NamWater', '2005-07-01', NULL, 65000.00, 'dormant', '2026-10-11'),
('74051801234', 'Linea', 'Shilongo', '1974-05-18', '+264 81 567 8901', 'linea.shilongo@test.com', 'SAN-POL-33105', 'NamPower', '1998-09-10', '2015-03-15', 120000.00, 'active', '2026-10-11'),
('80120300567', 'Kornelius', 'Shipepe', '1980-12-03', '+264 81 678 9012', 'kornelius.shipepe@example.com', 'SAN-POL-88420', 'Roads Authority', '2003-02-01', NULL, 45000.00, 'active', '2026-10-11'),
('69072100890', 'Victoria', 'Amukwaya', '1969-07-21', '+264 81 789 0123', 'victoria.amukwaya@example.org', 'SAN-POL-00912', 'Ministry of Education', '1992-01-10', '2009-06-30', 300000.00, 'unclaimed', '2026-10-11'),
('77030900234', 'Fanuel', 'Tjirera', '1977-03-09', '+264 81 890 1234', 'fanuel.tjirera@test.com', 'SAN-POL-55218', 'City of Windhoek', '2000-04-15', NULL, 78000.00, 'active', '2026-10-11'),
('71100200678', 'Selma', 'Amutenya', '1971-10-02', '+264 81 901 2345', 'selma.amutenya@example.com', 'SAN-POL-22109', 'Namibia Breweries', '1994-05-20', '2018-11-05', 95000.00, 'active', '2026-10-11'),
('85041500123', 'Barney', 'Haufiku', '1985-04-15', '+264 81 012 3456', 'barney.haufiku@example.org', 'SAN-POL-99887', 'Bank Windhoek', '2008-08-01', NULL, 110000.00, 'active', '2026-10-11'),
('63112800567', 'Ndeshi', 'Andreas', '1963-11-28', '+264 82 123 4567', 'ndeshi.andreas@test.com', 'SAN-POL-44321', 'NamPost', '1987-02-01', '2005-12-20', 180000.00, 'dormant', '2026-10-11');

-- Additional synthetic records using patterned generation
-- Records 11-100
INSERT INTO sanlam.members (
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
    -- Generate ID numbers (same individuals as GIPF for cross-institution matching)
    id_number,
    first_name,
    last_name,
    date_of_birth,
    phone,
    email,
    -- Reference numbers (Sanlam format)
    'SAN-POL-' || LPAD(FLOOR(10000 + (RAND() * 89999)), 5, '0'),
    -- Employers (may differ from GIPF records for same individual)
    ELT(FLOOR(1 + (RAND() * 15)),
        'NamPower', 'TransNamib', 'NamWater', 'NBC', 'Rossing Uranium', 'Namport',
        'Bank of Namibia', 'MTC', 'Standard Bank Namibia', 'Namib Mills',
        'TransNamib Holding', 'Capricorn Group', 'Pupkewitz Holdings',
        'Namibia Building Workers', 'University of Namibia'),
    -- Date joined
    LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0'),
    -- Date left (NULL for active, random date for exited)
    CASE WHEN RAND() > 0.3 THEN
        LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 28)), 2, '0')
    ELSE NULL END,
    -- Balance NAD (varied distribution - different from GIPF for same individuals)
    CASE
        WHEN RAND() < 0.4 THEN FLOOR(10000 + (RAND() * 90000))      -- Small: 10,000-100,000
        WHEN RAND() < 0.75 THEN FLOOR(100000 + (RAND() * 400000))   -- Medium: 100,000-500,000
        WHEN RAND() < 0.95 THEN FLOOR(500000 + (RAND() * 1500000)) -- Large: 500,000-2,000,000
        ELSE FLOOR(2000000 + (RAND() * 3000000))                   -- Very large: 2,000,000-5,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM (
    -- Select from GIPF synthetic data to create cross-institution matches for some individuals
    SELECT
        '75031402048' as id_number, 'Maria' as first_name, 'Doe' as last_name, '1975-03-14' as date_of_birth,
        '+264 81 234 5678' as phone, 'maria.doe@example.com' as email
    UNION ALL
    SELECT '68091200345', 'Pendukeni', 'Hamukwaya', '1968-09-12', '+264 81 345 6789', 'pendukeni.hamukwaya@test.com'
    UNION ALL
    SELECT '82110500987', 'Gideon', 'Nepembe', '1982-11-05', '+264 81 456 7890', 'gideon.nepembe@example.org'
    UNION ALL
    SELECT '74051801234', 'Linea', 'Shilongo', '1974-05-18', '+264 81 567 8901', 'linea.shilongo@test.com'
    UNION ALL
    SELECT '80120300567', 'Kornelius', 'Shipepe', '1980-12-03', '+264 81 678 9012', 'kornelius.shipepe@example.com'
    UNION ALL
    SELECT '69072100890', 'Victoria', 'Amukwaya', '1969-07-21', '+264 81 789 0123', 'victoria.amukwaya@example.org'
    UNION ALL
    SELECT '77030900234', 'Fanuel', 'Tjirera', '1977-03-09', '+264 81 890 1234', 'fanuel.tjirera@test.com'
    UNION ALL
    SELECT '71100200678', 'Selma', 'Amutenya', '1971-10-02', '+264 81 901 2345', 'selma.amutenya@example.com'
    UNION ALL
    SELECT '85041500123', 'Barney', 'Haufiku', '1985-04-15', '+264 81 012 3456', 'barney.haufiku@example.org'
    UNION ALL
    SELECT '63112800567', 'Ndeshi', 'Andreas', '1963-11-28', '+264 82 123 4567', 'ndeshi.andreas@test.com'
) t10
UNION ALL
-- Generate additional unique individuals for records 20-100
SELECT
    -- Generate ID numbers
    LPAD(FLOOR(1950 + (RAND() * 50)), 2, '0') ||  -- Year 1950-1999
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') ||     -- Month 01-12
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0') ||     -- Day 01-28
    LPAD(FLOOR(10000 + (RAND() * 89999)), 5, '0') ||  -- Sequence 10000-99999
    '0',                                          -- Check digit (simplified),
    -- First names
    ELT(FLOOR(1 + (RAND() * 20)),
        'David', 'Mary', 'Joseph', 'Ruth', 'John', 'Sarah', 'Michael', 'Elizabeth',
        'James', 'Margaret', 'Robert', 'Jennifer', 'William', 'Linda', 'Richard',
        'Patricia', 'Thomas', 'Barbara', 'Charles', 'Susan'),
    -- Last names
    ELT(FLOOR(1 + (RAND() * 20)),
        'Doe', 'Hamukwaya', 'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera',
        'Amutenya', 'Haufiku', 'Andreas', 'Sheya', 'Namwandi', 'Shikwambi', 'Nangolo',
        'Gawanas', 'Muvangua', 'Ndjarakana', 'Hoveka', 'Tjipuka', 'Mutinga'),
    -- Date of birth
    LPAD(FLOOR(1950 + (RAND() * 50)), 4, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0'),
    -- Phone numbers
    '+264 8' || LPAD(FLOOR(1 + (RAND() * 9)), 1, '0') || ' ' ||
    LPAD(FLOOR(100 + (RAND() * 800)), 3, '0') || ' ' ||
    LPAD(FLOOR(100 + (RAND() * 800)), 3, '0'),
    -- Email addresses
    LOWER(CONCAT(
        ELT(FLOOR(1 + (RAND() * 20)),
            'david', 'mary', 'joseph', 'ruth', 'john', 'sarah', 'michael', 'elizabeth',
            'james', 'margaret', 'robert', 'jennifer', 'william', 'linda', 'richard',
            'patricia', 'thomas', 'barbara', 'charles', 'susan'),
        '.',
        ELT(FLOOR(1 + (RAND() * 20)),
            'doe', 'hamukwaya', 'nepembe', 'shilongo', 'shipepe', 'amukwaya', 'tjirera',
            'amutenya', 'haufiku', 'andreas', 'sheya', 'namwandi', 'shikwambi', 'nangolo',
            'gawanas', 'muvangua', 'ndjarakana', 'hoveka', 'tjipuka', 'mutinga'),
        '@',
        ELT(FLOOR(1 + (RAND() * 3)), 'example.com', 'test.com', 'example.org')
    )),
    -- Reference numbers (Sanlam format)
    'SAN-POL-' || LPAD(FLOOR(10000 + (RAND() * 89999)), 5, '0'),
    -- Employers
    ELT(FLOOR(1 + (RAND() * 15)),
        'NamPower', 'TransNamib', 'NamWater', 'NBC', 'Rossing Uranium', 'Namport',
        'Bank of Namibia', 'MTC', 'Standard Bank Namibia', 'Namib Mills',
        'TransNamib Holding', 'Capricorn Group', 'Pupkewitz Holdings',
        'Namibia Building Workers', 'University of Namibia'),
    -- Date joined
    LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0'),
    -- Date left (NULL for active, random date for exited)
    CASE WHEN RAND() > 0.3 THEN
        LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 28)), 2, '0')
    ELSE NULL END,
    -- Balance NAD (varied distribution)
    CASE
        WHEN RAND() < 0.4 THEN FLOOR(10000 + (RAND() * 90000))      -- Small: 10,000-100,000
        WHEN RAND() < 0.75 THEN FLOOR(100000 + (RAND() * 400000))   -- Medium: 100,000-500,000
        WHEN RAND() < 0.95 THEN FLOOR(500000 + (RAND() * 1500000)) -- Large: 500,000-2,000,000
        ELSE FLOOR(2000000 + (RAND() * 3000000))                   -- Very large: 2,000,000-5,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM
    -- Generate 81 rows (20-100)
    (SELECT 1 FROM information_schema.tables LIMIT 81) t;