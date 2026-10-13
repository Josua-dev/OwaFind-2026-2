# Local Data Validation Report

## Validation summary

The synthetic local workspace was generated and validated for the as-of date 2026-10-12.

- Institutions: 19
- Synthetic profiles: 12,000
- Benefit/account records: 22,572
- Match records linked to accounts: 22,572
- Synthetic claims: 573 (2 workflow examples plus 571 deterministic historical records)
- Claim states: 53 submitted; 61 identity review; 51 evidence review; 60 institution review; 53 more information required; 54 resubmitted; 65 approved; 69 rejected; 64 closed; 43 appeal
- Resolved claims: 198 (65 approved, 69 rejected, 64 closed)
- Institution claim distribution: all 19 institutions have claims, pending reviews, and resolved claims; minimum per institution is 23 total claims, 11 pending reviews, and 6 resolved claims
- Account statuses: 9,504 active; 12,708 dormant; 360 unclaimed
- Unclaimed accounts: 360
- Current unclaimed balance: N$218,700,000.00
- Unique benefit IDs: true
- Unique claim IDs: true
- Match-to-account institution/reference links: true
- Negative balance check: true
- Valid date range check: true
- Deterministic regeneration check: true
- Local workspace claim persistence check: true
- Josua discovery returns an account match at all 19 listed institutions: true
- Dashboard/chart aggregates reconcile to the records and claims: true
- Institution claim and review queues are populated across all 19 institutions: true
- All six recent monthly claim-volume points and all eight quarterly resolution points contain data: true
- Currency formatting for the unclaimed total: N$218.7M

## Key rules enforced

1. All records use deterministic generation seeded with `owafind-synthetic-workspace-2026`.
2. All account and claim IDs must be unique.
3. The total of records with `status === 'unclaimed'` equals exactly N$218,700,000.00.
4. No future timestamps are used and no invalid dates are generated.
5. Local changes persist in browser storage and do not trigger network requests.
6. Annual match trends, monthly claims, quarterly resolutions, regional counts, institution activity, and unclaimed-benefit categories are calculated from the same workspace records. Historical claims provide dated workflow transitions and resolved outcomes across the chart periods.
7. Chart totals reconcile: annual matches and regional/institution match counts sum to 22,572; category balances sum to N$218,700,000.00; claim totals reconcile to the current claims collection.

## Validation commands run

- `npm ci`
- `npm run typecheck`
- `npm run lint`
- `npm run build`
- `npm test`

## Result

The frontend build, TypeScript check, linting, and synthetic-data tests pass in the local workspace configuration. Dashboard chart series and institution KPIs derive from the shared synthetic records and claim history; recent monthly volume and quarterly resolution charts each have non-zero values across every displayed period.
