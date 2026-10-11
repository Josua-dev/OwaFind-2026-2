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