/**
 * Adapters that map raw API response objects into the UI's presentation models.
 * Keeps API shapes separate from UI models so the rest of the app can stay
 * close to its existing types where practical.
 */

import type {
  FirmMember,
  PensionHolding,
  ClientHolding,
  ClaimableResponse,
  MultiFirmHolding,
  MultiFirmResponse,
  DormantResults,
  PensionFirm,
  ClaimRecord,
} from './pensionApi';
import type {
  BeneficiaryProfile,
  MatchRecord,
  BenefitRecord,
  Institution,
  RiskAlert,
  AuditEvent,
  Notification,
  SupportTicket,
  Claim,
} from '@/types';

// ---------------------------------------------------------------------------
// Static institution metadata (descriptive only — NOT live from the API)
// ---------------------------------------------------------------------------

const INSTITUTION_METADATA: Record<
  string,
  { name: string; label: string; type: Institution['type']; region: string }
> = {
  gipf: {
    name: 'Government Institutions Pension Fund (GIPF)',
    label: 'GIPF',
    type: 'Pension Fund',
    region: 'Windhoek',
  },
  sanlam: {
    name: 'Sanlam Namibia',
    label: 'Sanlam',
    type: 'Insurer',
    region: 'Windhoek',
  },
  oldmutual: {
    name: 'Old Mutual Namibia',
    label: 'Old Mutual',
    type: 'Insurer',
    region: 'Windhoek',
  },
};

// ---------------------------------------------------------------------------
// Firm → Institution mapping
// ---------------------------------------------------------------------------

export function mapFirmToInstitution(firm: PensionFirm): Institution {
  const meta = INSTITUTION_METADATA[firm.firm] ?? {
    name: firm.label,
    label: firm.label,
    type: 'Pension Fund' as const,
    region: 'Namibia',
  };
  return {
    id: firm.firm,
    name: meta.name,
    type: meta.type,
    region: meta.region,
    matches: firm.members,
    claims: 0, // no claim-count endpoint per firm
    pendingReview: 0,
    resolved: 0,
    avgResolutionDays: 0,
    demo: false,
  };
}

// ---------------------------------------------------------------------------
// Claimable search → MatchRecord[] + total balance
// ---------------------------------------------------------------------------

export interface ClaimableSearchResult {
  matches: MatchRecord[];
  totalBalance: number;
  dormantBalance: number;
  activeBalance: number;
}

function matchStatusFromConfidence(confidence: number): MatchRecord['status'] {
  if (confidence >= 80) return 'green';
  if (confidence >= 50) return 'amber';
  return 'red';
}

function confidenceFromHolding(holding: PensionHolding): number {
  // The API does not return a confidence score — derive a coarse proxy
  // from data completeness (balance present, employment data present).
  let score = 50;
  if (holding.balance_nad) score += 15;
  if (holding.employer) score += 15;
  if (holding.date_joined) score += 10;
  if (holding.ref_number) score += 10;
  return Math.min(95, score);
}

export function mapClaimableResponse(response: ClaimableResponse): ClaimableSearchResult {
  const matches: MatchRecord[] = [];
  let totalBalance = 0;
  let dormantBalance = 0;
  let activeBalance = 0;

  for (const client of response.clients) {
    const clientName =
      `${client.first_name ?? ''} ${client.last_name ?? ''}`.trim() || 'Unknown';
    const idNumber = client.id_number ?? '';

    for (const holding of client.holdings) {
      const balance = holding.balance_nad ?? 0;
      totalBalance += balance;

      // Use status field to split dormant vs active; default to treating
      // unknown status as active.
      const isDormant = (holding.status ?? '').toLowerCase().includes('dormant');
      if (isDormant) {
        dormantBalance += balance;
      } else {
        activeBalance += balance;
      }

      const confidence = confidenceFromHolding(holding);
      const status = matchStatusFromConfidence(confidence);

      matches.push({
        id: `m-${holding.firm}-${holding.ref_number ?? Math.random().toString(36).slice(2, 8)}`,
        beneficiaryId: idNumber,
        beneficiaryName: clientName,
        benefitType: 'Pension',
        institutionId: holding.firm,
        institutionName: holding.label,
        institutionReference: holding.ref_number ?? '',
        potentialValue: balance,
        confidence,
        status,
        signals: [
          { label: 'Name', strength: 'strong' },
          { label: 'National ID', strength: 'exact' },
          { label: 'Employer', strength: holding.employer ? 'strong' : 'weak' },
        ],
        employmentPeriod:
          holding.date_left && holding.date_joined
            ? `${holding.date_joined.slice(0, 7)}–${holding.date_left.slice(0, 7)}`
            : undefined,
        dateIdentified: new Date().toISOString(),
        region: 'Windhoek',
      });
    }
  }

  return {
    matches,
    totalBalance,
    dormantBalance,
    activeBalance,
  };
}

// ---------------------------------------------------------------------------
// Search-by-ID → MatchRecord[] (cross-firm search)
// ---------------------------------------------------------------------------

export function mapSearchByIdResults(results: {
  id_number: string;
  firms?: string[];
  total_balance: number;
  dormant_balance: number;
  results: FirmMember[];
}): MatchRecord[] {
  return results.results.map((member, index) => {
    const balance = member.balance_nad ?? 0;
    const confidence = member.date_of_birth ? 90 : 60;
    const institutionId = results.firms?.[index] ?? 'unknown';
    return {
      id: `id-${institutionId}-${member.ref_number ?? index}`,
      beneficiaryId: member.id_number,
      beneficiaryName: `${member.first_name ?? ''} ${member.last_name ?? ''}`.trim(),
      benefitType: 'Pension',
      institutionId,
      institutionName: institutionId,
      institutionReference: member.ref_number,
      potentialValue: balance,
      confidence,
      status: matchStatusFromConfidence(confidence),
      signals: [{ label: 'National ID', strength: 'exact' }],
      dateIdentified: new Date().toISOString(),
      region: 'Windhoek',
    };
  });
}

// ---------------------------------------------------------------------------
// Dormant listings → BenefitRecord[]
// ---------------------------------------------------------------------------

export function mapDormantResults(results: DormantResults): BenefitRecord[] {
  return results.results.map((member) => ({
    id: `dormant-${member.ref_number ?? ''}`,
    type: 'Pension',
    institutionId: 'unknown',
    institutionName: 'Unknown institution',
    reference: member.ref_number ?? '',
    approximateValue: member.balance_nad ?? 0,
    region: 'Namibia',
    status: 'dormant',
  }));
}

// ---------------------------------------------------------------------------
// Multi-firm results → MatchRecord[]
// ---------------------------------------------------------------------------

export function mapMultiFirmResults(response: MultiFirmResponse): MatchRecord[] {
  const matches: MatchRecord[] = [];
  for (const client of response.clients) {
    const clientName = `${client.first_name ?? ''} ${client.last_name ?? ''}`.trim();
    const idNumber = client.id_number ?? '';
    for (const holding of client.holdings) {
      const balance = holding.balance_nad ?? 0;
      const confidence = 80;
      matches.push({
        id: `mf-${holding.firm}-${holding.ref_number ?? Math.random().toString(36).slice(2, 8)}`,
        beneficiaryId: idNumber,
        beneficiaryName: clientName,
        benefitType: 'Pension',
        institutionId: holding.firm,
        institutionName: holding.label,
        institutionReference: holding.ref_number ?? '',
        potentialValue: balance,
        confidence,
        status: matchStatusFromConfidence(confidence),
        signals: [{ label: 'Multi-firm presence', strength: 'strong' }],
        dateIdentified: new Date().toISOString(),
        region: 'Namibia',
      });
    }
  }
  return matches;
}

// ---------------------------------------------------------------------------
// Claims → UI Claim model
// ---------------------------------------------------------------------------

export function mapClaimRecord(claim: ClaimRecord, match: MatchRecord | null = null): Claim {
  return {
    id: claim.id,
    matchId: match?.id ?? '',
    beneficiaryId: claim.id_number,
    beneficiaryName: match?.beneficiaryName ?? '',
    benefitType: 'Pension',
    institutionId: claim.firm,
    institutionName: match?.institutionName ?? claim.firm,
    referenceNumber: claim.ref_number,
    state: 'SUBMITTED',
    potentialValue: claim.amount_claimed ?? 0,
    amount: claim.amount_claimed ?? 0,
    submittedAt: claim.created_at,
    createdAt: claim.created_at,
    updatedAt: claim.created_at,
    documents: [],
    timeline: [
      {
        id: 't1',
        timestamp: claim.created_at,
        label: 'Claim Submitted',
        description: 'Claim has been submitted to the pension fund.',
        completed: true,
        current: true,
      },
    ],
    notes: claim.notes,
  };
}
