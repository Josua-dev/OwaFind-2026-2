# SQL Import Instructions for OwaFind Expansion

## Overview
This document provides instructions for importing the synthetic seed data into the existing OwaFind database infrastructure. The data is designed to be imported incrementally into existing institution databases without modifying the schema or deleting existing data.

## Prerequisites
1. Access to the Namibia Pension Funds API backend databases
2. MySQL/MariaDB 5.7+ or compatible database system
3. Sufficient privileges to INSERT data into institution databases
4. Backup of existing data (recommended)

## Database Structure
Each institution maintains its own independent database with a `members` table following this structure:

```sql
CREATE TABLE members (
    id_number VARCHAR(15) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    phone VARCHAR(20),
    email VARCHAR(100),
    ref_number VARCHAR(20) NOT NULL,  -- Institution-specific: fund_number, policy_number, account_number
    employer VARCHAR(100),
    date_joined DATE,
    date_left DATE,
    balance_nad DECIMAL(15,2),
    status VARCHAR(20),
    last_updated DATE,
    PRIMARY KEY (id_number, ref_number)  -- Composite key for cross-institution matching
);
```

## Import Order
The SQL files can be imported in any order as they only add new data and do not modify existing records. However, for optimal organization:

1. **Existing Institutions First** (if adding to existing data):
   - `gipf_additional_seed.sql`
   - `sanlam_additional_seed.sql`
   - `oldmutual_additional_seed.sql`

2. **New Pension Funds**:
   - `namcor_additional_seed.sql`
   - `nampower_additional_seed.sql`
   - `namwater_additional_seed.sql`
   - `nbc_additional_seed.sql`
   - `rossing_additional_seed.sql`
   - `namport_additional_seed.sql`
   - `bank_of_namibia_additional_seed.sql`
   - `mtc_additional_seed.sql`
   - `standard_bank_pension_additional_seed.sql`
   - `namib_mills_additional_seed.sql`
   - `transnamib_additional_seed.sql`
   - `capricorn_additional_seed.sql`
   - `pupkewitz_additional_seed.sql`
   - `namibia_building_workers_additional_seed.sql`
   - `universities_additional_seed.sql`
   - `nhe_additional_seed.sql`

3. **New Banks & Financial Services**:
   - `bank_windhoek_additional_seed.sql`
   - `fnb_namibia_additional_seed.sql`
   - `standard_bank_namibia_additional_seed.sql`
   - `nedbank_namibia_additional_seed.sql`
   - `letshego_namibia_additional_seed.sql`

## Import Method
Use the MySQL command-line client or compatible tool:

```bash
# For each institution database:
mysql -u username -p database_name < path/to/seed_file.sql

# Example:
mysql -u root -p gipf < database/seed/gipf_additional_seed.sql
```

## Verification
After importing, run the verification scripts to ensure data integrity:

```bash
# Check record counts per institution
mysql -u username -p < database/verification/institution_record_counts.sql

# Check balance totals per institution
mysql -u username -p < database/verification/institution_balance_totals.sql

# Verify combined balance equals N$218,000,000.00
mysql -u username -p < database/verification/combined_balance_total.sql

# Check cross-institution matching
mysql -u username -p < database/verification/cross_institution_matching.sql

# Validate beneficiary relationships (where applicable)
mysql -u username -p < database/verification/beneficiary_validation.sql
```

## Data Characteristics
- **Cross-Institution Matching**: Approximately 30% of synthetic individuals appear in multiple institutions with the same `id_number` but different `ref_number` values
- **Balance Distribution**: Varied distribution of account sizes to create realistic financial demographics
- **Status Distribution**: Active (70%), Dormant (20%), Unclaimed (10%) 
- **Temporal Data**: Realistic date ranges for employment, account opening, and account closure
- **Geographic Data**: Distribution across Namibian regions with concentration in Windhoek
- **Employment Data**: Mix of real Namibian employers and fictional entities

## Safety Features
- **Insert-Only**: All scripts use INSERT statements only - no UPDATE, DELETE, or DROP operations
- **No Schema Modifications**: Scripts preserve existing table structures
- **Referential Integrity**: While no foreign key constraints exist in the current schema, data follows logical relationships
- **Unique Constraints**: Reference numbers are unique within each institution
- **Reproducible Generation**: All data generated with random seed 42 for consistent results

## Troubleshooting
1. **Duplicate Entry Errors**: If importing fails due to duplicate reference numbers, the data may already exist. Check existing records before re-importing.
2. **Connection Errors**: Ensure database credentials and host information are correct
3. **Permission Errors**: Verify that the user has INSERT privileges on the target databases
4. **Data Type Errors**: Ensure target database schema matches the expected structure

## Contact
For questions regarding the seed data or import process, refer to the accompanying documentation files or contact the data architecture team.