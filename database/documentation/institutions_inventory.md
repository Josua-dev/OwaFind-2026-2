# Namibian Institutions Inventory for OwaFind Expansion

## Overview
This document outlines the research conducted on Namibian financial and institutional entities to determine their suitability for inclusion in the OwaFind multi-institution database expansion project.

## Research Sources
- Namibia Financial Institutions Supervisory Authority (NAMFISA): https://www.namfisa.com.na/pension-funds-friendly-societies/
- WikiNam Directory: https://www.wikinam.org/html/cat/cl/pension-funds/264/pension-funds.html
- Retirement Funds Institute of Namibia: https://www.rfin.com.na/
- Various insurance company websites and directories
- Wikipedia: List of banks in Namibia
- Various financial institution websites

## Institution Compatibility Analysis

### A. Pension Funds and Retirement Institutions ✅ VERIFIED AND COMPATIBLE
These institutions maintain member records with contribution balances that map directly to the existing schema.

| Institution | Type | Region | Reference Field | Compatibility Notes |
|-------------|------|--------|-----------------|-------------------|
| Government Institutions Pension Fund (GIPF) | Pension Fund | Windhoek | fund_number | Already in system |
| Namcor Pension Fund | Pension Fund | Windhoek | fund_number | Compatible - pension fund with member balances |
| Nampower Provident Fund | Provident Fund | Windhoek | fund_number | Compatible - retirement fund with member balances |
| Namwater Retirement Fund | Retirement Fund | Windhoek | fund_number | Compatible |
| NBC Retirement Fund | Retirement Fund | Windhoek | fund_number | Compatible |
| Rossing Pension Fund | Pension Fund | Arandis | fund_number | Compatible |
| Namport Retirement Fund | Retirement Fund | Walvis Bay | fund_number | Compatible |
| Bank of Namibia Provident Fund | Provident Fund | Windhoek | fund_number | Compatible |
| MTC Pension Fund | Pension Fund | Windhoek | fund_number | Compatible |
| Standard Bank Namibia Pension Fund | Pension Fund | Windhoek | fund_number | Compatible |
| Namib Mills Pension Fund | Pension Fund | Windhoek | fund_number | Compatible |
| TransNamib Retirement Fund | Retirement Fund | Windhoek | fund_number | Compatible |
| Capricorn Group Retirement Fund | Retirement Fund | Windhoek | fund_number | Compatible |
| Pupkewitz Group Pension Fund | Pension Fund | Windhoek | fund_number | Compatible |
| Namibia Building Workers' Pension Fund | Pension Fund | Windhoek | fund_number | Compatible |
| Universities Retirement Fund | Retirement Fund | Windhoek | fund_number | Compatible |
| NHE Retirement Fund | Retirement Fund | Windhoek | fund_number | Compatible |

### B. Insurance Companies ⚠️ VERIFIED BUT REQUIRES ASSESSMENT
These institutions may maintain policyholder records, but compatibility depends on whether they maintain cash value or benefit records similar to pension accounts.

| Institution | Type | Region | Reference Field | Compatibility Assessment |
|-------------|------|--------|-----------------|------------------------|
| Sanlam Namibia | Life Insurer | Windhoek | policy_number | Already in system - compatible |
| Old Mutual Namibia | Life Insurer | Windhoek | policy_number | Already in system - compatible |
| Namforce Life Insurance | Life Insurer | Windhoek | policy_number | Likely compatible - maintains policy records with values |
| Liberty Namibia | Life Insurer | Windhoek | policy_number | Likely compatible - maintains policy records with values |
| Momentum Metropolitan Namibia | Life Insurer | Windhoek | policy_number | Likely compatible - maintains policy records with values |
| Capricorn Private Wealth | Wealth Manager | Windhoek | client_number | Requires assessment - may maintain investment accounts |

### C. Banks and Financial Services Institutions ✅ VERIFIED AND COMPATIBLE
These institutions maintain customer account records with balances that map to the schema.

| Institution | Type | Region | Reference Field | Compatibility Notes |
|-------------|------|--------|-----------------|-------------------|
| Bank Windhoek | Commercial Bank | Windhoek | account_number | Compatible - maintains savings/investment account balances |
| FNB Namibia | Commercial Bank | Windhoek | account_number | Compatible - maintains savings/investment account balances |
| Standard Bank Namibia | Commercial Bank | Windhoek | account_number | Compatible - maintains savings/investment account balances |
| Nedbank Namibia | Commercial Bank | Windhoek | account_number | Compatible - maintains savings/investment account balances |
| Letshego Namibia | Microfinance Bank | Windhoek | account_number | Compatible - maintains loan/savings account balances |

### D. Investment and Asset-Management Institutions ⚠️ REQUIRES FURTHER ASSESSMENT
These institutions may manage funds on behalf of others but may not maintain direct customer accounts.

| Institution | Type | Region | Reference Field | Compatibility Assessment |
|-------------|------|--------|-----------------|------------------------|
| Capricorn Asset Management | Investment Manager | Windhoek | portfolio_id | Likely NOT directly compatible - manages funds rather than maintains member accounts |
| Various Unit Trust Managers | Investment Managers | Various | unit_holder_number | Requires assessment per institution |

### E. Medical Aid and Employee-Benefit Institutions ❌ STRUCTURALLY DIFFERENT
These institutions maintain benefit records rather than account balances.

| Institution | Type | Region | Reference Field | Compatibility Notes |
|-------------|------|--------|-----------------|-------------------|
| Namibia Health Plan (NHP) | Medical Aid Fund | Windhoek | member_number | Structural difference - manages benefits, not account balances |
| Public Service Employees Medical Aid Scheme (PSEMAS) | Medical Aid Fund | Windhoek | member_number | Structural difference - manages benefits, not account balances |
| Various Employer Benefit Funds | Employee Benefit | Various | employee_id | Structural difference - manages benefits, not account balances |

## Recommended Institutions for Seed Data Generation

Based on the analysis, the following institutions are recommended for inclusion in the seed data expansion:

### Phase 1: Definitely Compatible (Immediate Implementation)
All pension funds listed above (16 additional institutions) plus the 3 banks with clear account structures.

### Phase 2: Requires Validation
Insurance companies - need to verify they maintain policy records with cash values that can be represented as `balance_nad`.

### Phase 3: Not Recommended for Current Schema
Medical aid schemes and pure investment managers - their data models don't align with the account-balance focused schema.

## Seed Data Implementation Status

As of this update, the following seed data files have been created:

### Complete Detailed Examples:
1. `database/seed/gipf_additional_seed.sql` - 1,200 records
2. `database/seed/sanlam_additional_seed.sql` - 1,000 records
3. `database/seed/oldmutual_additional_seed.sql` - 1,000 records
4. `database/seed/namcor_additional_seed.sql` - 800 records
5. `database/seed/bank_windhoek_additional_seed.sql` - 750 records
6. `database/seed/standard_bank_pension_additional_seed.sql` - 600 records

### Pattern Demonstration Files:
7. `database/seed/nampower_additional_seed.sql` - Shows expansion pattern
8. `database/seed/fnb_namibia_additional_seed.sql` - Shows expansion pattern
9. `database/seed/namforce_life_insurance_additional_seed.sql` - Shows expansion pattern

### Verification Scripts:
- `database/verification/institution_record_counts.sql`
- `database/verification/institution_balance_totals.sql`
- `database/verification/combined_balance_total.sql`
- `database/verification/cross_institution_matching.sql`
- `database/verification/beneficiary_validation.sql`

### Documentation:
- `database/documentation/institutions_inventory.md` (this file)
- `database/documentation/seed_data_summary.md`
- `database/documentation/sql_import_instructions.md`

## Implementation Notes
The seed data generation follows a consistent pattern:
1. Cross-institution matching records (same ID numbers across institutions)
2. Unique individual records in varying batch sizes
3. Realistic Namibian demographic and employment data
4. Varied financial distributions to create authentic portfolio mix
5. Proper institution-specific reference number formats

To complete the full expansion to all 24 recommended institutions, generate additional seed files following the established patterns, ensuring the total combined balance equals exactly N$218,000,000.00.