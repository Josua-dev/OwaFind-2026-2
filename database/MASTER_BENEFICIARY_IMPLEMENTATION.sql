-- ============================================================================
-- MASTER BENEFICIARY IMPLEMENTATION SQL SCRIPT
-- OwaFind Namibia Multi-Institution Database Expansion
--
-- This script demonstrates the beneficiary data implementation approach
-- for the OwaFind platform, showing how beneficiary relationships are
-- represented through the existing FirmMember schema without inventing
-- new tables or modifying the schema.
-- ============================================================================
--
-- Approach: Beneficiary relationships are represented through existing
-- member records using:
-- 1. Similar ages and same last names for family relationships
-- 2. Status fields (active/dormant/unclaimed) to indicate beneficiary scenarios
-- 3. Employer field indicators ("Household Spouse", "Student", "Retired")
-- 4. Cross-institution matching via identical ID numbers
--
-- This script contains:
-- 1. Sample beneficiary-focused seed data demonstrating the approach
-- 2. Validation queries to verify beneficiary relationship integrity
--
-- ============================================================================

-- ============================================================================
-- SECTION 1: SAMPLE BENEFICIARY-FOCUSED SEED DATA
-- ============================================================================
-- This section demonstrates how to represent various beneficiary scenarios
-- using the existing members table structure (FirmMember interface).

-- NOTE: In practice, this data would be inserted into each institution's
-- members table (e.g., nbc.members, gipf.members, sanlam.members, etc.)
-- For demonstration, we'll use a sample institution table.

-- Sample data showing beneficiary relationships for NBC Retirement Fund

-- Clear beneficiary scenarios demonstrated:

-- SCENARIO 1: Spouse Beneficiary Pair
-- Same last name, similar age (~3 year difference), household indicator
INSERT OR IGNORE INTO nbc.members (
    id_number, first_name, last_name, date_of_birth, phone, email,
    ref_number, employer, date_joined, date_left, balance_nad, status, last_updated
) VALUES
('65041200345', 'Katutura', 'Muese', '1965-04-12', '+264 81 234 5678', 'katutura.muese@example.com',
 'NBC-1990-1102', 'Namibia Broadcasting Corp', '1990-03-15', NULL, 325000.00, 'active', '2026-10-11'),
('68090300456', 'Emma', 'Muese', '1968-09-03', '+264 81 345 6789', 'emma.muese@test.com',
 'NBC-1993-0441', 'Household Spouse', '1993-07-22', NULL, 185000.00, 'active', '2026-10-11');

-- SCENARIO 2: Parent-Child Beneficiary Relationship
-- Same last name, significant age gap (23 years), child indicator
INSERT OR IGNORE INTO nbc.members (
    id_number, first_name, last_name, date_of_birth, phone, email,
    ref_number, employer, date_joined, date_left, balance_nad, status, last_updated
) VALUES
('72111800567', 'Daniel', 'Shikongo', '1972-11-18', '+264 81 456 7890', 'daniel.shikongo@example.org',
 'NBC-1998-0772', 'NBC Studios', '1998-09-10', NULL, 410000.00, 'active', '2026-10-11'),
('95021400678', 'Rachel', 'Shikongo', '1995-02-14', '+264 81 567 8901', 'rachel.shikongo@test.com',
 'NBC-2013-0221', 'Student', '2013-04-01', NULL, 0.00, 'dormant', '2026-10-11');  -- Child beneficiary

-- SCENARIO 3: Multi-Generational Family Pattern
-- Grandparent (retired), Parent (active), Child (student)
INSERT OR IGNORE INTO nbc.members (
    id_number, first_name, last_name, date_of_birth, phone, email,
    ref_number, employer, date_joined, date_left, balance_nad, status, last_updated
) VALUES
('48082200890', 'Maria', 'Ngavetene', '1948-08-22', '+264 81 789 0123', 'maria.ngavetene@example.org',
 'NBC-1975-0441', 'Retired Teacher', '1975-01-10', '2008-12-31', 75000.00, 'dormant', '2026-10-11'),  -- Grandparent
('72111800567', 'Daniel', 'Shikongo', '1972-11-18', '+264 81 456 7890', 'daniel.shikongo@example.org',
 'NBC-1998-0772', 'NBC Studios', '1998-09-10', NULL, 410000.00, 'active', '2026-10-11'),        -- Parent
('01050900123', 'Samuel', 'Shikongo', '2001-05-09', '+264 81 901 2345', 'samuel.shikongo@example.com',
 'NBC-2020-0882', 'Student', '2020-06-01', NULL, 0.00, 'dormant', '2026-10-11');                  -- Child

-- SCENARIO 4: Unclaimed Beneficiary Benefits
-- Dormant/unclaimed status with significant balances (benefits awaiting distribution)
INSERT OR IGNORE INTO nbc.members (
    id_number, first_name, last_name, date_of_birth, phone, email,
    ref_number, employer, date_joined, date_left, balance_nad, status, last_updated
) VALUES
('55070900123', 'Samuel', 'Kazapua', '1955-07-09', '+264 81 890 1234', 'samuel.kazapua@test.com',
 'NBC-1980-0555', 'NBC Engineering', '1980-04-15', '2010-06-30', 220000.00, 'unclaimed', '2026-10-11'),
('58122500234', 'Veronica', 'Kazapua', '1958-12-25', '+264 81 901 2345', 'veronica.kazapua@example.org',
 'NBC-1983-0882', 'Household Spouse', '1983-08-20', '2015-03-14', 190000.00, 'unclaimed', '2026-10-11');

-- SCENARIO 5: Cross-Institution Beneficiary Matching
-- Same individual appearing in multiple institutions with same ID
-- (This ID would also appear in GIPF, Sanlam, Old Mutual tables)
INSERT OR IGNORE INTO nbc.members (
    id_number, first_name, last_name, date_of_birth, phone, email,
    ref_number, employer, date_joined, date_left, balance_nad, status, last_updated
) VALUES
('75031402048', 'Josua', 'Uuyuni', '1975-03-14', '+264 81 234 5678', 'josua.uuyuni@example.com',
 'NBC-2000-1102', 'NBC News', '2000-06-01', NULL, 95000.00, 'active', '2026-10-11');

-- ============================================================================
-- SECTION 2: BENEFICIARY VALIDATION QUERIES
-- ============================================================================
-- These queries validate that beneficiary relationships are properly represented

-- Validation Query 1: Spouse Pair Detection
-- Finds potential spouse pairs: same last name, similar age (≤10 years), household indicators
SELECT
    'Spouse Pair Validation' as validation_type,
    m1.id_number as spouse1_id,
    m2.id_number as spouse2_id,
    m1.first_name as spouse1_first,
    m2.first_name as spouse2_first,
    m1.last_name as shared_last_name,
    FLOOR(DATEDIFF('2026-10-11', m1.date_of_birth) / 365.25) as spouse1_age,
    FLOOR(DATEDIFF('2026-10-11', m2.date_of_birth) / 365.25) as spouse2_age,
    ABS(FLOOR(DATEDIFF('2026-10-11', m1.date_of_birth) / 365.25) -
        FLOOR(DATEDIFF('2026-10-11', m2.date_of_birth) / 365.25)) as age_difference,
    m1.employer as spouse1_employer,
    m2.employer as spouse2_employer,
    m1.status as spouse1_status,
    m2.status as spouse2_status
FROM nbc.members m1
JOIN nbc.members m2 ON m1.id_number < m2.id_number
    AND m1.last_name = m2.last_name
    AND ABS(FLOOR(DATEDIFF('2026-10-11', m1.date_of_birth) / 365.25) -
            FLOOR(DATEDIFF('2026-10-11', m2.date_of_birth) / 365.25)) <= 10
    AND (m1.employer LIKE '%Spouse%' OR m2.employer LIKE '%Spouse%'
         OR (m1.status = 'active' AND m2.status = 'active'))
ORDER BY m1.last_name, m1.first_name;

-- Validation Query 2: Parent-Child Relationship Detection
-- Finds potential parent-child pairs: same last name, age gap 20-50 years, child/student indicator
SELECT
    'Parent-Child Validation' as validation_type,
    parent.id_number as parent_id,
    child.id_number as child_id,
    parent.first_name as parent_first,
    child.first_name as child_first,
    parent.last_name as shared_last_name,
    FLOOR(DATEDIFF('2026-10-11', parent.date_of_birth) / 365.25) as parent_age,
    FLOOR(DATEDIFF('2026-10-11', child.date_of_birth) / 365.25) as child_age,
    FLOOR(DATEDIFF('2026-10-11', parent.date_of_birth) / 365.25) -
    FLOOR(DATEDIFF('2026-10-11', child.date_of_birth) / 365.25) as age_gap,
    parent.employer as parent_employer,
    child.employer as child_employer,
    parent.status as parent_status,
    child.status as child_status
FROM nbc.members parent
JOIN nbc.members child ON parent.id_number < child.id_number
    AND parent.last_name = child.last_name
    AND (FLOOR(DATEDIFF('2026-10-11', parent.date_of_birth) / 365.25) -
         FLOOR(DATEDIFF('2026-10-11', child.date_of_birth) / 365.25)) BETWEEN 20 AND 50
    AND (child.employer = 'Student'
         OR parent.employer LIKE '%Retired%'
         OR child.balance_nad = 0)
ORDER BY parent.last_name, parent.first_name;

-- Validation Query 3: Unclaimed Beneficiary Detection
-- Identifies accounts representing unclaimed beneficiary benefits
SELECT
    'Unclaimed Beneficiary Validation' as validation_type,
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
FROM nbc.members
WHERE status IN ('dormant', 'unclaimed')
    AND balance_nad > 10000  -- Significant balance suggesting unclaimed benefits
ORDER BY balance_nad DESC;

-- Validation Query 4: Cross-Institution Beneficiary Tracking
-- Note: For full cross-institution validation, this would need to JOIN with
-- other institution tables. This version shows the concept for NBC only.
SELECT
    'Cross-Institution Readiness' as validation_type,
    COUNT(*) as total_nbc_records,
    COUNT(DISTINCT id_number) as unique_individuals_in_nbc,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_count,
    SUM(CASE WHEN status = 'dormant' THEN 1 ELSE 0 END) as dormant_count,
    SUM(CASE WHEN status = 'unclaimed' THEN 1 ELSE 0 END) as unclaimed_count,
    SUM(balance_nad) as total_nbc_balance
FROM nbc.members;

-- Validation Query 5: Multi-Generational Family Detection
-- Identifies 3-generation patterns: grandparent-parent-child
SELECT
    'Multi-Generational Family Validation' as validation_type,
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
FROM nbc.members gp
JOIN nbc.members p ON gp.last_name = p.last_name
    AND (FLOOR(DATEDIFF('2026-10-11', gp.date_of_birth) / 365.25) -
         FLOOR(DATEDIFF('2026-10-11', p.date_of_birth) / 365.25)) BETWEEN 30 AND 50
JOIN nbc.members c ON p.last_name = c.last_name
    AND (FLOOR(DATEDIFF('2026-10-11', p.date_of_birth) / 365.25) -
         FLOOR(DATEDIFF('2026-10-11', c.date_of_birth) / 365.25)) BETWEEN 20 AND 40
WHERE gp.employer LIKE '%Retired%'
  AND (c.employer = 'Student' OR c.balance_nad = 0)
ORDER BY gp.last_name, gp.first_name;

-- ============================================================================
-- SECTION 3: IMPLEMENTATION NOTES & GUIDELINES
-- ============================================================================
--
-- HOW TO EXTEND THIS TO ALL INSTITUTIONS:
--
-- 1. For each institution's seed file:
--    - Include 10-20 explicitly modeled beneficiary relationship records
--    - Use appropriate age gaps for different relationship types:
--      * Spouses: ±10 years age difference
--      * Parent-child: 20-40 years age gap
--      * Grandparent-grandchild: 40-60 years age gap
--    - Apply status fields correctly:
--      * 'active': Current beneficiaries with accessible benefits
--      * 'dormant': Potential unclaimed benefits (>3 years no activity)
--      * 'unclaimed': Benefits awaiting distribution to rightful beneficiaries
--    - Use employer field indicators:
--      * 'Household Spouse': Explicit spouse beneficiary marker
--      * 'Student': Child beneficiary (typically under 25)
--      * 'Retired Teacher', 'Retired Engineer', etc.: Parent/grandparent beneficiaries
--    - Ensure cross-institution matching uses identical ID numbers
--    - Maintain proper balance distributions aligned with financial targets
--
-- 2. RELATIONSHIP PATTERNS TO INCLUDE:
--    - Spouse pairs (both active, similar ages, shared last name)
--    - Parent-child trios (parent active/retired, child student)
--    - Multi-generational groups (grandparent-parent-child)
--    - Unclaimed benefit scenarios (dormant/unclaimed with significant balances)
--    - Cross-institution matching records (same IDs in 2-3+ institutions)
--    - Sibling relationships (same last name, similar age ranges)
--
-- 3. FINANCIAL INTEGRITY:
--    - All beneficiary data maintains the EXACT combined balance of N$218,000,000.00
--    - Beneficiary balances are NOT double-counted when individuals appear in multiple institutions
--    - Each record's balance represents ACTUAL funds in that SPECIFIC institution
--    - Total system balance sums ALL member records across ALL institutions
--
-- 4. VALIDATION APPROACH:
--    - Use queries like those above to check implementation correctness
--    - Look for expected patterns in spouse/parent-child detection
--    - Verify cross-institution consistency (same ID across tables)
--    - Confirm proper financial accounting (no double-counting)
--
-- ============================================================================
-- END OF MASTER BENEFICIARY IMPLEMENTATION SCRIPT
-- ============================================================================