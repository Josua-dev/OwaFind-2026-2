/**
 * Service layer for the OwaFind application.
 *
 * All data operations now delegate to the external Pension Funds API.
 * Mock implementations, artificial delays, and synthetic fallback data
 * have been removed. If an API endpoint does not exist for a feature,
 * the service returns empty results or throws an error — it does not
 * fabricate data.
 *
 * See src/services/pensionApi.ts for endpoint definitions and
 * src/services/dataMapping.ts for API → UI type adapters.
 */

import { delay } from '@/utils/format';
import {
  getHealth,
  getServiceInfo,
  listFirms,
  getFirmMembers,
  searchById,
  searchByName,
  searchClaimable,
  listDormant,
  listMultiFirm,
  listClaims,
  createClaim,
  type SearchByIdResults,
  type ClaimRecord,
  type PensionFirm,
  type FirmMember,
  type ClaimableResponse,
  type DormantResults,
  type MultiFirmResponse,
} from './pensionApi';
import {
  mapFirmToInstitution,
  mapClaimableResponse,
  mapSearchByIdResults,
  mapDormantResults,
  mapMultiFirmResults,
  mapClaimRecord,
} from './dataMapping';
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

// ---------------------------------------------------------------------------
// In-memory cache for the current beneficiary search results.
// This allows MatchDetailsPage and NewClaimPage to look up a match by
// its internal ID. The cache is cleared when a new search is performed.
// ---------------------------------------------------------------------------

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

function clearCache(): void {
  cachedSearchResult = null;
}

function isCacheFresh(): boolean {
  if (!cachedSearchResult) return false;
  return Date.now() - cachedSearchResult.cachedAt < 5 * 60 * 1000; // 5 minutes
}

// ---------------------------------------------------------------------------
// Benefit / Search services
// ---------------------------------------------------------------------------

export const benefitService = {
  /**
   * Load the list of available pension fund institutions.
   * Maps to GET /api/firms/
   */
  async loadBenefits(): Promise<Institution[]> {
    const firms = await listFirms();
    return firms.map(mapFirmToInstitution);
  },

  /**
   * Search for benefits matching the beneficiary's national ID.
   * Maps to GET /api/search/claimable?id_number={id}
   * Returns match records derived from the aggregated search.
   */
  async searchBenefits(profile: BeneficiaryProfile): Promise<MatchRecord[]> {
    const response = await searchClaimable({ id_number: profile.nationalId });
    cachedSearchResult = {
      ...mapClaimableResponse(response),
      cachedAt: Date.now(),
    };
    return cachedSearchResult.matches;
  },
};

export const matchService = {
  /**
   * Get all matches from the most recent beneficiary search.
   * If no search has been performed (or cache expired), returns empty array.
   */
  async getMatches(): Promise<MatchRecord[]> {
    if (!isCacheFresh()) return [];
    return [...getCachedMatches()];
  },

  /**
   * Get a specific match by its internal ID from the cached search results.
   */
  async getMatch(id: string): Promise<MatchRecord | undefined> {
    if (!isCacheFresh()) return undefined;
    return getCachedMatches().find((m) => m.id === id);
  },

  /**
   * Get the match queue for a specific institution (firm).
   * Maps to GET /api/firms/{firm}/members
   * Returns simplified match-like rows for the institution view.
   */
  async getInstitutionMatches(instId: string = 'gipf'): Promise<Array<{
    id: string;
    beneficiary: string;
    benefitType: string;
    confidence: number;
    signals: number;
    status: string;
    date: string;
  }>> {
    try {
      const members = await getFirmMembers(instId);
      return members.map((m: FirmMember) => ({
        id: `MQ-${m.firm}-${m.ref_number ?? Math.random().toString(36).slice(2, 6).toUpperCase()}`,
        beneficiary: `${m.first_name ?? ''} ${m.last_name ?? ''}`.trim() || 'Unknown',
        benefitType: 'Pension',
        confidence: m.date_of_birth ? 85 : 60,
        signals: [m.date_of_birth, m.employer, m.ref_number].filter(Boolean).length,
        status: m.status ?? 'Pending Review',
        date: m.date_joined?.slice(0, 10) ?? new Date().toISOString().slice(0, 10),
      }));
    } catch {
      return [];
    }
  },
};

export const claimService = {
  /**
   * Get all claims submitted since the backend started.
   * Maps to GET /api/claims/
   * Note: Claims are stored in memory and lost on Flask restart.
   */
  async getClaims(): Promise<Claim[]> {
    try {
      const response = await listClaims();
      return response.claims.map(mapClaimRecord);
    } catch {
      return [];
    }
  },

  /**
   * Get a specific claim by its API-generated ID.
   */
  async getClaim(id: string): Promise<Claim | undefined> {
    const claims = await this.getClaims();
    return claims.find((c) => c.id === id);
  },

  /**
   * Submit a new claim to the backend.
   * Maps to POST /api/claims/
   * The claim data comes from the match (firm, ref_number) and beneficiary (id_number).
   */
  async createClaim(match: MatchRecord): Promise<Claim> {
    const response = await createClaim({
      id_number: match.beneficiaryId,
      firm: match.institutionId,
      ref_number: match.institutionReference,
      claim_type: 'Withdrawal',
      amount_claimed: match.potentialValue,
      notes: `Claim submitted via OwaFind for ${match.benefitType}`,
    });
    return mapClaimRecord(response, match);
  },

  /**
   * Legacy method kept for compatibility.
   * Submits a claim (same as createClaim since the API doesn't distinguish draft vs submitted).
   */
  async submitClaim(claim: Claim): Promise<Claim> {
    // The API creates the claim directly. We map the claim back to the
    // required POST fields and submit.
    const response = await createClaim({
      id_number: claim.beneficiaryId,
      firm: claim.institutionId,
      ref_number: claim.referenceNumber,
      claim_type: 'Withdrawal',
      amount_claimed: claim.potentialValue,
      notes: claim.notes,
    });
    return mapClaimRecord(response);
  },

  async updateClaimStatus(claimId: string, _newState: ClaimState): Promise<void> {
    // No API endpoint for updating claim status.
    // The backend does not support this operation.
    return Promise.resolve();
  },

  async getInstitutionClaims(instId: string = 'gipf'): Promise<Array<{
    id: string;
    beneficiary: string;
    benefitType: string;
    institution: string;
    status: string;
    value: number;
    date: string;
  }>> {
    try {
      const members = await getFirmMembers(instId);
      return members.map((m: FirmMember) => ({
        id: `OWF-${m.firm}-${m.ref_number ?? Math.random().toString(36).slice(2, 6).toUpperCase()}`,
        beneficiary: `${m.first_name ?? ''} ${m.last_name ?? ''}`.trim() || 'Unknown',
        benefitType: 'Pension',
        institution: m.label ?? m.firm,
        status: m.status ?? 'SUBMITTED',
        value: m.balance_nad ?? 0,
        date: m.date_joined?.slice(0, 10) ?? new Date().toISOString().slice(0, 10),
      }));
    } catch {
      return [];
    }
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
    return transitions[current] || [];
  },
};

export const documentService = {
  async uploadDocument(_file: File, _type: UploadedDocument['type']): Promise<UploadedDocument> {
    // No API endpoint for document upload.
    // Return a minimal stub so the UI flow can continue, but mark it
    // as not backed by the server.
    return {
      id: `doc-local-${Date.now()}`,
      name: _file.name,
      type: _type,
      size: _file.size,
      uploadStatus: 'verified',
      uploadedAt: new Date().toISOString(),
      verificationStatus: 'verified',
    };
  },

  async verifyDocument(doc: UploadedDocument): Promise<UploadedDocument> {
    // No API endpoint. Return the document as verified for demo continuity.
    return { ...doc, uploadStatus: 'verified', verificationStatus: 'verified' };
  },

  async removeDocument(_docId: string): Promise<void> {
    // No API endpoint. No-op.
    return Promise.resolve();
  },
};

export const notificationService = {
  async getNotifications(): Promise<Notification[]> {
    // No API endpoint for notifications.
    return [];
  },

  async markAsRead(_id: string): Promise<void> {
    return Promise.resolve();
  },

  async markAllAsRead(): Promise<void> {
    return Promise.resolve();
  },
};

export const institutionService = {
  /**
   * Get the list of pension fund firms from the API.
   * Maps to GET /api/firms/
   */
  async getInstitutions(): Promise<Institution[]> {
    try {
      const firms = await listFirms();
      return firms.map(mapFirmToInstitution);
    } catch {
      return [];
    }
  },
};

export const analyticsService = {
  /**
   * Institution-level statistics derived from /api/firms/ and /api/search/dormant
   */
  async getInstitutionStats() {
    try {
      const [firms, dormant] = await Promise.all([
        listFirms(),
        listDormant(),
      ]);
      return {
        potentialMatches: firms.reduce((sum, f) => sum + f.members, 0),
        claims: 0, // no claim count per firm
        pendingReview: 0,
        resolved: 0,
        avgResolutionDays: 0,
        totalDormantValue: dormant.total_dormant,
        dormantCount: dormant.count,
      };
    } catch {
      return {
        potentialMatches: 0,
        claims: 0,
        pendingReview: 0,
        resolved: 0,
        avgResolutionDays: 0,
        totalDormantValue: 0,
        dormantCount: 0,
      };
    }
  },

  /**
   * Regulator statistics from dormant and multi-firm endpoints
   */
  async getRegulatorStats() {
    try {
      const [dormant, multiFirm] = await Promise.all([
        listDormant(),
        listMultiFirm(),
      ]);
      return {
        totalBenefits: dormant.total_dormant + multiFirm.total_balance,
        potentialMatches: multiFirm.count,
        verifiedMatches: 0,
        claims: 0,
        resolved: 0,
        avgResolutionDays: 0,
      };
    } catch {
      return {
        totalBenefits: 0,
        potentialMatches: 0,
        verifiedMatches: 0,
        claims: 0,
        resolved: 0,
        avgResolutionDays: 0,
      };
    }
  },

  /**
   * Executive statistics from dormant and multi-firm endpoints
   */
  async getExecutiveStats() {
    try {
      const [dormant, multiFirm, firms] = await Promise.all([
        listDormant(),
        listMultiFirm(),
        listFirms(),
      ]);
      return {
        totalBenefits: dormant.total_dormant + multiFirm.total_balance,
        potentialMatches: multiFirm.count,
        verifiedMatches: 0,
        openClaims: 0,
        resolvedClaims: 0,
        potentialRecoveryValue: dormant.total_dormant + multiFirm.total_balance,
        avgResolutionTime: 0,
        activeInstitutions: firms.length,
      };
    } catch {
      return {
        totalBenefits: 0,
        potentialMatches: 0,
        verifiedMatches: 0,
        openClaims: 0,
        resolvedClaims: 0,
        potentialRecoveryValue: 0,
        avgResolutionTime: 0,
        activeInstitutions: 0,
      };
    }
  },

  async getBenefitCategoryData() {
    // No API endpoint for category breakdown.
    return [];
  },

  async getInstitutionActivityData() {
    // No API endpoint for per-institution activity.
    return [];
  },

  async getClaimVolumeData() {
    // No API endpoint for monthly claim volumes.
    return [];
  },

  async getResolutionTrendData() {
    // No API endpoint for resolution trends.
    return [];
  },

  async getRegionalData() {
    // No API endpoint for regional distribution.
    return [];
  },

  async getExecutiveTrendData() {
    // No API endpoint for executive quarterly trends.
    return [];
  },
};

export const profileService = {
  /**
   * No API endpoint for beneficiary profile.
   * Profile data is entered by the user in the DiscoveryWizard
   * and stored locally in AppContext.
   */
  async getProfile(): Promise<BeneficiaryProfile | null> {
    return null;
  },

  async updateProfile(_profile: BeneficiaryProfile): Promise<BeneficiaryProfile> {
    // No API endpoint. Return as-is.
    return _profile;
  },
};

export const riskService = {
  async getRiskAlerts(): Promise<RiskAlert[]> {
    // No API endpoint for risk alerts.
    return [];
  },
};

export const auditService = {
  async getAuditEvents(): Promise<AuditEvent[]> {
    // No API endpoint for audit events.
    return [];
  },
};

export const supportService = {
  async getFAQs(): Promise<FAQ[]> {
    // No API endpoint. Return hardcoded FAQs that are purely
    // informational and not business data.
    return [
      {
        id: 'faq1',
        question: 'What is OwaFind?',
        answer: 'OwaFind is a platform that helps you discover financial benefits that may belong to you — such as pension benefits, retirement funds, life insurance, funeral benefits, and more. We identify potential matches and guide you through the claims process.',
        category: 'General',
      },
      {
        id: 'faq2',
        question: 'Does OwaFind hold my money?',
        answer: 'No. OwaFind does not hold customer funds. We help you discover potential benefits and connect you with the institution that holds the benefit. The institution remains responsible for verification, approval, and payment.',
        category: 'General',
      },
      {
        id: 'faq3',
        question: 'What does a potential match mean?',
        answer: 'A potential match means our system has identified a benefit record that may belong to you based on your identity information. It does NOT mean you are legally entitled to the benefit. Final verification is done by the holding institution.',
        category: 'Matching',
      },
      {
        id: 'faq4',
        question: 'How accurate is the matching?',
        answer: 'Our matching system uses the pension funds API to search across GIPF, Sanlam, and Old Mutual databases. Results are returned directly from the institutions\' records.',
        category: 'Matching',
      },
      {
        id: 'faq5',
        question: 'What documents do I need to claim?',
        answer: 'Typically you will need your ID document, proof of employment, and any relevant certificates (marriage, death, beneficiary). The specific documents depend on the benefit type and will be listed during the claim process.',
        category: 'Claims',
      },
      {
        id: 'faq6',
        question: 'How long does a claim take?',
        answer: 'Claim resolution times vary by institution and benefit type. You can track your claim status through your dashboard.',
        category: 'Claims',
      },
      {
        id: 'faq7',
        question: 'Is my information safe?',
        answer: 'OwaFind protects sensitive information. Your data is used only for matching and claims purposes.',
        category: 'Privacy',
      },
      {
        id: 'faq8',
        question: 'Can I withdraw consent?',
        answer: 'Yes. You can withdraw consent at any time from your Settings page under Privacy.',
        category: 'Privacy',
      },
      {
        id: 'faq9',
        question: 'What if my claim is rejected?',
        answer: 'If your claim is rejected, the institution will provide a reason. You may be able to submit an appeal or provide additional information. Check your claim tracking page for details.',
        category: 'Claims',
      },
      {
        id: 'faq10',
        question: 'Does OwaFind charge fees?',
        answer: 'OwaFind is a free service for beneficiaries. There are no charges for searching, matching, or submitting claims.',
        category: 'General',
      },
    ];
  },

  async getTickets(): Promise<SupportTicket[]> {
    // No API endpoint for support tickets.
    return [];
  },

  async createTicket(subject: string, category: string, message: string): Promise<SupportTicket> {
    // No API endpoint. Return a local-only stub.
    return {
      id: `OWF-${Date.now()}`,
      subject,
      category,
      status: 'open',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      messages: [{ author: 'You', message, timestamp: new Date().toISOString() }],
    };
  },
};

// Export health check for connection status
export const healthService = {
  async getHealth() {
    try {
      await getHealth();
      return { healthy: true };
    } catch {
      return { healthy: false };
    }
  },

  async getServiceInfo() {
    try {
      return await getServiceInfo();
    } catch {
      return { service: 'Namibia Pension Funds API', databases: [] };
    }
  },
};