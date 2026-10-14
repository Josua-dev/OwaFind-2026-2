import {
  AS_OF_DATE,
  syntheticWorkspace,
} from '@/data/synthetic';
import {
  getWorkspaceSnapshot,
  loadLocalWorkspaceState,
  saveLocalWorkspaceState,
} from './workspaceRepository';
import type {
  AuditEvent,
  BeneficiaryProfile,
  Claim,
  ClaimState,
  FAQ,
  Institution,
  MatchRecord,
  Notification,
  RiskAlert,
  SupportTicket,
  UploadedDocument,
} from '@/types';

const terminalStates: ClaimState[] = ['APPROVED', 'REJECTED', 'CLOSED'];
const pendingStates: ClaimState[] = [
  'SUBMITTED',
  'IDENTITY_REVIEW',
  'EVIDENCE_REVIEW',
  'INSTITUTION_REVIEW',
  'MORE_INFORMATION_REQUIRED',
  'RESUBMITTED',
  'APPEAL',
];
const stateTransitions: Record<ClaimState, ClaimState[]> = {
  DRAFT: ['SUBMITTED'],
  SUBMITTED: ['IDENTITY_REVIEW'],
  IDENTITY_REVIEW: ['EVIDENCE_REVIEW', 'MORE_INFORMATION_REQUIRED', 'REJECTED'],
  EVIDENCE_REVIEW: ['INSTITUTION_REVIEW', 'MORE_INFORMATION_REQUIRED', 'REJECTED'],
  INSTITUTION_REVIEW: ['APPROVED', 'REJECTED', 'MORE_INFORMATION_REQUIRED'],
  MORE_INFORMATION_REQUIRED: ['RESUBMITTED', 'REJECTED'],
  RESUBMITTED: ['EVIDENCE_REVIEW'],
  APPROVED: ['CLOSED'],
  REJECTED: ['APPEAL', 'CLOSED'],
  APPEAL: ['INSTITUTION_REVIEW', 'CLOSED'],
  CLOSED: [],
};

function getMatchesForProfile(profile: BeneficiaryProfile): MatchRecord[] {
  const id = profile.nationalId.trim().toLowerCase();
  if (!id) return [];
  return syntheticWorkspace.matches.filter((match) => match.beneficiaryId.toLowerCase() === id);
}

function mean(values: number[]): number {
  return values.length ? Math.round(values.reduce((sum, value) => sum + value, 0) / values.length) : 0;
}

function claimResolutionDays(claim: Claim): number {
  return Math.max(0, Math.round(
    (new Date(claim.updatedAt).getTime() - new Date(claim.submittedAt).getTime()) / 86_400_000,
  ));
}

function currentStats() {
  const workspace = getWorkspaceSnapshot();
  const claims = workspace.claims;
  const unclaimed = workspace.benefitRecords.filter((record) => record.status === 'unclaimed');
  const resolved = claims.filter((claim) => terminalStates.includes(claim.state));
  const open = claims.filter((claim) => !terminalStates.includes(claim.state));
  const verifiedMatches = workspace.matches.filter((match) => match.status === 'green').length;
  return {
    workspace,
    claims,
    unclaimed,
    resolved,
    open,
    verifiedMatches,
    avgResolutionDays: mean(resolved.map(claimResolutionDays)),
    totalUnclaimed: unclaimed.reduce((sum, record) => sum + record.approximateValue, 0),
  };
}

function aggregateInstitutions(): Institution[] {
  const { workspace, claims } = currentStats();
  return workspace.institutions.map((institution) => {
    const institutionClaims = claims.filter((claim) => claim.institutionId === institution.id);
    const resolved = institutionClaims.filter((claim) => terminalStates.includes(claim.state));
    return {
      ...institution,
      matches: workspace.matches.filter((match) => match.institutionId === institution.id).length,
      claims: institutionClaims.length,
      pendingReview: institutionClaims.filter((claim) => pendingStates.includes(claim.state)).length,
      resolved: resolved.length,
      avgResolutionDays: mean(resolved.map(claimResolutionDays)),
    };
  });
}

let cachedMatches: MatchRecord[] = [];

export const benefitService = {
  async loadBenefits(): Promise<Institution[]> {
    return aggregateInstitutions();
  },

  async searchBenefits(profile: BeneficiaryProfile): Promise<MatchRecord[]> {
    cachedMatches = getMatchesForProfile(profile);
    saveLocalWorkspaceState({ profile, searchResults: cachedMatches });
    return [...cachedMatches];
  },

  async searchByQuery(query: string): Promise<MatchRecord[]> {
    const normalized = query.trim().toLowerCase();
    if (normalized.length < 2) return [];

    const matchingIds = new Set(
      syntheticWorkspace.profiles
        .filter((profile) =>
          `${profile.firstName} ${profile.lastName}`.toLowerCase().includes(normalized) ||
          profile.nationalId.toLowerCase().includes(normalized) ||
          profile.region.toLowerCase().includes(normalized))
        .map((profile) => profile.nationalId),
    );
    cachedMatches = syntheticWorkspace.matches.filter((match) =>
      matchingIds.has(match.beneficiaryId) ||
      match.institutionName.toLowerCase().includes(normalized) ||
      match.benefitType.toLowerCase().includes(normalized) ||
      match.id.toLowerCase().includes(normalized),
    );
    return [...cachedMatches];
  },
};

export const matchService = {
  async getMatches(): Promise<MatchRecord[]> {
    const state = loadLocalWorkspaceState();
    const storedMatches = state.searchResults;
    if (storedMatches.length) {
      cachedMatches = storedMatches;
      return [...storedMatches];
    }
    cachedMatches = getMatchesForProfile(state.profile);
    return [...cachedMatches];
  },

  async getMatch(id: string): Promise<MatchRecord | undefined> {
    const fromCache = cachedMatches.find((match) => match.id === id);
    return fromCache ?? syntheticWorkspace.matches.find((match) => match.id === id);
  },

  async getInstitutionMatches(instId = 'gipf') {
    return syntheticWorkspace.matches
      .filter((match) => match.institutionId === instId)
      .slice(0, 100)
      .map((match) => ({
        id: match.id,
        beneficiary: match.beneficiaryName,
        benefitType: match.benefitType,
        confidence: match.confidence,
        signals: match.signals.length,
        status: match.status,
        date: match.dateIdentified,
      }));
  },
};

export const claimService = {
  async getClaims(): Promise<Claim[]> {
    return getWorkspaceSnapshot().claims;
  },

  async getClaim(id: string): Promise<Claim | undefined> {
    return getWorkspaceSnapshot().claims.find((claim) => claim.id === id);
  },

  async createClaim(match: MatchRecord): Promise<Claim> {
    const now = new Date().toISOString();
    const id = `OWF-LOCAL-${Date.now().toString(36).toUpperCase()}`;
    return {
      id,
      matchId: match.id,
      beneficiaryId: match.beneficiaryId,
      beneficiaryName: match.beneficiaryName,
      benefitType: match.benefitType,
      institutionId: match.institutionId,
      institutionName: match.institutionName,
      referenceNumber: `LOCAL-${id.slice(-8)}`,
      state: 'DRAFT',
      status: 'DRAFT',
      potentialValue: match.potentialValue,
      amount: match.potentialValue,
      submittedAt: now,
      createdAt: now,
      updatedAt: now,
      documents: [],
      timeline: [{
        id: `${id}-EVENT-1`,
        timestamp: now,
        label: 'Claim drafted',
        description: 'A local claim draft was created. It has not been sent to an institution.',
        completed: true,
        current: true,
      }],
    };
  },

  async submitClaim(claim: Claim): Promise<Claim> {
    const now = new Date().toISOString();
    const submitted: Claim = {
      ...claim,
      state: 'SUBMITTED',
      status: 'SUBMITTED',
      submittedAt: now,
      updatedAt: now,
      timeline: [
        ...claim.timeline.map((event) => ({ ...event, current: false })),
        {
          id: `${claim.id}-SUBMITTED`,
          timestamp: now,
          label: 'Claim submitted locally',
          description: 'This claim is saved in this browser only and has not been sent to an institution.',
          completed: true,
          current: true,
        },
      ],
    };
    const claims = getWorkspaceSnapshot().claims;
    saveLocalWorkspaceState({ claims: [submitted, ...claims.filter((item) => item.id !== submitted.id)] });
    return submitted;
  },

  async updateClaimStatus(claimId: string, newState: ClaimState): Promise<void> {
    const claims = getWorkspaceSnapshot().claims;
    const claim = claims.find((item) => item.id === claimId);
    if (!claim) throw new Error(`Claim ${claimId} was not found in the local workspace.`);
    if (!stateTransitions[claim.state].includes(newState)) {
      throw new Error(`Claim cannot transition from ${claim.state} to ${newState}.`);
    }
    const now = new Date().toISOString();
    const updated: Claim = {
      ...claim,
      state: newState,
      status: newState,
      updatedAt: now,
      timeline: [
        ...claim.timeline.map((event) => ({ ...event, current: false })),
        {
          id: `${claim.id}-${Date.now()}`,
          timestamp: now,
          label: newState.replace(/_/g, ' '),
          description: 'Status updated in the local synthetic workspace.',
          completed: true,
          current: true,
        },
      ],
    };
    saveLocalWorkspaceState({ claims: claims.map((item) => item.id === claimId ? updated : item) });
  },

  async getInstitutionClaims(instId = 'gipf') {
    return getWorkspaceSnapshot().claims
      .filter((claim) => claim.institutionId === instId)
      .map((claim) => ({
        id: claim.id,
        beneficiary: claim.beneficiaryName,
        benefitType: claim.benefitType,
        institution: claim.institutionName ?? instId,
        status: claim.state,
        value: claim.amount ?? claim.potentialValue,
        date: claim.createdAt ?? claim.submittedAt,
      }));
  },

  getValidTransitions(current: ClaimState): ClaimState[] {
    return [...stateTransitions[current]];
  },
};

export const documentService = {
  async uploadDocument(file: File, type: UploadedDocument['type']): Promise<UploadedDocument> {
    const document: UploadedDocument = {
      id: `DOC-LOCAL-${Date.now().toString(36).toUpperCase()}`,
      name: file.name,
      type,
      size: file.size,
      uploadStatus: 'needs_review',
      uploadedAt: new Date().toISOString(),
      verificationStatus: 'pending',
    };
    const documents = loadLocalWorkspaceState().documents;
    saveLocalWorkspaceState({ documents: [document, ...documents] });
    return document;
  },

  async verifyDocument(document: UploadedDocument): Promise<UploadedDocument> {
    return { ...document, uploadStatus: 'needs_review', verificationStatus: 'needs_review' };
  },

  async removeDocument(docId: string): Promise<void> {
    const documents = loadLocalWorkspaceState().documents.filter((document) => document.id !== docId);
    saveLocalWorkspaceState({ documents });
  },
};

export const notificationService = {
  async getNotifications(): Promise<Notification[]> {
    return getWorkspaceSnapshot().notifications;
  },

  async markAsRead(id: string): Promise<void> {
    const notifications = loadLocalWorkspaceState().notifications.map((item) =>
      item.id === id ? { ...item, read: true } : item,
    );
    saveLocalWorkspaceState({ notifications });
  },

  async markAllAsRead(): Promise<void> {
    saveLocalWorkspaceState({
      notifications: loadLocalWorkspaceState().notifications.map((item) => ({ ...item, read: true })),
    });
  },
};

export const institutionService = {
  async getInstitutions(): Promise<Institution[]> {
    return aggregateInstitutions();
  },
};

export const analyticsService = {
  async getInstitutionStats() {
    const stats = currentStats();
    return {
      potentialMatches: stats.workspace.matches.length,
      claims: stats.claims.length,
      pendingReview: stats.claims.filter((claim) => pendingStates.includes(claim.state)).length,
      resolved: stats.resolved.length,
      avgResolutionDays: stats.avgResolutionDays,
      totalDormantValue: stats.workspace.benefitRecords
        .filter((record) => record.status === 'dormant')
        .reduce((sum, record) => sum + record.approximateValue, 0),
      dormantCount: stats.workspace.benefitRecords.filter((record) => record.status === 'dormant').length,
    };
  },

  async getRegulatorStats() {
    const stats = currentStats();
    return {
      totalBenefits: stats.totalUnclaimed,
      potentialMatches: stats.workspace.matches.length,
      verifiedMatches: stats.verifiedMatches,
      claims: stats.claims.length,
      resolved: stats.resolved.length,
      avgResolutionDays: stats.avgResolutionDays,
    };
  },

  async getExecutiveStats() {
    const stats = currentStats();
    const openClaimValue = stats.open.reduce((sum, claim) => sum + (claim.amount ?? claim.potentialValue), 0);
    return {
      totalBenefits: stats.totalUnclaimed,
      potentialMatches: stats.workspace.matches.length,
      verifiedMatches: stats.verifiedMatches,
      openClaims: stats.open.length,
      resolvedClaims: stats.resolved.length,
      potentialRecoveryValue: stats.totalUnclaimed,
      openClaimValue,
      avgResolutionTime: stats.avgResolutionDays,
      activeInstitutions: stats.workspace.institutions.length,
      institutionsWithRecords: new Set(stats.workspace.benefitRecords.map((record) => record.institutionId)).size,
    };
  },

  async getBenefitCategoryData() {
    const { workspace, claims } = currentStats();
    return [...new Set(workspace.benefitRecords.map((record) => record.type))].map((type) => ({
      label: type,
      value: workspace.benefitRecords
        .filter((record) => record.type === type && record.status === 'unclaimed')
        .reduce((sum, record) => sum + record.approximateValue, 0),
      claims: claims.filter((claim) => claim.benefitType === type).length,
    }));
  },

  async getInstitutionActivityData() {
    return aggregateInstitutions().map((institution) => ({
      label: institution.short ?? institution.name,
      matches: institution.matches,
      claims: institution.claims,
      resolved: institution.resolved,
    }));
  },

  async getClaimVolumeData() {
    const claims = getWorkspaceSnapshot().claims;
    const months = Array.from({ length: 6 }, (_, index) => {
      const date = new Date(`${AS_OF_DATE}T00:00:00.000Z`);
      date.setUTCDate(1);
      date.setUTCMonth(date.getUTCMonth() - (5 - index));
      const key = date.toISOString().slice(0, 7);
      return {
        label: date.toLocaleString('en', { month: 'short', timeZone: 'UTC' }),
        value: claims.filter((claim) => claim.submittedAt.slice(0, 7) === key).length,
      };
    });
    return months;
  },

  async getResolutionTrendData() {
    const claims = getWorkspaceSnapshot().claims.filter((claim) => terminalStates.includes(claim.state));
    const quarters = Array.from({ length: 8 }, (_, index) => {
      const quarter = 3 + index;
      const year = 2024 + Math.floor(quarter / 4);
      const q = quarter % 4 + 1;
      const label = `${year}-Q${q}`;
      const periodClaims = claims.filter((claim) => {
        const month = Number(claim.updatedAt.slice(5, 7));
        return claim.updatedAt.slice(0, 4) === String(year) && Math.ceil(month / 3) === q;
      });
      return { label, resolved: periodClaims.length, avgDays: mean(periodClaims.map(claimResolutionDays)) };
    });
    return quarters;
  },

  async getRegionalData() {
    const { workspace } = currentStats();
    const counts = new Map<string, number>();
    for (const match of workspace.matches) counts.set(match.region, (counts.get(match.region) ?? 0) + 1);
    return [...counts].map(([label, value]) => ({ label, value }));
  },

  async getExecutiveTrendData() {
    const { workspace, claims } = currentStats();
    return Array.from({ length: 11 }, (_, index) => {
      const year = 2016 + index;
      const yearMatches = workspace.matches.filter((match) => match.dateIdentified.slice(0, 4) === String(year));
      return {
        label: String(year),
        matches: yearMatches.length,
        verified: yearMatches.filter((match) => match.status === 'green').length,
        claims: claims.filter((claim) => claim.submittedAt.slice(0, 4) === String(year)).length,
      };
    });
  },
};

export const profileService = {
  async getProfile(): Promise<BeneficiaryProfile> {
    return loadLocalWorkspaceState().profile;
  },

  async updateProfile(profile: BeneficiaryProfile): Promise<BeneficiaryProfile> {
    saveLocalWorkspaceState({ profile });
    return profile;
  },
};

export const riskService = {
  async getRiskAlerts(): Promise<RiskAlert[]> {
    return getWorkspaceSnapshot().riskAlerts;
  },
};

export const auditService = {
  async getAuditEvents(): Promise<AuditEvent[]> {
    return [...getWorkspaceSnapshot().auditEvents].sort((a, b) =>
      b.timestamp.localeCompare(a.timestamp),
    );
  },
};

export const supportService = {
  async getFAQs(): Promise<FAQ[]> {
    return getWorkspaceSnapshot().faqs;
  },

  async getTickets(): Promise<SupportTicket[]> {
    return getWorkspaceSnapshot().supportTickets;
  },

  async createTicket(subject: string, category: string, message: string): Promise<SupportTicket> {
    const now = new Date().toISOString();
    const ticket: SupportTicket = {
      id: `SUP-LOCAL-${Date.now().toString(36).toUpperCase()}`,
      subject,
      category,
      status: 'open',
      createdAt: now,
      updatedAt: now,
      messages: [{ author: 'You', message, timestamp: now }],
    };
    const tickets = loadLocalWorkspaceState().tickets;
    saveLocalWorkspaceState({ tickets: [ticket, ...tickets] });
    return ticket;
  },
};

export const healthService = {
  async getHealth() {
    return { healthy: true };
  },

  async getServiceInfo() {
    return { service: 'Local synthetic workspace', asOfDate: AS_OF_DATE };
  },
};
