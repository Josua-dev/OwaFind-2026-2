import { buildSyntheticWorkspace, validateSyntheticWorkspace, type SyntheticWorkspace } from '@/data/synthetic';
import type {
  BeneficiaryProfile,
  Claim,
  MatchRecord,
  Notification,
  SupportTicket,
  UploadedDocument,
} from '@/types';

export interface LocalWorkspaceState {
  claims: Claim[];
  notifications: Notification[];
  documents: UploadedDocument[];
  tickets: SupportTicket[];
  searchResults: MatchRecord[];
  profile: BeneficiaryProfile;
  consentGiven: boolean;
}

const BASELINE = buildSyntheticWorkspace();
const WORKSPACE_KEY = 'owafind-local-workspace-v1';

if (!validateSyntheticWorkspace(BASELINE)) {
  throw new Error('Synthetic workspace validation failed.');
}

export const baselineWorkspace = BASELINE;

const DEFAULT_STATE: LocalWorkspaceState = {
  claims: BASELINE.claims,
  notifications: BASELINE.notifications,
  documents: BASELINE.documents,
  tickets: BASELINE.supportTickets,
  searchResults: BASELINE.matches.slice(0, 12),
  profile: BASELINE.profiles[0] ?? {
    firstName: 'Josua',
    lastName: 'Uuyuni',
    dateOfBirth: '2004-01-14',
    nationalId: '04011400076',
    previousName: '',
    phone: '+264 81 000 0000',
    email: 'josua.uuyuni@example.org',
    region: 'Windhoek',
    employmentHistory: [],
    consentGiven: true,
    consentDate: '2026-10-01',
    profileCompletion: 100,
    verificationStatus: 'verified',
  },
  consentGiven: true,
};

function readLocalState(): Partial<LocalWorkspaceState> | null {
  try {
    const raw = localStorage.getItem(WORKSPACE_KEY);
    return raw ? (JSON.parse(raw) as Partial<LocalWorkspaceState>) : null;
  } catch {
    return null;
  }
}

function writeLocalState(state: Partial<LocalWorkspaceState>) {
  try {
    localStorage.setItem(WORKSPACE_KEY, JSON.stringify(state));
  } catch {
    // Ignore storage failures and let the app surface a local initialization error.
  }
}

function mergeClaimsWithBaseline(savedClaims: Claim[] | undefined): Claim[] {
  const savedById = new Map((savedClaims ?? []).map((claim) => [claim.id, claim]));
  const baselineIds = new Set(BASELINE.claims.map((claim) => claim.id));
  const refreshedBaselineClaims = BASELINE.claims.map((claim) => {
    const saved = savedById.get(claim.id);
    if (!saved) return claim;

    return {
      ...claim,
      state: saved.state,
      updatedAt: saved.updatedAt,
      timeline: saved.timeline,
      documents: saved.documents,
      notes: saved.notes,
    };
  });
  const locallyCreatedClaims = (savedClaims ?? []).filter((claim) => !baselineIds.has(claim.id));
  return [...refreshedBaselineClaims, ...locallyCreatedClaims];
}

export function loadLocalWorkspaceState(): LocalWorkspaceState {
  const existing = readLocalState();
  const storedProfile = existing?.profile ?? DEFAULT_STATE.profile;
  const profile = storedProfile.nationalId === '75031402048'
    ? { ...storedProfile, nationalId: '04011400076', dateOfBirth: '2004-01-14' }
    : storedProfile;
  return {
    ...DEFAULT_STATE,
    ...existing,
    claims: mergeClaimsWithBaseline(existing?.claims),
    notifications: existing?.notifications ?? DEFAULT_STATE.notifications,
    documents: existing?.documents ?? DEFAULT_STATE.documents,
    tickets: existing?.tickets ?? DEFAULT_STATE.tickets,
    searchResults: existing?.searchResults ?? DEFAULT_STATE.searchResults,
    profile,
    consentGiven: existing?.consentGiven ?? DEFAULT_STATE.consentGiven,
  };
}

export function getWorkspaceSnapshot(): SyntheticWorkspace {
  const state = loadLocalWorkspaceState();
  return {
    ...BASELINE,
    claims: state.claims,
    notifications: state.notifications,
    documents: state.documents,
    supportTickets: state.tickets,
    matches: BASELINE.matches,
    profiles: BASELINE.profiles,
    totalUnclaimedBalance: BASELINE.totalUnclaimedBalance,
  };
}

export function saveLocalWorkspaceState(next: Partial<LocalWorkspaceState>) {
  const existing = loadLocalWorkspaceState();
  const merged = { ...existing, ...next };
  writeLocalState(merged);
  return merged;
}

export function resetLocalWorkspaceState() {
  try {
    localStorage.removeItem(WORKSPACE_KEY);
  } catch {
    // Ignore reset errors.
  }
  return loadLocalWorkspaceState();
}
