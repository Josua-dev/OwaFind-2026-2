# Local Synthetic Workspace

This workspace is intentionally configured to run without any networked backend. The application loads a deterministic synthetic dataset from the frontend bundle and persists user-created changes in browser storage.

## Scope

- Dataset generation: `src/data/synthetic/index.ts`
- Persistence and reset: `src/services/workspaceRepository.ts`
- Local service façade: `src/services/index.ts`
- Local generator script: `scripts/generate-synthetic-data.mjs`

## Data characteristics

- As-of date: 2026-10-12
- Deterministic generation with a fixed seed: `owafind-synthetic-data-2026`
- 19 institution catalogue entries covering Namibian pension, insurer, and benefit-related institutions
- 12,000 synthetic profiles with repeated appearances across institutions where appropriate
- 22,572 benefit/account rows
- Exact current unclaimed total: N$218,700,000.00
- Claims and notifications are generated as fictional historical events, not live institutional activity

## Persistence model

- Baseline data is loaded from the bundled seed generator at first app startup
- User changes are stored in `localStorage` under the key `owafind-local-workspace-v1`
- On load, persisted claims are reconciled with the current bundled baseline so older browser state gains newly generated historical institution claims while locally created claims and saved status/timeline changes remain intact
- Reset clears only local user state and restores the bundled baseline data without deleting it
- The app never calls the Flask API, ngrok endpoint, or external service during normal use

## Synthetic disclosure

The UI includes a visible notice that the workspace uses fictional data. Institution names may correspond to real public-label entities, but associated balances, claim records, notifications, and account activity are synthetic and local to this browser only.

## Validation

The workspace validates the following on startup:

- exact current unclaimed balance equals N$218,700,000.00
- no negative balances
- unique record IDs for accounts and claims
- valid date ranges without future timestamps
- deterministic record generation

This is a prototype and local-analysis tool, not a live benefits service or live institution integration.
