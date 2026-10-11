-- Institution Record Counts Verification
-- This script verifies the number of records in each institution's members table

SELECT
    'GIPF' as institution,
    COUNT(*) as record_count
FROM gipf.members

UNION ALL

SELECT
    'SANLAM' as institution,
    COUNT(*) as record_count
FROM sanlam.members

UNION ALL

SELECT
    'OLD_MUTUAL' as institution,
    COUNT(*) as record_count
FROM oldmutual.members

UNION ALL

SELECT
    'NAMCOR' as institution,
    COUNT(*) as record_count
FROM namcor.members

UNION ALL

SELECT
    'NAMPOWER' as institution,
    COUNT(*) as record_count
FROM nampower.members

UNION ALL

SELECT
    'NAMWATER' as institution,
    COUNT(*) as record_count
FROM namwater.members

UNION ALL

SELECT
    'NBC' as institution,
    COUNT(*) as record_count
FROM nbc.members

UNION ALL

SELECT
    'ROSSING' as institution,
    COUNT(*) as record_count
FROM rossing.members

UNION ALL

SELECT
    'NAMPORT' as institution,
    COUNT(*) as record_count
FROM namport.members

UNION ALL

SELECT
    'BANK_OF_NAMIBIA' as institution,
    COUNT(*) as record_count
FROM bank_of_namibia.members

UNION ALL

SELECT
    'MTC' as institution,
    COUNT(*) as record_count
FROM mtc.members

UNION ALL

SELECT
    'STANDARD_BANK_PENSION' as institution,
    COUNT(*) as record_count
FROM standard_bank_pension.members

UNION ALL

SELECT
    'NAMIB_MILLS' as institution,
    COUNT(*) as record_count
from namib_mills.members

UNION ALL

SELECT
    'TRANSNAMIB' as institution,
    COUNT(*) as record_count
FROM transnamib.members

UNION ALL

SELECT
    'CAPRICORN' as institution,
    COUNT(*) as record_count
FROM capricorn.members

UNION ALL

SELECT
    'PUPKEWITZ' as institution,
    COUNT(*) as record_count
FROM pupkewitz.members

UNION ALL

SELECT
    'NAMIBIA_BUILDING_WORKERS' as institution,
    COUNT(*) as record_count
FROM namibia_building_workers.members

UNION ALL

SELECT
    'UNIVERSITIES' as institution,
    COUNT(*) as record_count
FROM universities.members

UNION ALL

SELECT
    'NHE' as institution,
    COUNT(*) as record_count
FROM nhe.members

UNION ALL

SELECT
    'BANK_WINDHOEK' as institution,
    COUNT(*) as record_count
FROM bank_windhoek.members

UNION ALL

SELECT
    'FNB_NAMIBIA' as institution,
    COUNT(*) as record_count
FROM fnb_namibia.members

UNION ALL

SELECT
    'STANDARD_BANK_NAMIBIA' as institution,
    COUNT(*) as record_count
FROM standard_bank_namibia.members

UNION ALL

SELECT
    'NEDBANK_NAMIBIA' as institution,
    COUNT(*) as record_count
FROM nedbank_namibia.members

UNION ALL

SELECT
    'LETSHEGO_NAMIBIA' as institution,
    COUNT(*) as record_count
FROM letshego_namibia.members

UNION ALL

SELECT
    'COMBINED_TOTAL' as institution,
    SUM(record_count) as record_count
FROM (
    SELECT COUNT(*) as record_count FROM gipf.members UNION ALL
    SELECT COUNT(*) as record_count FROM sanlam.members UNION ALL
    SELECT COUNT(*) as record_count FROM oldmutual.members UNION ALL
    SELECT COUNT(*) as record_count FROM namcor.members UNION ALL
    SELECT COUNT(*) as record_count FROM nampower.members UNION ALL
    SELECT COUNT(*) as record_count FROM namwater.members UNION ALL
    SELECT COUNT(*) as record_count FROM nbc.members UNION ALL
    SELECT COUNT(*) as record_count FROM rossing.members UNION ALL
    SELECT COUNT(*) as record_count FROM namport.members UNION ALL
    SELECT COUNT(*) as record_count FROM bank_of_namibia.members UNION ALL
    SELECT COUNT(*) as record_count FROM mtc.members UNION ALL
    SELECT COUNT(*) as record_count FROM standard_bank_pension.members UNION ALL
    SELECT COUNT(*) as record_count FROM namib_mills.members UNION ALL
    SELECT COUNT(*) as record_count FROM transnamib.members UNION ALL
    SELECT COUNT(*) as record_count FROM capricorn.members UNION ALL
    SELECT COUNT(*) as record_count FROM pupkewitz.members UNION ALL
    SELECT COUNT(*) as record_count FROM namibia_building_workers.members UNION ALL
    SELECT COUNT(*) as record_count FROM universities.members UNION ALL
    SELECT COUNT(*) as record_count FROM nhe.members UNION ALL
    SELECT COUNT(*) as record_count FROM bank_windhoek.members UNION ALL
    SELECT COUNT(*) as record_count FROM fnb_namibia.members UNION ALL
    SELECT COUNT(*) as record_count FROM standard_bank_namibia.members UNION ALL
    SELECT COUNT(*) as record_count FROM nedbank_namibia.members UNION ALL
    SELECT COUNT(*) as record_count FROM letshego_namibia.members
) combined_counts

ORDER BY
    CASE institution
        WHEN 'GIPF' THEN 1
        WHEN 'SANLAM' THEN 2
        WHEN 'OLD_MUTUAL' THEN 3
        WHEN 'NAMCOR' THEN 4
        WHEN 'NAMPOWER' THEN 5
        WHEN 'NAMWATER' THEN 6
        WHEN 'NBC' THEN 7
        WHEN 'ROSSING' THEN 8
        WHEN 'NAMPORT' THEN 9
        WHEN 'BANK_OF_NAMIBIA' THEN 10
        WHEN 'MTC' THEN 11
        WHEN 'STANDARD_BANK_PENSION' THEN 12
        WHEN 'NAMIB_MILLS' THEN 13
        WHEN 'TRANSNAMIB' THEN 14
        WHEN 'CAPRICORN' THEN 15
        WHEN 'PUPKEWITZ' THEN 16
        WHEN 'NAMIBIA_BUILDING_WORKERS' THEN 17
        WHEN 'UNIVERSITIES' THEN 18
        WHEN 'NHE' THEN 19
        WHEN 'BANK_WINDHOEK' THEN 20
        WHEN 'FNB_NAMIBIA' THEN 21
        WHEN 'STANDARD_BANK_NAMIBIA' THEN 22
        WHEN 'NEDBANK_NAMIBIA' THEN 23
        WHEN 'LETSHEGO_NAMIBIA' THEN 24
        WHEN 'COMBINED_TOTAL' THEN 25
        ELSE 99
    END;