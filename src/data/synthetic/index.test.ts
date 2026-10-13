import fs from 'node:fs';
import path from 'node:path';
import { expect, test } from 'vitest';

import { analyticsService, benefitService, claimService, institutionService } from '../../services/index.ts';
import { loadLocalWorkspaceState, saveLocalWorkspaceState } from '../../services/workspaceRepository.ts';
import { formatCurrencyShort } from '../../utils/format.ts';
import { AS_OF_DATE, TOTAL_UNCLAIMED_BALANCE, buildSyntheticWorkspace, validateSyntheticWorkspace } from './index.ts';
import type { Claim } from '../../types/index.ts';

const memory = new Map<string, string>();
const storage = {
  getItem(key: string) {
    return memory.has(key) ? memory.get(key)! : null;
  },
  setItem(key: string, value: string) {
    memory.set(key, String(value));
  },
  removeItem(key: string) {
    memory.delete(key);
  },
  clear() {
    memory.clear();
  },
};

Object.defineProperty(globalThis, 'localStorage', {
  value: storage,
  configurable: true,
});

Object.defineProperty(globalThis, 'fetch', {
  value: async () => {
    throw new Error('Unexpected fetch call in local workspace test');
  },
  configurable: true,
});

test('synthetic generation is deterministic and valid', () => {
  const first = buildSyntheticWorkspace();
  const second = buildSyntheticWorkspace();

  expect(first.institutions).toEqual(second.institutions);
  expect(first.profiles).toEqual(second.profiles);
  expect(first.benefitRecords).toEqual(second.benefitRecords);
  expect(validateSyntheticWorkspace(first)).toBe(true);
  expect(validateSyntheticWorkspace(second)).toBe(true);
});

test('exact unclaimed balance and record integrity', () => {
  const workspace = buildSyntheticWorkspace();
  const unclaimed = workspace.benefitRecords.filter((record) => record.status === 'unclaimed');
  const total = unclaimed.reduce((sum, record) => sum + record.approximateValue, 0);

  expect(total).toBe(TOTAL_UNCLAIMED_BALANCE);
  expect(total).toBeGreaterThan(0);
  expect(unclaimed.length).toBeGreaterThan(0);
  expect(workspace.benefitRecords.length).toBeGreaterThanOrEqual(18_500);
  expect(workspace.benefitRecords.every((record) => record.approximateValue >= 0)).toBe(true);

  const ids = new Set(workspace.benefitRecords.map((record) => record.id));
  expect(ids.size).toBe(workspace.benefitRecords.length);

  const claimIds = new Set(workspace.claims.map((claim) => claim.id));
  expect(claimIds.size).toBe(workspace.claims.length);
});

test('date ranges and claim chronology remain valid', () => {
  const workspace = buildSyntheticWorkspace();
  const asOf = new Date(`${AS_OF_DATE}T00:00:00.000Z`).getTime();

  for (const record of workspace.benefitRecords) {
    const joined = new Date(`${record.dateJoined ?? AS_OF_DATE}T00:00:00.000Z`).getTime();
    expect(joined).toBeLessThanOrEqual(asOf);
    if (record.dateExited) {
      const exited = new Date(`${record.dateExited}T00:00:00.000Z`).getTime();
      expect(exited).toBeGreaterThanOrEqual(joined);
    }
  }

  const recordsByReference = new Map(workspace.benefitRecords.map((item) => [item.reference, item]));
  for (const match of workspace.matches) {
    const identified = new Date(`${match.dateIdentified}T00:00:00.000Z`).getTime();
    const record = recordsByReference.get(match.institutionReference);
    expect(record).toBeDefined();
    expect(identified).toBeGreaterThanOrEqual(new Date(`${record?.dateJoined ?? AS_OF_DATE}T00:00:00.000Z`).getTime());
    expect(identified).toBeLessThanOrEqual(asOf);
  }

  for (const claim of workspace.claims) {
    const submitted = new Date(claim.submittedAt).getTime();
    const updated = new Date(claim.updatedAt).getTime();
    const created = new Date(claim.createdAt).getTime();
    const relatedMatch = workspace.matches.find((match) => match.id === claim.matchId);
    expect(relatedMatch).toBeDefined();
    expect(submitted).toBeGreaterThanOrEqual(new Date(`${relatedMatch?.dateIdentified}T00:00:00.000Z`).getTime());
    expect(submitted).toBeLessThanOrEqual(asOf);
    expect(updated).toBeLessThanOrEqual(asOf);
    expect(created).toBeLessThanOrEqual(asOf);
    expect(updated).toBeGreaterThanOrEqual(submitted);

    const timeline = [...claim.timeline].sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    expect(timeline.length).toBeGreaterThan(0);
    expect(new Date(timeline[0].timestamp).getTime()).toBeLessThanOrEqual(new Date(timeline[timeline.length - 1].timestamp).getTime());
    expect(timeline.every((event) => new Date(event.timestamp).getTime() <= asOf)).toBe(true);
    expect(timeline[timeline.length - 1].current).toBe(true);
  }
});

test('shared identities create cross-institution account records without duplicates', () => {
  const workspace = buildSyntheticWorkspace();
  const byBeneficiary = new Map<string, Set<string>>();

  for (const record of workspace.benefitRecords) {
    const beneficiaryId = record.beneficiaryId ?? record.id;
    const institutions = byBeneficiary.get(beneficiaryId) ?? new Set<string>();
    institutions.add(record.institutionId);
    byBeneficiary.set(beneficiaryId, institutions);
  }

  const shared = [...byBeneficiary.values()].filter((institutions) => institutions.size > 1).length;
  expect(shared).toBeGreaterThan(0);
  expect(workspace.profiles.length).toBeGreaterThan(10_000);
});

test('Josua discovery returns matches linked to his synthetic accounts', async () => {
  const workspace = buildSyntheticWorkspace();
  const josua = workspace.profiles.find((profile) => profile.nationalId === '04011400076');

  if (!josua) {
    throw new Error('Expected the synthetic Josua profile to exist.');
  }
  expect(josua.dateOfBirth).toBe('2004-01-14');
  const matches = await benefitService.searchBenefits(josua);

  expect(matches.length).toBeGreaterThan(0);
  expect(matches.every((match) => match.beneficiaryId === josua.nationalId)).toBe(true);
  expect(matches.every((match) => match.beneficiaryName === 'Josua Uuyuni')).toBe(true);
  expect(new Set(matches.map((match) => match.institutionId))).toEqual(
    new Set(workspace.institutions.map((institution) => institution.id))
  );
  expect(matches.every((match) => workspace.benefitRecords.some((record) =>
    record.beneficiaryId === match.beneficiaryId &&
    record.institutionId === match.institutionId &&
    record.reference === match.institutionReference
  ))).toBe(true);
});

test('saved Josua profile migrates to the updated synthetic identifier', () => {
  const savedProfile = { ...buildSyntheticWorkspace().profiles[0], nationalId: '75031402048', dateOfBirth: '1975-03-14' };
  storage.setItem('owafind-local-workspace-v1', JSON.stringify({ profile: savedProfile }));

  const migrated = loadLocalWorkspaceState().profile;
  expect(migrated.nationalId).toBe('04011400076');
  expect(migrated.dateOfBirth).toBe('2004-01-14');
  storage.clear();
});

test('stale browser claims refresh from baseline and preserve locally created claims', async () => {
  const baseline = buildSyntheticWorkspace();
  const staleBaselineClaims = baseline.claims.slice(0, 2).map((claim) => ({
    ...claim,
    institutionId: 'gipf',
    institutionName: 'Old stored institution value',
  }));
  const locallyCreated = {
    ...baseline.claims[0],
    id: 'OWF-LOCAL-PERSISTED-CLAIM',
    institutionId: 'old-mutual-namibia',
    institutionName: 'Old Mutual Namibia',
    state: 'SUBMITTED' as const,
  };
  storage.setItem('owafind-local-workspace-v1', JSON.stringify({
    claims: [...staleBaselineClaims, locallyCreated],
  }));

  const refreshed = loadLocalWorkspaceState();
  const refreshedByInstitution = new Map<string, Claim[]>();
  for (const claim of refreshed.claims) {
    const claims = refreshedByInstitution.get(claim.institutionId) ?? [];
    claims.push(claim);
    refreshedByInstitution.set(claim.institutionId, claims);
  }

  expect(refreshed.claims.length).toBe(baseline.claims.length + 1);
  expect(refreshed.claims.some((claim) => claim.id === locallyCreated.id)).toBe(true);
  expect(refreshed.claims.filter((claim) => claim.id.startsWith('OWF-2026-'))).toHaveLength(2);
  expect(refreshedByInstitution.get('old-mutual-namibia')).toContainEqual(
    expect.objectContaining({ id: locallyCreated.id })
  );
  expect(baseline.institutions.every((institution) =>
    (refreshedByInstitution.get(institution.id)?.length ?? 0) > 0
  )).toBe(true);
  const institutionMetrics = await institutionService.getInstitutions();
  expect(institutionMetrics.every((institution) =>
    institution.claims > 0 && institution.pendingReview > 0 && institution.resolved > 0
  )).toBe(true);
  const gipf = institutionMetrics.find((institution) => institution.id === 'gipf');
  const nbc = institutionMetrics.find((institution) => institution.id === 'nbc-retirement');
  expect(gipf).toBeDefined();
  expect(nbc).toBeDefined();
  expect(gipf?.matches).not.toBe(nbc?.matches);
  expect(gipf?.claims).not.toBe(nbc?.claims);
  expect(gipf?.pendingReview).not.toBe(nbc?.pendingReview);
  storage.clear();
});

test('dashboard aggregations align with the shared workspace dataset', async () => {
  const stats = await analyticsService.getRegulatorStats();
  const executiveStats = await analyticsService.getExecutiveStats();
  const categoryData = await analyticsService.getBenefitCategoryData();
  const institutionData = await analyticsService.getInstitutionActivityData();
  const regionalData = await analyticsService.getRegionalData();
  const monthlyClaims = await analyticsService.getClaimVolumeData();
  const annualTrend = await analyticsService.getExecutiveTrendData();
  const resolutionTrend = await analyticsService.getResolutionTrendData();
  const institutions = await institutionService.getInstitutions();
  const workspace = buildSyntheticWorkspace();
  const totalUnclaimed = workspace.benefitRecords
    .filter((record) => record.status === 'unclaimed')
    .reduce((sum, record) => sum + record.approximateValue, 0);
  const verified = workspace.matches.filter((match) => match.status === 'green').length;

  expect(totalUnclaimed).toBe(218_700_000);
  expect(stats.totalBenefits).toBe(totalUnclaimed);
  expect(executiveStats.totalBenefits).toBe(totalUnclaimed);
  expect(stats.potentialMatches).toBe(workspace.matches.length);
  expect(stats.verifiedMatches).toBe(verified);
  expect(stats.claims).toBe(workspace.claims.length);
  expect(executiveStats.potentialMatches).toBe(workspace.matches.length);
  expect(executiveStats.verifiedMatches).toBe(verified);
  expect(executiveStats.institutionsWithRecords).toBe(workspace.institutions.length);
  expect(executiveStats.openClaimValue).toBe(
    workspace.claims.filter((claim) => !['APPROVED', 'REJECTED', 'CLOSED'].includes(claim.state))
      .reduce((sum, claim) => sum + claim.amount, 0)
  );
  expect(categoryData.reduce((sum, item) => sum + item.value, 0)).toBe(totalUnclaimed);
  expect(categoryData.reduce((sum, item) => sum + item.claims, 0)).toBe(workspace.claims.length);
  expect(institutionData.reduce((sum, item) => sum + (item.matches ?? 0), 0)).toBe(workspace.matches.length);
  expect(institutionData.reduce((sum, item) => sum + (item.claims ?? 0), 0)).toBe(workspace.claims.length);
  expect(institutionData.reduce((sum, item) => sum + (item.resolved ?? 0), 0)).toBe(stats.resolved);
  expect(institutions.reduce((sum, item) => sum + item.matches, 0)).toBe(workspace.matches.length);
  expect(institutions.reduce((sum, item) => sum + item.claims, 0)).toBe(workspace.claims.length);
  expect(institutions.every((institution) => institution.claims > 0 && institution.pendingReview > 0 && institution.resolved > 0)).toBe(true);
  expect(regionalData.reduce((sum, item) => sum + item.value, 0)).toBe(workspace.matches.length);
  expect(annualTrend.reduce((sum, item) => sum + (item.matches ?? 0), 0)).toBe(workspace.matches.length);
  expect(annualTrend.reduce((sum, item) => sum + (item.verified ?? 0), 0)).toBe(verified);
  expect(annualTrend.reduce((sum, item) => sum + (item.claims ?? 0), 0)).toBe(workspace.claims.length);
  const plottedQuarters = new Set(resolutionTrend.map((item) => item.label));
  expect(resolutionTrend.reduce((sum, item) => sum + (item.resolved ?? 0), 0)).toBe(
    workspace.claims.filter((claim) => {
      const month = Number(claim.updatedAt.slice(5, 7));
      const quarter = Math.floor((month - 1) / 3) + 1;
      return ['APPROVED', 'REJECTED', 'CLOSED'].includes(claim.state) &&
        plottedQuarters.has(`${claim.updatedAt.slice(0, 4)}-Q${quarter}`);
    }).length
  );
  expect(resolutionTrend).toHaveLength(8);
  expect(resolutionTrend.every((item) => (item.resolved ?? 0) > 0 && (item.avgDays ?? 0) > 0)).toBe(true);
  expect(monthlyClaims).toHaveLength(6);
  expect(monthlyClaims.every((item) => item.value > 0)).toBe(true);
  expect(monthlyClaims.reduce((sum, item) => sum + item.value, 0)).toBe(
    workspace.claims.filter((claim) => claim.submittedAt >= '2026-05-01' && claim.submittedAt < '2026-11-01').length
  );
  expect(formatCurrencyShort(totalUnclaimed)).toBe('N$218.7M');
});

test('local claim creation persists after reload without API usage', async () => {
  let fetchCalls = 0;
  Object.defineProperty(globalThis, 'fetch', {
    value: async () => {
      fetchCalls += 1;
      throw new Error('Unexpected fetch call');
    },
    configurable: true,
  });

  const base = loadLocalWorkspaceState();
  const initialClaims = base.claims.length;

  const created = await claimService.createClaim({
    id: 'LOCAL-CLAIM-FIXTURE',
    beneficiaryId: '123456789',
    beneficiaryName: 'Test Beneficiary',
    benefitType: 'Pension',
    institutionId: 'gipf',
    institutionName: 'Government Institutions Pension Fund (GIPF)',
    institutionReference: 'GIPF-TEST-001',
    potentialValue: 25000,
    confidence: 88,
    status: 'green',
    signals: [{ label: 'Name', strength: 'strong' }],
    dateIdentified: AS_OF_DATE,
    region: 'Windhoek',
  });

  saveLocalWorkspaceState({ claims: [created, ...base.claims] });
  const afterPersist = loadLocalWorkspaceState();
  expect(afterPersist.claims.length).toBe(initialClaims + 1);
  expect(afterPersist.claims.some((claim) => claim.id === created.id)).toBe(true);
  expect(fetchCalls).toBe(0);
});

test('user-visible strings remain in local synthetic workspace mode', () => {
  const files = [
    'src/pages/LandingPage.tsx',
    'src/components/shared/RoleSwitcher.tsx',
    'src/pages/NewClaimPage.tsx',
    'src/pages/MatchResultsPage.tsx',
  ];

  for (const file of files) {
    const content = fs.readFileSync(path.resolve(process.cwd(), file), 'utf8').toLowerCase();
    expect(content).not.toMatch(/demo/);
  }
});
