import { loadLocalWorkspaceState, getWorkspaceSnapshot, saveLocalWorkspaceState } from './workspaceRepository';
import type {
  MatchRecord,
  Claim,
  Notification,
  BeneficiaryProfile,
  Institution,
  RiskAlert,
  AuditEvent,
  FAQ,
  SupportTicket,
  UploadedDocument,
  ClaimState,
} from '@/types';

const TERMINAL_CLAIM_STATES = new Set<ClaimState>(['APPROVED', 'REJECTED', 'CLOSED']);

let cachedSearchResult: {
  matches: MatchRecord[];
  totalBalance: number;
  dormantBalance: number;
  activeBalance: number;
  cachedAt: number;
} | null = null;

function getCachedMatches(): MatchRecord[] {
  return cachedSearchResult?.matches ?? [];
}

function isCacheFresh(): boolean {
  if (!cachedSearchResult) return false;
  return Date.now() - cachedSearchResult.cachedAt < 5 * 60 * 1000;
}

function formatClaimId(): string {
  const stamp = Date.now().toString().slice(-6);
  return `OWF-${new Date().toISOString().slice(0, 10).replace(/-/g, '')}-${stamp}`;
}

function isResolvedClaim(claim: Claim): boolean {
  return TERMINAL_CLAIM_STATES.has(claim.state);
}

function averageResolutionDays(claims: Claim[]): number {
  const resolvedClaims = claims.filter(isResolvedClaim);
  if (resolvedClaims.length === 0) return 0;

  const totalDays = resolvedClaims.reduce((total, claim) => {
    const submitted = new Date(claim.submittedAt).getTime();
    const resolved = new Date(claim.updatedAt).getTime();
    return total + Math.max(0, resolved - submitted) / 86_400_000;
  }, 0);
  return Math.round((totalDays / resolvedClaims.length) * 10) / 10;
}

function getInstitutionMetrics(institutions: Institution[], matches: MatchRecord[], claims: Claim[]): Institution[] {
  return institutions.map((institution) => {
    const institutionClaims = claims.filter((claim) => claim.institutionId === institution.id);
    const resolvedClaims = institutionClaims.filter(isResolvedClaim);
    return {
      ...institution,
      matches: matches.filter((match) => match.institutionId === institution.id).length,
      claims: institutionClaims.length,
      pendingReview: institutionClaims.filter((claim) => !isResolvedClaim(claim)).length,
      resolved: resolvedClaims.length,
      avgResolutionDays: averageResolutionDays(resolvedClaims),
    };
  });
}

export const benefitService = {
  async loadBenefits(): Promise<Institution[]> {
    const workspace = getWorkspaceSnapshot();
    return getInstitutionMetrics(workspace.institutions, workspace.matches, workspace.claims);
  },

  async searchBenefits(profile: BeneficiaryProfile): Promise<MatchRecord[]> {
    const workspace = getWorkspaceSnapshot();
    const q = (profile.nationalId || profile.firstName || profile.lastName || '').trim().toLowerCase();
    const matches = workspace.matches.filter((match) => {
      if (!q) return true;
      return (
        match.beneficiaryId.toLowerCase().includes(q) ||
        match.beneficiaryName.toLowerCase().includes(q) ||
        match.institutionName.toLowerCase().includes(q)
      );
    });
    cachedSearchResult = {
      matches,
      totalBalance: matches.reduce((sum, record) => sum + record.potentialValue, 0),
      dormantBalance: matches.filter((record) => record.status === 'red').reduce((sum, record) => sum + record.potentialValue, 0),
      activeBalance: matches.filter((record) => record.status !== 'red').reduce((sum, record) => sum + record.potentialValue, 0),
      cachedAt: Date.now(),
    };
    saveLocalWorkspaceState({ searchResults: matches.slice(0, 30) });
    return matches;
  },
};

export const matchService = {
  async getMatches(): Promise<MatchRecord[]> {
    if (!isCacheFresh()) {
      const workspace = getWorkspaceSnapshot();
      cachedSearchResult = {
        matches: workspace.matches,
        totalBalance: workspace.matches.reduce((sum, matching) => sum + matching.potentialValue, 0),
        dormantBalance: workspace.matches.filter((m) => m.status === 'red').reduce((sum, matching) => sum + matching.potentialValue, 0),
        activeBalance: workspace.matches.filter((m) => m.status !== 'red').reduce((sum, matching) => sum + matching.potentialValue, 0),
        cachedAt: Date.now(),
      };
    }
    return [...getCachedMatches()];
  },

  async getMatch(id: string): Promise<MatchRecord | undefined> {
    const matches = await this.getMatches();
    return matches.find((match) => match.id === id);
  },

  async getInstitutionMatches(instId = 'gipf'): Promise<Array<{ id: string; beneficiary: string; benefitType: string; confidence: number; signals: number; status: string; date: string }>> {
    const workspace = getWorkspaceSnapshot();
    return workspace.matches
      .filter((match) => match.institutionId === instId)
      .slice(0, 12)
      .map((match, idx) => ({
        id: `${match.id}-queue`,
        beneficiary: match.beneficiaryName,
        benefitType: match.benefitType,
        confidence: match.confidence,
        signals: match.signals.length,
        status: match.status === 'green' ? 'Verified' : match.status === 'amber' ? 'Pending Review' : 'Unmatched',
        date: idx % 2 === 0 ? '2026-10-07' : '2026-10-09',
      }));
  },
};

export const claimService = {
  async getClaims(): Promise<Claim[]> {
    const workspace = getWorkspaceSnapshot();
    return workspace.claims;
  },

  async getClaim(id: string): Promise<Claim | undefined> {
    return (await this.getClaims()).find((claim) => claim.id === id);
  },

  async createClaim(match: MatchRecord): Promise<Claim> {
    const nextClaim: Claim = {
      id: formatClaimId(),
      matchId: match.id,
      beneficiaryId: match.beneficiaryId,
      beneficiaryName: match.beneficiaryName,
      benefitType: match.benefitType,
      institutionId: match.institutionId,
      institutionName: match.institutionName,
      referenceNumber: `${match.institutionId.toUpperCase()}-${Math.random().toString(36).slice(2, 6).toUpperCase()}`,
      state: 'SUBMITTED',
      potentialValue: match.potentialValue,
      submittedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      amount: match.potentialValue,
      createdAt: new Date().toISOString(),
      documents: [],
      timeline: [
        {
          id: `timeline-${Date.now()}`,
          timestamp: new Date().toISOString(),
          label: 'Claim Submitted',
          description: 'Claim submitted through the local synthetic workspace.',
          completed: true,
          current: true,
        },
      ],
      notes: 'Claim initiated in the local synthetic workspace without external network calls.',
    };
    const state = loadLocalWorkspaceState();
    saveLocalWorkspaceState({ claims: [nextClaim, ...state.claims] });
    return nextClaim;
  },

  async submitClaim(claim: Claim): Promise<Claim> {
    const updated: Claim = {
      ...claim,
      state: 'SUBMITTED',
      updatedAt: new Date().toISOString(),
      timeline: [
        ...claim.timeline,
        {
          id: `timeline-${Date.now()}`,
          timestamp: new Date().toISOString(),
          label: 'Submitted',
          description: 'Claim submitted to the synthetic institution queue.',
          completed: true,
          current: true,
        },
      ],
    };
    const state = loadLocalWorkspaceState();
    const nextClaims = [updated, ...state.claims.filter((item) => item.id !== claim.id)];
    saveLocalWorkspaceState({ claims: nextClaims });
    return updated;
  },

  async updateClaimStatus(claimId: string, newState: ClaimState): Promise<void> {
    const state = loadLocalWorkspaceState();
    const nextClaims = state.claims.map((claim) =>
      claim.id === claimId
        ? {
            ...claim,
            state: newState,
            updatedAt: new Date().toISOString(),
            timeline: [
              ...claim.timeline,
              {
                id: `timeline-${Date.now()}`,
                timestamp: new Date().toISOString(),
                label: newState,
                description: `Claim status updated to ${newState} in the local workspace.`,
                completed: true,
                current: true,
              },
            ],
          }
        : claim
    );
    saveLocalWorkspaceState({ claims: nextClaims });
  },

  async getInstitutionClaims(instId = 'gipf'): Promise<Array<{ id: string; beneficiary: string; benefitType: string; institution: string; status: string; value: number; date: string }>> {
    const claims = await this.getClaims();
    return claims
      .filter((claim) => claim.institutionId === instId)
      .map((claim) => ({
        id: claim.id,
        beneficiary: claim.beneficiaryName,
        benefitType: claim.benefitType,
        institution: claim.institutionName,
        status: claim.state,
        value: claim.potentialValue,
        date: claim.submittedAt.slice(0, 10),
      }));
  },

  getValidTransitions(current: ClaimState): ClaimState[] {
    const transitions: Record<ClaimState, ClaimState[]> = {
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
    return transitions[current] ?? [];
  },
};

export const documentService = {
  async uploadDocument(file: File, type: UploadedDocument['type']): Promise<UploadedDocument> {
    const doc: UploadedDocument = {
      id: `doc-local-${Date.now()}`,
      name: file.name,
      type,
      size: file.size,
      uploadStatus: 'verified',
      uploadedAt: new Date().toISOString(),
      verificationStatus: 'verified',
    };
    const state = loadLocalWorkspaceState();
    saveLocalWorkspaceState({ documents: [doc, ...state.documents] });
    return doc;
  },

  async verifyDocument(doc: UploadedDocument): Promise<UploadedDocument> {
    const state = loadLocalWorkspaceState();
    const nextDocs: UploadedDocument[] = state.documents.map((item) =>
      item.id === doc.id ? { ...item, verificationStatus: 'verified', uploadStatus: 'verified' } : item
    );
    saveLocalWorkspaceState({ documents: nextDocs });

    const nextDoc: UploadedDocument = {
      ...doc,
      verificationStatus: 'verified',
      uploadStatus: 'verified',
    };
    return nextDoc;
  },

  async removeDocument(docId: string): Promise<void> {
    const state = loadLocalWorkspaceState();
    saveLocalWorkspaceState({ documents: state.documents.filter((doc) => doc.id !== docId) });
  },
};

export const notificationService = {
  async getNotifications(): Promise<Notification[]> {
    return loadLocalWorkspaceState().notifications;
  },

  async markAsRead(id: string): Promise<void> {
    const state = loadLocalWorkspaceState();
    saveLocalWorkspaceState({ notifications: state.notifications.map((n) => (n.id === id ? { ...n, read: true } : n)) });
  },

  async markAllAsRead(): Promise<void> {
    const state = loadLocalWorkspaceState();
    saveLocalWorkspaceState({ notifications: state.notifications.map((n) => ({ ...n, read: true })) });
  },
};

export const institutionService = {
  async getInstitutions(): Promise<Institution[]> {
    const workspace = getWorkspaceSnapshot();
    return getInstitutionMetrics(workspace.institutions, workspace.matches, workspace.claims);
  },
};

export const analyticsService = {
  async getInstitutionStats() {
    const workspace = getWorkspaceSnapshot();
    const resolvedClaims = workspace.claims.filter(isResolvedClaim);
    return {
      potentialMatches: workspace.matches.length,
      claims: workspace.claims.length,
      pendingReview: workspace.claims.filter((claim) => !isResolvedClaim(claim)).length,
      resolved: resolvedClaims.length,
      avgResolutionDays: averageResolutionDays(resolvedClaims),
      totalDormantValue: workspace.benefitRecords.filter((record) => record.status === 'dormant').reduce((sum, record) => sum + record.approximateValue, 0),
      dormantCount: workspace.benefitRecords.filter((record) => record.status === 'dormant').length,
    };
  },

  async getRegulatorStats() {
    const workspace = getWorkspaceSnapshot();
    const resolvedClaims = workspace.claims.filter(isResolvedClaim);
    return {
      totalBenefits: workspace.benefitRecords
        .filter((record) => record.status === 'unclaimed')
        .reduce((sum, record) => sum + record.approximateValue, 0),
      potentialMatches: workspace.matches.length,
      verifiedMatches: workspace.matches.filter((match) => match.status === 'green').length,
      claims: workspace.claims.length,
      resolved: resolvedClaims.length,
      avgResolutionDays: averageResolutionDays(resolvedClaims),
    };
  },

  async getExecutiveStats() {
    const workspace = getWorkspaceSnapshot();
    const resolvedClaims = workspace.claims.filter(isResolvedClaim);
    return {
      totalBenefits: workspace.benefitRecords
        .filter((record) => record.status === 'unclaimed')
        .reduce((sum, record) => sum + record.approximateValue, 0),
      potentialMatches: workspace.matches.length,
      verifiedMatches: workspace.matches.filter((match) => match.status === 'green').length,
      openClaims: workspace.claims.filter((claim) => !isResolvedClaim(claim)).length,
      resolvedClaims: resolvedClaims.length,
      openClaimValue: workspace.claims
        .filter((claim) => !isResolvedClaim(claim))
        .reduce((sum, claim) => sum + claim.amount, 0),
      avgResolutionTime: averageResolutionDays(resolvedClaims),
      institutionsWithRecords: new Set(workspace.benefitRecords.map((record) => record.institutionId)).size,
    };
  },

  async getBenefitCategoryData() {
    const workspace = getWorkspaceSnapshot();
    const categories = new Map<string, { value: number; claims: number }>();
    for (const record of workspace.benefitRecords.filter((benefit) => benefit.status === 'unclaimed')) {
      const current = categories.get(record.type) ?? { value: 0, claims: 0 };
      categories.set(record.type, {
        value: current.value + record.approximateValue,
        claims: current.claims,
      });
    }
    for (const claim of workspace.claims) {
      const current = categories.get(claim.benefitType) ?? { value: 0, claims: 0 };
      categories.set(claim.benefitType, { ...current, claims: current.claims + 1 });
    }
    return Array.from(categories.entries()).map(([label, payload]) => ({ label, value: payload.value, claims: payload.claims }));
  },

  async getInstitutionActivityData() {
    const workspace = getWorkspaceSnapshot();
    return getInstitutionMetrics(workspace.institutions, workspace.matches, workspace.claims).map((institution) => ({
      label: institution.short,
      matches: institution.matches,
      claims: institution.claims,
      resolved: institution.resolved,
    }));
  },

  async getClaimVolumeData() {
    const workspace = getWorkspaceSnapshot();
    const asOf = new Date(`${workspace.asOfDate}T00:00:00.000Z`);
    const months = Array.from({ length: 6 }, (_, index) => {
      const date = new Date(Date.UTC(asOf.getUTCFullYear(), asOf.getUTCMonth() - 5 + index, 1));
      const key = `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}`;
      return {
        key,
        label: date.toLocaleDateString('en-NA', { month: 'short', year: 'numeric', timeZone: 'UTC' }),
        value: workspace.claims.filter((claim) => claim.submittedAt.slice(0, 7) === key).length,
      };
    });
    return months.map(({ label, value }) => ({ label, value }));
  },

  async getResolutionTrendData() {
    const workspace = getWorkspaceSnapshot();
    const asOf = new Date(`${workspace.asOfDate}T00:00:00.000Z`);
    const quarters = Array.from({ length: 8 }, (_, index) => {
      const date = new Date(Date.UTC(asOf.getUTCFullYear(), asOf.getUTCMonth() - 21 + index * 3, 1));
      const quarter = Math.floor(date.getUTCMonth() / 3) + 1;
      const key = `${date.getUTCFullYear()}-Q${quarter}`;
      const resolvedClaims = workspace.claims.filter((claim) =>
        isResolvedClaim(claim) && `${claim.updatedAt.slice(0, 4)}-Q${Math.floor((Number(claim.updatedAt.slice(5, 7)) - 1) / 3) + 1}` === key
      );
      return {
        label: key,
        resolved: resolvedClaims.length,
        avgDays: resolvedClaims.length > 0 ? averageResolutionDays(resolvedClaims) : undefined,
      };
    });
    return quarters;
  },

  async getRegionalData() {
    const workspace = getWorkspaceSnapshot();
    const map = new Map<string, number>();
    for (const match of workspace.matches) {
      map.set(match.region, (map.get(match.region) ?? 0) + 1);
    }
    return Array.from(map.entries()).map(([label, value]) => ({ label, value }));
  },

  async getExecutiveTrendData() {
    const workspace = getWorkspaceSnapshot();
    const endYear = Number(workspace.asOfDate.slice(0, 4));
    return Array.from({ length: endYear - 2016 + 1 }, (_, index) => {
      const year = String(2016 + index);
      const yearlyMatches = workspace.matches.filter((match) => match.dateIdentified.slice(0, 4) === year);
      return {
        label: year,
        matches: yearlyMatches.length,
        verified: yearlyMatches.filter((match) => match.status === 'green').length,
        claims: workspace.claims.filter((claim) => claim.submittedAt.slice(0, 4) === year).length,
      };
    });
  },
};

export const profileService = {
  async getProfile(): Promise<BeneficiaryProfile | null> {
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
    return getWorkspaceSnapshot().auditEvents;
  },
};

export const supportService = {
  async getFAQs(): Promise<FAQ[]> {
    return getWorkspaceSnapshot().faqs;
  },

  async getTickets(): Promise<SupportTicket[]> {
    return loadLocalWorkspaceState().tickets;
  },

  async createTicket(subject: string, category: string, message: string): Promise<SupportTicket> {
    const existing = loadLocalWorkspaceState();
    const ticket: SupportTicket = {
      id: `OWF-${Date.now()}`,
      subject,
      category,
      status: 'open',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      messages: [{ author: 'You', message, timestamp: new Date().toISOString() }],
    };
    saveLocalWorkspaceState({ tickets: [ticket, ...existing.tickets] });
    return ticket;
  },
};

export const searchClaimable = async (query: { id_number?: string; name?: string }) => {
  const workspace = getWorkspaceSnapshot();
  const q = (query.id_number ?? query.name ?? '').trim().toLowerCase();
  const matches = workspace.matches.filter((match) => {
    if (!q) return true;
    return (
      match.beneficiaryId.toLowerCase().includes(q) ||
      match.beneficiaryName.toLowerCase().includes(q) ||
      match.institutionName.toLowerCase().includes(q) ||
      match.institutionReference.toLowerCase().includes(q)
    );
  });

  const clients = matches.map((match) => {
    const [firstName = '', ...rest] = match.beneficiaryName.split(' ');
    const lastName = rest.join(' ') || 'Synthetic';
    const isDormant = match.status === 'red';

    return {
      id_number: match.beneficiaryId,
      first_name: firstName,
      last_name: lastName,
      firms: [match.institutionId],
      funds_found: 1,
      dormant_balance: isDormant ? match.potentialValue : 0,
      active_balance: isDormant ? 0 : match.potentialValue,
      total_balance: match.potentialValue,
      holdings: [{
        firm: match.institutionId,
        label: match.institutionName,
        ref_number: match.institutionReference,
        balance_nad: match.potentialValue,
        status: isDormant ? 'dormant' : 'active',
        employer: 'Synthetic employer',
        date_joined: '2019-01-01',
      }],
    };
  });

  return {
    clients,
    count: clients.length,
    total_balance: clients.reduce((sum, client) => sum + client.total_balance, 0),
    dormant_balance: clients.reduce((sum, client) => sum + client.dormant_balance, 0),
    active_balance: clients.reduce((sum, client) => sum + client.active_balance, 0),
  };
};

export { searchClaimable as searchClaimableDirect };
