-- Combined Balance Total Verification
-- This script verifies that the combined balance across all institutions equals exactly N$218,000,000.00

WITH institution_balances AS (
    SELECT 'GIPF' as institution, COALESCE(SUM(balance_nad), 0) as total_balance FROM gipf.members UNION ALL
    SELECT 'SANLAM', COALESCE(SUM(balance_nad), 0) FROM sanlam.members UNION ALL
    SELECT 'OLD_MUTUAL', COALESCE(SUM(balance_nad), 0) FROM oldmutual.members UNION ALL
    SELECT 'NAMCOR', COALESCE(SUM(balance_nad), 0) FROM namcor.members UNION ALL
    SELECT 'NAMPOWER', COALESCE(SUM(balance_nad), 0) FROM nampower.members UNION ALL
    SELECT 'NAMWATER', COALESCE(SUM(balance_nad), 0) FROM namwater.members UNION ALL
    SELECT 'NBC', COALESCE(SUM(balance_nad), 0) FROM nbc.members UNION ALL
    SELECT 'ROSSING', COALESCE(SUM(balance_nad), 0) FROM rossing.members UNION ALL
    SELECT 'NAMPORT', COALESCE(SUM(balance_nad), 0) FROM namport.members UNION ALL
    SELECT 'BANK_OF_NAMIBIA', COALESCE(SUM(balance_nad), 0) FROM bank_of_namibia.members UNION ALL
    SELECT 'MTC', COALESCE(SUM(balance_nad), 0) FROM mtc.members UNION ALL
    SELECT 'STANDARD_BANK_PENSION', COALESCE(SUM(balance_nad), 0) FROM standard_bank_pension.members UNION ALL
    SELECT 'NAMIB_MILLS', COALESCE(SUM(balance_nad), 0) FROM namib_mills.members UNION ALL
    SELECT 'TRANSNAMIB', COALESCE(SUM(balance_nad), 0) FROM transnamib.members UNION ALL
    SELECT 'CAPRICORN', COALESCE(SUM(balance_nad), 0) FROM capricorn.members UNION ALL
    SELECT 'PUPKEWITZ', COALESCE(SUM(balance_nad), 0) FROM pupkewitz.members UNION ALL
    SELECT 'NAMIBIA_BUILDING_WORKERS', COALESCE(SUM(balance_nad), 0) FROM namibia_building_workers.members UNION ALL
    SELECT 'UNIVERSITIES', COALESCE(SUM(balance_nad), 0) FROM universities.members UNION ALL
    SELECT 'NHE', COALESCE(SUM(balance_nad), 0) FROM nhe.members UNION ALL
    SELECT 'BANK_WINDHOEK', COALESCE(SUM(balance_nad), 0) FROM bank_windhoek.members UNION ALL
    SELECT 'FNB_NAMIBIA', COALESCE(SUM(balance_nad), 0) FROM fnb_namibia.members UNION ALL
    SELECT 'STANDARD_BANK_NAMIBIA', COALESCE(SUM(balance_nad), 0) FROM standard_bank_namibia.members UNION ALL
    SELECT 'NEDBANK_NAMIBIA', COALESCE(SUM(balance_nad), 0) FROM nedbank_namibia.members UNION ALL
    SELECT 'LETSHEGO_NAMIBIA', COALESCE(SUM(balance_nad), 0) FROM letshego_namibia.members
)
SELECT
    SUM(total_balance) as combined_balance_nad,
    CASE
        WHEN SUM(total_balance) = 218000000.00 THEN 'BALANCE CORRECT'
        ELSE 'BALANCE INCORRECT - Target: 218,000,000.00, Actual: ' || SUM(total_balance)
    END as balance_verification
FROM institution_balances;