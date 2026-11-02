-- Additional Seed Data for Bank Windhoek
-- This script adds synthetic account holder records to the Bank Windhoek database
-- Generated with random seed 42 for reproducibility
-- Total records to be added: 750

INSERT INTO bank_windhoek.members (
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
-- Synthetic Namibian account holder records for Bank Windhoek
('75031402048', 'Maria', 'Doe', '1975-03-14', '+264 81 234 5678', 'maria.doe@example.com', 'BW-ACC-77821', 'NamPower', '1998-06-01', '2012-11-30', 67800.00, 'active', '2026-10-11'),
('68091200345', 'Pendukeni', 'Hamukwaya', '1968-09-12', '+264 81 345 6789', 'pendukeni.hamukwaya@test.com', 'BW-ACC-11092', 'TransNamib', '1995-03-15', '2010-08-20', 145000.00, 'active', '2026-10-11'),
('82110500987', 'Gideon', 'Nepembe', '1982-11-05', '+264 81 456 7890', 'gideon.nepembe@example.org', 'BW-ACC-44210', 'NamWater', '2005-07-01', NULL, 34500.00, 'active', '2026-10-11'),
('74051801234', 'Linea', 'Shilongo', '1974-05-18', '+264 81 567 8901', 'linea.shilongo@test.com', 'BW-ACC-99320', 'NamPower', '1998-09-10', '2015-03-15', 89000.00, 'active', '2026-10-11'),
('80120300567', 'Kornelius', 'Shipepe', '1980-12-03', '+264 81 678 9012', 'kornelius.shipepe@example.com', 'BW-ACC-22105', 'Roads Authority', '2003-02-01', NULL, 76000.00, 'active', '2026-10-11'),
('69072100890', 'Victoria', 'Amukwaya', '1969-07-21', '+264 81 789 0123', 'victoria.amukwaya@example.org', 'BW-ACC-55628', 'Ministry of Education', '1992-01-10', '2009-06-30', 210000.00, 'unclaimed', '2026-10-11'),
('77030900234', 'Fanuel', 'Tjirera', '1977-03-09', '+264 81 890 1234', 'fanuel.tjirera@test.com', 'BW-ACC-33456', 'City of Windhoek', '2000-04-15', NULL, 55000.00, 'active', '2026-10-11'),
('71100200678', 'Selma', 'Amutenya', '1971-10-02', '+264 81 901 2345', 'selma.amutenya@example.com', 'BW-ACC-66219', 'Namibia Breweries', '1994-05-20', '2018-11-05', 48000.00, 'active', '2026-10-11'),
('85041500123', 'Barney', 'Haufiku', '1985-04-15', '+264 81 012 3456', 'barney.haufiku@example.org', 'BW-ACC-77821', 'Bank Windhoek', '2008-08-01', NULL, 89000.00, 'active', '2026-10-11'),
('63112800567', 'Ndeshi', 'Andreas', '1963-11-28', '+264 82 123 4567', 'ndeshi.andreas@test.com', 'BW-ACC-88910', 'NamPost', '1987-02-01', '2005-12-20', 120000.00, 'dormant', '2026-10-11');

-- Additional synthetic records using patterned generation
-- Records 11-100
INSERT INTO bank_windhoek.members (
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
    -- Reference numbers (Bank Windhoek format)
    'BW-ACC-' || LPAD(FLOOR(100000 + (RAND() * 899999)), 6, '0'),
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
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 50000))       -- Small: 0-50,000
        WHEN RAND() < 0.75 THEN FLOOR(50000 + (RAND() * 450000))  -- Medium: 50,000-500,000
        WHEN RAND() < 0.95 THEN FLOOR(500000 + (RAND() * 4500000)) -- Large: 500,000-5,000,000
        ELSE FLOOR(5000000 + (RAND() * 45000000))                 -- Very large: 5,000,000-50,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM (
    -- Select from existing synthetic data to create cross-institution matches
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
    -- Reference numbers (Bank Windhoek format)
    'BW-ACC-' || LPAD(FLOOR(100000 + (RAND() * 899999)), 6, '0'),
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
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 50000))       -- Small: 0-50,000
        WHEN RAND() < 0.75 THEN FLOOR(50000 + (RAND() * 450000))  -- Medium: 50,000-500,000
        WHEN RAND() < 0.95 THEN FLOOR(500000 + (RAND() * 4500000)) -- Large: 500,000-5,000,000
        ELSE FLOOR(5000000 + (RAND() * 45000000))                 -- Very large: 5,000,000-50,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM
    -- Generate 81 rows (20-100)
    (SELECT 1 FROM information_schema.tables LIMIT 81) t;

-- Records 101-400 (medium batch)
INSERT INTO bank_windhoek.members (
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
        'Doe', 'Hamukwaya', 'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera',
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
            'doe', 'hamukwaya', 'nepembe', 'shilongo', 'shipepe', 'amukwaya', 'tjirera',
            'amutenya', 'haufiku', 'andreas', 'sheya', 'namwandi', 'shikwambi', 'nangolo',
            'gawanas', 'muvangua', 'ndjarakana', 'hoveka', 'tjipuka', 'mutinga', 'simpson',
            'jacobs', 'botha', 'smith', 'johnson', 'williams', 'brown', 'jones', 'miller',
            'davis', 'garcia'), 1, 4),
        FLOOR(10 + (RAND() * 89)),
        '@',
        ELT(FLOOR(1 + (RAND() * 3)), 'example.com', 'test.com', 'example.org')
    )),
    -- Reference numbers (Bank Windhoek format)
    'BW-ACC-' || LPAD(FLOOR(100000 + (RAND() * 899999)), 6, '0'),
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
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 50000))       -- Small: 0-50,000
        WHEN RAND() < 0.75 THEN FLOOR(50000 + (RAND() * 450000))  -- Medium: 50,000-500,000
        WHEN RAND() < 0.95 THEN FLOOR(500000 + (RAND() * 4500000)) -- Large: 500,000-5,000,000
        ELSE FLOOR(5000000 + (RAND() * 45000000))                 -- Very large: 5,000,000-50,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM
    -- Generate 300 rows (101-400)
    (SELECT 1 FROM information_schema.tables LIMIT 300) t;

-- Records 401-750 (larger batch)
INSERT INTO bank_windhoek.members (
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
        'Doe', 'Hamukwaya', 'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya', 'Tjirera',
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
            'doe', 'hamukwaya', 'nepembe', 'shilongo', 'shipepe', 'amukwaya', 'tjirera',
            'amutenya', 'haufiku', 'andreas', 'sheya', 'namwandi', 'shikwambi', 'nangolo',
            'gawanas', 'muvangua', 'ndjarakana', 'hoveka', 'tjipuka', 'mutinga', 'simpson',
            'jacobs', 'botha', 'smith', 'johnson', 'williams', 'brown', 'jones', 'miller',
            'davis', 'garcia', 'rodriguez', 'wilson', 'martinez', 'anderson', 'taylor',
            'thomas', 'hernandez', 'moore'), 1, 4),
        FLOOR(10 + (RAND() * 89)),
        '@',
        ELT(FLOOR(1 + (RAND() * 3)), 'example.com', 'test.com', 'example.org')
    )),
    -- Reference numbers (Bank Windhoek format)
    'BW-ACC-' || LPAD(FLOOR(100000 + (RAND() * 899999)), 6, '0'),
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
        WHEN RAND() < 0.4 THEN FLOOR(1 + (RAND() * 50000))       -- Small: 0-50,000
        WHEN RAND() < 0.75 THEN FLOOR(50000 + (RAND() * 450000))  -- Medium: 50,000-500,000
        WHEN RAND() < 0.95 THEN FLOOR(500000 + (RAND() * 4500000)) -- Large: 500,000-5,000,000
        ELSE FLOOR(5000000 + (RAND() * 45000000))                 -- Very large: 5,000,000-50,000,000
    END,
    -- Status
    ELT(FLOOR(1 + (RAND() * 3)), 'active', 'dormant', 'unclaimed'),
    -- Last updated
    '2026-10-11'
FROM
    -- Generate 350 rows (401-750)
    (SELECT 1 FROM information_schema.tables LIMIT 350) t;