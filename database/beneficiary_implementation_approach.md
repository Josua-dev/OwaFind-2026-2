# Beneficiary Data Implementation Approach for OwaFind Expansion

## Overview
Based on analysis of the OwaFind codebase, there are no explicit beneficiary tables in the current schema (FirmMember interface). However, beneficiary relationships can be effectively represented through the existing member schema by:

1. Creating member records that represent beneficiaries (spouses, children, parents, etc.)
2. Using status fields to indicate beneficiary-related scenarios
3. Leveraging cross-institution matching to show beneficiary relationships across institutions
4. Using balance amounts and dates to represent benefit distributions

## Implementation Strategy

### 1. Beneficiary Representation Through Member Records
Beneficiaries will be represented as member records with:
- Appropriate relationship indicators in names or employer fields
- Age-appropriate dates of birth (younger for children, older for parents)
- Balance amounts representing benefit values or residual amounts
- Status fields indicating beneficiary scenarios (dormant for unclaimed benefits, etc.)

### 2. Cross-Institution Beneficiary Matching
Same beneficiary individuals will appear across institutions using identical ID numbers, showing:
- How benefits might be distributed across multiple institutions
- Consistent identity tracking for beneficiaries
- Variation in benefit amounts per institution

### 3. Scenario Modeling
We will model various beneficiary scenarios:
- **Primary member with spouse beneficiary**: Two records with linked IDs, spouse typically younger
- **Primary member with child beneficiaries**: Multiple records showing children of different ages
- **Multi-generational families**: Records showing grandparents, parents, children
- **Unclaimed benefits**: Dormant status with significant balances
- **Paid-out benefits**: Zero or low balances indicating distribution completed

### 4. Financial Constraints
All beneficiary data will be generated to ensure:
- Combined balance across all institutions remains exactly N$218,000,000.00
- Beneficiary balances are properly weighted in the overall distribution
- No double-counting of funds when beneficiaries appear in multiple institutions

## Files to Create/Modify

### Seed Data Files
For each of the 24 compatible institutions, create seed data that includes:
- Primary member records
- Beneficiary records (spouses, children, parents, etc.)
- Cross-institution matching records
- Realistic demographic and financial distributions

### Verification Script Updates
Update `database/verification/beneficiary_validation.sql` to:
- Validate specific beneficiary relationship patterns
- Check for age-appropriate relationships
- Verify cross-institution beneficiary consistency
- Confirm proper financial representation of beneficiary scenarios

## Technical Details

### ID Number Generation for Beneficiaries
- Use Namibian ID format: YYMMDDSSSSSX
- Generate appropriate dates of birth for different relationships:
  * Spouses: Similar age (±10 years)
  * Children: 20-40 years younger than primary member
  * Parents: 20-40 years older than primary member
- Maintain cross-institution consistency for same individuals

### Balance Distribution for Beneficiaries
- Beneficiary balances represent:
  * Residual benefits (for dormant/unclaimed scenarios)
  * Distributed benefits (lower or zero balances)
  * Future benefit entitlements (for younger beneficiaries)
- Weighted distribution consistent with overall financial targets

### Status Field Usage
- 'active': Current beneficiary with accessible benefits
- 'dormant': Unclaimed benefits or inactive beneficiary records
- 'unclaimed': Benefits awaiting distribution to rightful beneficiaries

## Relationship to Original Request
This approach satisfies section 8 requirements by:
- Not inventing a new schema (using existing FirmMember interface)
- Populating existing tables with synthetic beneficiary data
- Generating variety of relationships (spouse, child, parent, sibling)
- Ensuring beneficiaries reference valid members through cross-institution matching
- Keeping institutional records independent while showing relationships
- Not adding beneficiary amounts to existing balances if representing distributions