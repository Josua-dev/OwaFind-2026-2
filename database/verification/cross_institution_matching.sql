-- Cross-Institution Matching Verification
-- This script verifies the number of individuals appearing in multiple institutions

-- First, let's get a count of unique individuals across all institutions
WITH all_individuals AS (
    SELECT id_number, 'GIPF' as institution FROM gipf.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'SANLAM' FROM sanlam.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'OLD_MUTUAL' FROM oldmutual.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NAMCOR' FROM namcor.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NAMPOWER' FROM nampower.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NAMWATER' FROM namwater.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NBC' FROM nbc.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'ROSSING' FROM rossing.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NAMPORT' FROM namport.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'BANK_OF_NAMIBIA' FROM bank_of_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'MTC' FROM mtc.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'STANDARD_BANK_PENSION' FROM standard_bank_pension.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NAMIB_MILLS' FROM namib_mills.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'TRANSNAMIB' FROM transnamib.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'CAPRICORN' FROM capricorn.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'PUPKEWITZ' FROM pupkewitz.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NAMIBIA_BUILDING_WORKERS' FROM namibia_building_workers.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'UNIVERSITIES' FROM universities.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NHE' FROM nhe.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'BANK_WINDHOEK' FROM bank_windhoek.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'FNB_NAMIBIA' FROM fnb_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'STANDARD_BANK_NAMIBIA' FROM standard_bank_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'NEDBANK_NAMIBIA' FROM nedbank_namibia.members WHERE id_number IS NOT NULL UNION ALL
    SELECT id_number, 'LETSHEGO_NAMIBIA' FROM letshego_namibia.members WHERE id_number IS NOT NULL
),
individual_institution_count AS (
    SELECT
        id_number,
        COUNT(DISTINCT institution) as institution_count
    FROM all_individuals
    GROUP BY id_number
),
matching_summary AS (
    SELECT
        COUNT(*) as total_records,
        COUNT(DISTINCT id_number) as unique_individuals,
        SUM(CASE WHEN institution_count = 1 THEN 1 ELSE 0 END) as individuals_single_institution,
        SUM(CASE WHEN institution_count > 1 THEN 1 ELSE 0 END) as individuals_multiple_institutions,
        MAX(institution_count) as max_institutions_per_individual
    FROM individual_institution_count
)
SELECT
    total_records,
    unique_individuals,
    individuals_single_institution,
    individuals_multiple_institutions,
    max_institutions_per_individual,
    ROUND((individuals_multiple_institutions::decimal / unique_individuals) * 100, 2) as percentage_shared_individuals
FROM matching_summary;