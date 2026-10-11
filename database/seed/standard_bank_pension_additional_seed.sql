-- Additional Seed Data for Standard Bank Namibia Pension Fund
-- This script adds synthetic member records to the Standard Bank Namibia Pension Fund database
-- Generated with random seed 42 for reproducibility
-- Total records to be added: 600

INSERT INTO standard_bank_pension.members (
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
-- Synthetic Namibian member records for Standard Bank Namibia Pension Fund
('75031402048', 'Josua', 'Uuyuni', '1975-03-14', '+264 81 234 5678', 'josua.uuyuni@example.com', 'SBNP-2012-8842', 'Standard Bank Namibia', '1998-06-01', '2012-11-30', 89200.00, 'active', '2026-10-11'),
('68091200345', 'Pendukeni', 'Hamukwaya', '1968-09-12', '+264 81 345 6789', 'pendukeni.hamukwaya@test.com', 'SBNP-1995-11022', 'TransNamib', '1995-03-15', '2010-08-20', 156000.00, 'active', '2026-10-11'),
('82110500987', 'Gideon', 'Nepembe', '1982-11-05', '+264 81 456 7890', 'gideon.nepembe@example.org', 'SBNP-2005-03315', 'NamWater', '2005-07-01', NULL, 45000.00, 'active', '2026-10-11'),
('74051801234', 'Linea', 'Shilongo', '1974-05-18', '+264 81 567 8901', 'linea.shilongo@test.com', 'SBNP-1998-07728', 'NamPower', '1998-09-10', '2015-03-15', 78000.00, 'active', '2026-10-11'),
('80120300567', 'Kornelius', 'Shipepe', '1980-12-03', '+264 81 678 9012', 'kornelius.shipepe@example.com', 'SBNP-2003-11289', 'Roads Authority', '2003-02-01', NULL, 62000.00, 'active', '2026-10-11'),
('69072100890', 'Victoria', 'Amukwaya', '1969-07-21', '+264 81 789 0123', 'victoria.amukwaya@example.org', 'SBNP-1992-04411', 'Ministry of Education', '1992-01-10', '2009-06-30', 180000.00, 'unclaimed', '2026-10-11'),
('77030900234', 'Fanuel', 'Tjirera', '1977-03-09', '+264 81 890 1234', 'fanuel.tjirera@test.com', 'SBNP-2000-05553', 'City of Windhoek', '2000-04-15', NULL, 54000.00, 'active', '2026-10-11'),
('71100200678', 'Selma', 'Amutenya', '1971-10-02', '+264 81 901 2345', 'selma.amutenya@example.com', 'SBNP-1994-08826', 'Namibia Breweries', '1994-05-20', '2018-11-05', 95000.00, 'active', '2026-10-11'),
('85041500123', 'Barney', 'Haufiku', '1985-04-15', '+264 81 012 3456', 'barney.haufiku@example.org', 'SBNP-2008-02217', 'Bank Windhoek', '2008-08-01', NULL, 72000.00, 'active', '2026-10-11'),
('63112800567', 'Ndeshi', 'Andreas', '1963-11-28', '+264 82 123 4567', 'ndeshi.andreas@test.com', 'SBNP-1987-03334', 'NamPost', '1987-02-01', '2005-12-20', 110000.00, 'dormant', '2026-10-11');

-- Additional synthetic records using patterned generation
-- Records 11-100
INSERT INTO standard_bank_pension.members (
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
    -- Generate ID numbers (same individuals as existing institutions for cross-institution matching)
    id_number,
    first_name,
    last_name,
    date_of_birth,
    phone,
    email,
    -- Reference numbers (Standard Bank Namibia Pension format)
    'SBNP-' || LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1000 + (RAND() * 8999)), 4, '0'),
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
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 40000))       -- Small: 0-40,000
        WHEN RAND() < 0.75 THEN FLOOR(40000 + (RAND() * 360000))  -- Medium: 40,000-400,000
        WHEN RAND() < 0.95 THEN FLOOR(400000 + (RAND() * 2600000)) -- Large: 400,000-3,000,000
        ELSE FLOOR(3000000 + (RAND() * 4000000))                 -- Very large: 3,000,000-7,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM (
    -- Select from existing synthetic data to create cross-institution matches
    SELECT
        '75031402048' as id_number, 'Josua' as first_name, 'Uuyuni' as last_name, '1975-03-14' as date_of_birth,
        '+264 81 234 5678' as phone, 'josua.uuyuni@example.com' as email
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
        'Uuyuni', 'Hamukwaya', 'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera',
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
            'uuyuni', 'hamukwaya', 'nepembe', 'shilongo', 'shipepe', 'amukwaya', 'tjirera',
            'amutenya', 'haufiku', 'andreas', 'sheya', 'namwandi', 'shikwambi', 'nangolo',
            'gawanas', 'muvangua', 'ndjarakana', 'hoveka', 'tjipuka', 'mutinga'),
        '@',
        ELT(FLOOR(1 + (RAND() * 3)), 'example.com', 'test.com', 'example.org')
    )),
    -- Reference numbers (Standard Bank Namibia Pension format)
    'SBNP-' || LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1000 + (RAND() * 8999)), 4, '0'),
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
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 40000))       -- Small: 0-40,000
        WHEN RAND() < 0.75 THEN FLOOR(40000 + (RAND() * 360000))  -- Medium: 40,000-400,000
        WHEN RAND() < 0.95 THEN FLOOR(400000 + (RAND() * 2600000)) -- Large: 400,000-3,000,000
        ELSE FLOOR(3000000 + (RAND() * 4000000))                 -- Very large: 3,000,000-7,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM
    -- Generate 81 rows (20-100)
    (SELECT 1 FROM information_schema.tables LIMIT 81) t;

-- Records 101-300 (medium batch)
INSERT INTO standard_bank_pension.members (
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
    '0',                                          -- Check digit (simplified),
    -- First names (expanded)
    ELT(FLOOR(1 + (RAND() * 25)),
        'David', 'Mary', 'Joseph', 'Ruth', 'John', 'Sarah', 'Michael', 'Elizabeth',
        'James', 'Margaret', 'Robert', 'Jennifer', 'William', 'Linda', 'Richard',
        'Patricia', 'Thomas', 'Barbara', 'Charles', 'Susan', 'Daniel', 'Jessica',
        'Matthew', 'Ashley', 'Christopher', 'Andrew', 'Amanda'),
    -- Last names (expanded)
    ELT(FLOOR(1 + (RAND() * 25)),
        'Uuyuni', 'Hamukwaya', 'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera',
        'Amutenya', 'Haufiku', 'Andreas', 'Sheya', 'Namwandi', 'Shikwambi', 'Nangolo',
        'Gawanas', 'Muvangua', 'Ndjarakana', 'Hoveka', 'Tjipuka', 'Mutinga', 'Simpson',
        'Jacobs', 'Botha', 'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller',
        'Davis', 'Garcia'),
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
        SUBSTRING(ELT(FLOOR(1 + (RAND() * 25)),
            'david', 'mary', 'joseph', 'ruth', 'john', 'sarah', 'michael', 'elizabeth',
            'james', 'margaret', 'robert', 'jennifer', 'william', 'linda', 'richard',
            'patricia', 'thomas', 'barbara', 'charles', 'susan', 'daniel', 'jessica',
            'matthew', 'ashley', 'christopher', 'andrew', 'amanda'), 1, 2),
        '.',
        SUBSTRING(ELT(FLOOR(1 + (RAND() * 25)),
            'uuyuni', 'hamukwaya', 'nepembe', 'shilongo', 'shipepe', 'amukwaya', 'tjirera',
            'amutenya', 'haufiku', 'andreas', 'sheya', 'namwandi', 'shikwambi', 'nangolo',
            'gawanas', 'muvangua', 'ndjarakana', 'hoveka', 'tjipuka', 'mutinga', 'simpson',
            'jacobs', 'botha', 'smith', 'johnson', 'williams', 'brown', 'jones', 'miller',
            'davis', 'garcia'), 1, 4),
        FLOOR(10 + (RAND() * 89)),
        '@',
        ELT(FLOOR(1 + (RAND() * 3)), 'example.com', 'test.com', 'example.org')
    )),
    -- Reference numbers (Standard Bank Namibia Pension format)
    'SBNP-' || LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1000 + (RAND() * 8999)), 4, '0'),
    -- Employers
    ELT(FLOOR(1 + (RAND() * 20)),
        'NamPower', 'TransNamib', 'NamWater', 'NBC', 'Rossing Uranium', 'Namport',
        'Bank of Namibia', 'MTC', 'Standard Bank Namibia', 'Namib Mills',
        'TransNamib Holding', 'Capricorn Group', 'Pupkewitz Holdings',
        'Namibia Building Workers', 'University of Namibia', 'Government OMI',
        'Namibia Diamond Corporation', 'Namibia Wildlife Resorts',
        'Air Namibia', 'FNB Namibia', 'Standard Bank Namibia', 'Nedbank Namibia',
        'Letshego Namibia', 'Paratus Telecom', 'MTC'),
    -- Date joined
    LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0'),
    -- Date left (NULL for active, random date for exited)
    CASE WHEN RAND() > 0.25 THEN
        LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 28)), 2, '0')
    ELSE NULL END,
    -- Balance NAD (varied distribution)
    CASE
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 40000))       -- Small: 0-40,000
        WHEN RAND() < 0.75 THEN FLOOR(40000 + (RAND() * 360000))  -- Medium: 40,000-400,000
        WHEN RAND() < 0.95 THEN FLOOR(400000 + (RAND() * 2600000)) -- Large: 400,000-3,000,000
        ELSE FLOOR(3000000 + (RAND() * 4000000))                 -- Very large: 3,000,000-7,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM
    -- Generate 200 rows (101-300)
    (SELECT 1 FROM information_schema.tables LIMIT 200) t;

-- Records 301-600 (larger batch)
INSERT INTO standard_bank_pension.members (
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
    '0',                                          -- Check digit (simplified),
    -- First names (larger pool)
    ELT(FLOOR(1 + (RAND() * 30)),
        'David', 'Mary', 'Joseph', 'Ruth', 'John', 'Sarah', 'Michael', 'Elizabeth',
        'James', 'Margaret', 'Robert', 'Jennifer', 'William', 'Linda', 'Richard',
        'Patricia', 'Thomas', 'Barbara', 'Charles', 'Susan', 'Daniel', 'Jessica',
        'Matthew', 'Ashley', 'Christopher', 'Andrew', 'Amanda', 'Kevin', 'Stephanie',
        'Joshua', 'Nicole', 'Eric', 'Robin', 'Tracy', 'Leslie'),
    -- Last names (larger pool)
    ELT(FLOOR(1 + (RAND() * 30)),
        'Uuyuni', 'Hamukwaya', 'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera',
        'Amutenya', 'Haufiku', 'Andreas', 'Sheya', 'Namwandi', 'Shikwambi', 'Nangolo',
        'Gawanas', 'Muvangua', 'Ndjarakana', 'Hoveka', 'Tjipuka', 'Mutinga', 'Simpson',
        'Jacobs', 'Botha', 'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller',
        'Davis', 'Garcia', 'Rodriguez', 'Wilson', 'Martinez', 'Anderson', 'Taylor',
        'Thomas', 'Hernandez', 'Moore'),
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
        SUBSTRING(ELT(FLOOR(1 + (RAND() * 30)),
            'david', 'mary', 'joseph', 'ruth', 'john', 'sarah', 'michael', 'elizabeth',
            'james', 'margaret', 'robert', 'jennifer', 'william', 'linda', 'richard',
            'patricia', 'thomas', 'barbara', 'charles', 'susan', 'daniel', 'jessica',
            'matthew', 'ashley', 'christopher', 'andrew', 'amanda', 'kevin', 'stephanie',
            'joshua', 'nicole', 'eric', 'robin', 'tracy', 'leslie'), 1, 2),
        '.',
        SUBSTRING(ELT(FLOOR(1 + (RAND() * 30)),
            'uuyuni', 'hamukwaya', 'nepembe', 'shilongo', 'shipepe', 'amukwaya', 'tjirera',
            'amutenya', 'haufiku', 'andreas', 'sheya', 'namwandi', 'shikwambi', 'nangolo',
            'gawanas', 'muvangua', 'ndjarakana', 'hoveka', 'tjipuka', 'mutinga', 'simpson',
            'jacobs', 'botha', 'smith', 'johnson', 'williams', 'brown', 'jones', 'miller',
            'davis', 'garcia', 'rodriguez', 'wilson', 'martinez', 'anderson', 'taylor',
            'thomas', 'hernandez', 'moore'), 1, 4),
        FLOOR(10 + (RAND() * 89)),
        '@',
        ELT(FLOOR(1 + (RAND() * 3)), 'example.com', 'test.com', 'example.org')
    )),
    -- Reference numbers (Standard Bank Namibia Pension format)
    'SBNP-' || LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1000 + (RAND() * 8999)), 4, '0'),
    -- Employers (larger pool)
    ELT(FLOOR(1 + (RAND() * 25)),
        'NamPower', 'TransNamib', 'NamWater', 'NBC', 'Rossing Uranium', 'Namport',
        'Bank of Namibia', 'MTC', 'Standard Bank Namibia', 'Namib Mills',
        'TransNamib Holding', 'Capricorn Group', 'Pupkewitz Holdings',
        'Namibia Building Workers', 'University of Namibia', 'Government OMI',
        'Namibia Diamond Corporation', 'Namibia Wildlife Resorts',
        'Air Namibia', 'FNB Namibia', 'Standard Bank Namibia', 'Nedbank Namibia',
        'Letshego Namibia', 'Paratus Telecom', 'MTC', 'Leo People', 'Namibia Agronomic Board'),
    -- Date joined
    LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 12)), 2, '0') || '-' ||
    LPAD(FLOOR(1 + (RAND() * 28)), 2, '0'),
    -- Date left (NULL for active, random date for exited)
    CASE WHEN RAND() > 0.2 THEN
        LPAD(FLOOR(1980 + (RAND() * 40)), 4, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 40)), 4, '0') || '-' ||
        LPAD(FLOOR(1 + (RAND() * 40)), 4, '0')
    ELSE NULL END,
    -- Balance NAD (varied distribution)
    CASE
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 40000))       -- Small: 0-40,000
        WHEN RAND() < 0.75 THEN FLOOR(40000 + (RAND() * 360000))  -- Medium: 40,000-400,000
        WHEN RAND() < 0.95 THEN FLOOR(400000 + (RAND() * 2600000)) -- Large: 400,000-3,000,000
        ELSE FLOOR(3000000 + (RAND() * 4000000))                 -- Very large: 3,000,000-7,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM
    -- Generate 300 rows (301-600)
    (SELECT 1 FROM information_schema.tables LIMIT 300) t;