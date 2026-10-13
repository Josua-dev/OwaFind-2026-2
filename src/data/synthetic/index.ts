import type {
  Institution,
  MatchRecord,
  Claim,
  Notification,
  RiskAlert,
  AuditEvent,
  FAQ,
  SupportTicket,
  UploadedDocument,
  BenefitRecord,
  BeneficiaryProfile,
} from '@/types';

export const AS_OF_DATE = '2026-10-12';
export const TOTAL_UNCLAIMED_BALANCE = 218_700_000;

export interface SyntheticWorkspace {
  asOfDate: string;
  institutions: Institution[];
  profiles: BeneficiaryProfile[];
  benefitRecords: BenefitRecord[];
  matches: MatchRecord[];
  claims: Claim[];
  notifications: Notification[];
  riskAlerts: RiskAlert[];
  auditEvents: AuditEvent[];
  faqs: FAQ[];
  supportTickets: SupportTicket[];
  documents: UploadedDocument[];
  totalUnclaimedBalance: number;
}

const institutionCatalog = [
  { id: 'gipf', name: 'Government Institutions Pension Fund (GIPF)', short: 'GIPF', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'namcor-pension', name: 'Namcor Pension Fund', short: 'Namcor', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'nampower-provident', name: 'Nampower Provident Fund', short: 'Nampower', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'namwater-retirement', name: 'Namwater Retirement Fund', short: 'Namwater', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'nbc-retirement', name: 'NBC Retirement Fund', short: 'NBC', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'rossing-pension', name: 'Rossing Pension Fund', short: 'Rossing', type: 'Pension Fund', region: 'Arandis' },
  { id: 'namport-retirement', name: 'Namport Retirement Fund', short: 'Namport', type: 'Pension Fund', region: 'Walvis Bay' },
  { id: 'bon-provident', name: 'Bank of Namibia Provident Fund', short: 'BoN', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'mtc-pension', name: 'MTC Pension Fund', short: 'MTC', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'standard-bank-pension', name: 'Standard Bank Namibia Pension Fund', short: 'Std Bank', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'namib-mills-pension', name: 'Namib Mills Pension Fund', short: 'Nam Mills', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'transnamib-retirement', name: 'TransNamib Retirement Fund', short: 'TransNamib', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'capricorn-retirement', name: 'Capricorn Group Retirement Fund', short: 'Capricorn', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'pupkewitz-pension', name: 'Pupkewitz Group Pension Fund', short: 'Pupkewitz', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'nbw-pension', name: "Namibia Building Workers' Pension Fund", short: 'NBW', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'universities-retirement', name: 'Universities Retirement Fund', short: 'Universities', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'nhe-retirement', name: 'NHE Retirement Fund', short: 'NHE', type: 'Pension Fund', region: 'Windhoek' },
  { id: 'sanlam-namibia', name: 'Sanlam Namibia', short: 'Sanlam', type: 'Insurer', region: 'Windhoek' },
  { id: 'old-mutual-namibia', name: 'Old Mutual Namibia', short: 'Old Mutual', type: 'Insurer', region: 'Windhoek' },
] as const;

const firstNames = ['Josua','Pendukeni','Gideon','Linea','Kornelius','Victoria','Fanuel','Selma','Barney','Ndeshi','Mateus','Frieda','Kauna','Ester','Johannes','Rosalia','Petrus','Magrieta','Immanuel','Lukas','Abraham','Sarah','David','Leah','Rachel','Jacob','Benjamin','Joseph','Samuel','Daniel','Moses'];
const lastNames = ['Uuyuni','Hamukwaya','Nepembe','Shilongo','Shipepe','Amukwaya','Tjirera','Amutenya','Haufiku','Andreas','Sheya','Namwandi','Shikwambi','Nangolo','Gawanas','Muvangua','Ndjarakana','Hoveka','Tjipuka','Mutinga','Nankudhu','Amadhila','Shaningwa','Amukoshi','Ngeleka','Shaetonimwe','Nandjala','Haufiku'];
const towns = ['Windhoek','Walvis Bay','Swakopmund','Oshakati','Ongwediva','Rundu','Katima Mulilo','Otjiwarongo','Gobabis','Keetmanshoop','Luderitz','Outjo','Karibib','Rehoboth','Mariental'];
const benefitKinds: BenefitRecord['type'][] = ['Pension','Retirement Fund','Life Insurance','Funeral Benefit','Employee Benefit','Death Benefit'];

function hashValue(input: string): number {
  let h = 2166136261;
  for (let i = 0; i < input.length; i += 1) {
    h = Math.imul(h ^ input.charCodeAt(i), 16777619);
  }
  return h >>> 0;
}

function mulberry32(seed: number) {
  let a = seed >>> 0;
  return function next() {
    a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function isoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function matchDiscoveryDate(record: { id: string; dateJoined: string }): string {
  const joinedAt = new Date(`${record.dateJoined}T00:00:00.000Z`).getTime();
  const asOf = new Date(`${AS_OF_DATE}T00:00:00.000Z`).getTime();
  const availableDays = Math.floor((asOf - joinedAt) / 86_400_000);
  const offset = hashValue(`${record.id}:discovery`) % (availableDays + 1);
  return isoDate(new Date(joinedAt + offset * 86_400_000));
}

function timestampAfter(date: string, days: number, hour: number): string {
  const timestamp = new Date(`${date}T00:00:00.000Z`);
  timestamp.setUTCDate(timestamp.getUTCDate() + days);
  timestamp.setUTCHours(hour, 0, 0, 0);
  return timestamp.toISOString();
}

function buildHistoricalClaims(matches: MatchRecord[]): Claim[] {
  const generated: Claim[] = [];
  const asOf = new Date(`${AS_OF_DATE}T00:00:00.000Z`).getTime();
  let sequence = 1;
  const stateSequence: Claim['state'][] = [
    'SUBMITTED',
    'IDENTITY_REVIEW',
    'EVIDENCE_REVIEW',
    'INSTITUTION_REVIEW',
    'APPROVED',
    'CLOSED',
    'REJECTED',
    'MORE_INFORMATION_REQUIRED',
    'RESUBMITTED',
    'APPEAL',
  ];
  const stepsByState: Record<Claim['state'], Claim['state'][]> = {
    DRAFT: ['DRAFT'],
    SUBMITTED: ['SUBMITTED'],
    IDENTITY_REVIEW: ['SUBMITTED', 'IDENTITY_REVIEW'],
    EVIDENCE_REVIEW: ['SUBMITTED', 'IDENTITY_REVIEW', 'EVIDENCE_REVIEW'],
    INSTITUTION_REVIEW: ['SUBMITTED', 'IDENTITY_REVIEW', 'EVIDENCE_REVIEW', 'INSTITUTION_REVIEW'],
    MORE_INFORMATION_REQUIRED: ['SUBMITTED', 'IDENTITY_REVIEW', 'MORE_INFORMATION_REQUIRED'],
    RESUBMITTED: ['SUBMITTED', 'IDENTITY_REVIEW', 'MORE_INFORMATION_REQUIRED', 'RESUBMITTED'],
    APPROVED: ['SUBMITTED', 'IDENTITY_REVIEW', 'EVIDENCE_REVIEW', 'INSTITUTION_REVIEW', 'APPROVED'],
    REJECTED: ['SUBMITTED', 'IDENTITY_REVIEW', 'REJECTED'],
    APPEAL: ['SUBMITTED', 'IDENTITY_REVIEW', 'REJECTED', 'APPEAL'],
    CLOSED: ['SUBMITTED', 'IDENTITY_REVIEW', 'EVIDENCE_REVIEW', 'INSTITUTION_REVIEW', 'APPROVED', 'CLOSED'],
  };
  const labels: Record<Claim['state'], string> = {
    DRAFT: 'Claim drafted',
    SUBMITTED: 'Claim submitted',
    IDENTITY_REVIEW: 'Identity review',
    EVIDENCE_REVIEW: 'Evidence review',
    INSTITUTION_REVIEW: 'Institution review',
    MORE_INFORMATION_REQUIRED: 'More information requested',
    RESUBMITTED: 'Claim resubmitted',
    APPROVED: 'Claim approved',
    REJECTED: 'Claim rejected',
    APPEAL: 'Appeal opened',
    CLOSED: 'Case closed',
  };
  const usedMatchIds = new Set<string>();
  const addClaim = (match: MatchRecord, submittedDate: string, state: Claim['state']) => {
    const stateSteps = stepsByState[state];
    const timeline = stateSteps.map((step, stepIndex) => ({
      id: `HTL-${sequence}-${stepIndex + 1}`,
      timestamp: timestampAfter(submittedDate, stepIndex * 2, 9 + (stepIndex % 8)),
      label: labels[step],
      description: `${labels[step]} in the synthetic local workspace.`,
      completed: stepIndex < stateSteps.length - 1,
      current: stepIndex === stateSteps.length - 1,
    }));
    const submittedAt = timeline[0].timestamp;
    const updatedAt = timeline[timeline.length - 1].timestamp;
    const claimYear = submittedDate.slice(0, 4);

    generated.push({
      id: `OWF-HIST-${claimYear}-${String(sequence).padStart(6, '0')}`,
      matchId: match.id,
      beneficiaryId: match.beneficiaryId,
      beneficiaryName: match.beneficiaryName,
      benefitType: match.benefitType,
      institutionId: match.institutionId,
      institutionName: match.institutionName,
      referenceNumber: `SYN-${match.institutionId.toUpperCase()}-${String(sequence).padStart(6, '0')}`,
      state,
      potentialValue: match.potentialValue,
      submittedAt,
      updatedAt,
      amount: match.potentialValue,
      createdAt: submittedAt,
      documents: [],
      timeline,
      notes: 'Fictional historical workflow record.',
    });
    usedMatchIds.add(match.id);
    sequence += 1;
  };

  matches.forEach((match, index) => {
    if (index % 40 !== 7) return;

    const identifiedAt = new Date(`${match.dateIdentified}T00:00:00.000Z`).getTime();
    const daysAvailable = Math.floor((asOf - identifiedAt) / 86_400_000);
    if (daysAvailable < 14) return;
    const submissionWindow = Math.max(1, daysAvailable - 13);
    const submittedDate = isoDate(new Date(identifiedAt + (hashValue(`${match.id}:claim`) % submissionWindow) * 86_400_000));
    const state = stateSequence[hashValue(`${match.id}:claim-state`) % stateSequence.length];
    addClaim(match, submittedDate, state);
  });

  const resolvedQuarterStarts = [
    '2025-01-01', '2025-04-01', '2025-07-01', '2025-10-01',
    '2026-01-01', '2026-04-01', '2026-07-01', '2026-10-01',
  ];
  for (const quarterStart of resolvedQuarterStarts) {
    const match = matches.find((candidate) =>
      !usedMatchIds.has(candidate.id) && candidate.dateIdentified <= quarterStart
    );
    if (!match) {
      throw new Error(`Unable to seed a resolved claim for quarter ${quarterStart}.`);
    }
    const submittedDate = isoDate(new Date(new Date(`${quarterStart}T00:00:00.000Z`).getTime() + 2 * 86_400_000));
    addClaim(match, submittedDate, 'APPROVED');
  }

  for (const [month, state] of [
    ['2026-05', 'EVIDENCE_REVIEW'],
    ['2026-06', 'MORE_INFORMATION_REQUIRED'],
    ['2026-08', 'SUBMITTED'],
    ['2026-09', 'RESUBMITTED'],
  ] as const) {
    const submittedDate = `${month}-02`;
    const match = matches.find((candidate) =>
      !usedMatchIds.has(candidate.id) && candidate.dateIdentified <= submittedDate
    );
    if (!match) {
      throw new Error(`Unable to seed a claim volume record for ${month}.`);
    }
    addClaim(match, submittedDate, state);
  }

  const institutionIds = Array.from(new Set(matches.map((match) => match.institutionId)));
  const pendingStates: Claim['state'][] = [
    'SUBMITTED',
    'IDENTITY_REVIEW',
    'EVIDENCE_REVIEW',
    'INSTITUTION_REVIEW',
    'MORE_INFORMATION_REQUIRED',
    'RESUBMITTED',
    'APPEAL',
  ];
  institutionIds.forEach((institutionId, institutionIndex) => {
    const institutionMatches = matches.filter((match) => match.institutionId === institutionId);
    const institutionClaims = generated.filter((claim) => claim.institutionId === institutionId);
    const pendingClaimExists = institutionClaims.some((claim) => !['APPROVED', 'REJECTED', 'CLOSED'].includes(claim.state));
    const resolvedClaimExists = institutionClaims.some((claim) => ['APPROVED', 'REJECTED', 'CLOSED'].includes(claim.state));

    if (!pendingClaimExists) {
      const month = String((institutionIndex % 9) + 1).padStart(2, '0');
      const plannedDate = `2026-${month}-05`;
      const match = institutionMatches.find((candidate) =>
        !usedMatchIds.has(candidate.id) && candidate.dateIdentified <= plannedDate
      );
      if (!match) {
        throw new Error(`Unable to seed a pending review for institution ${institutionId}.`);
      }
      addClaim(match, plannedDate, pendingStates[institutionIndex % pendingStates.length]);
    }

    if (!resolvedClaimExists) {
      const quarterStart = resolvedQuarterStarts[institutionIndex % resolvedQuarterStarts.length];
      const quarterEnd = new Date(`${quarterStart}T00:00:00.000Z`);
      quarterEnd.setUTCMonth(quarterEnd.getUTCMonth() + 3);
      quarterEnd.setUTCDate(quarterEnd.getUTCDate() - 10);
      const latestAllowed = new Date(`${AS_OF_DATE}T00:00:00.000Z`);
      latestAllowed.setUTCDate(latestAllowed.getUTCDate() - 8);
      const latestSubmissionDate = isoDate(new Date(Math.min(quarterEnd.getTime(), latestAllowed.getTime())));
      const match = institutionMatches.find((candidate) =>
        !usedMatchIds.has(candidate.id) && candidate.dateIdentified <= latestSubmissionDate
      );
      if (!match) {
        throw new Error(`Unable to seed a resolved claim for institution ${institutionId}.`);
      }
      const earliestSubmissionDate = `${quarterStart.slice(0, 4)}-${quarterStart.slice(5, 7)}-03`;
      const submittedDate = match.dateIdentified > earliestSubmissionDate
        ? match.dateIdentified
        : earliestSubmissionDate;
      addClaim(match, submittedDate, 'APPROVED');
    }
  });

  return generated;
}

function makeNationalId(dob: string, index: number): string {
  const [y, m, d] = dob.split('-').map(Number);
  const yy = String(y).slice(-2).padStart(2, '0');
  const mm = String(m).padStart(2, '0');
  const dd = String(d).padStart(2, '0');
  const seq = String((index % 9000) + 1000);
  return `${yy}${mm}${dd}${seq}8`;
}

function makeEmail(first: string, last: string, index: number): string {
  return `${first.toLowerCase()}.${last.toLowerCase()}${index % 7}@example.org`;
}

function makePhone(index: number): string {
  const prefix = ['+264 81', '+264 82', '+264 85'][index % 3];
  const tail = String((index * 137) % 10000000).padStart(7, '0');
  return `${prefix} ${tail.slice(0, 3)} ${tail.slice(3)}`;
}

function buildProfiles(): BeneficiaryProfile[] {
  const profiles: BeneficiaryProfile[] = [];
  for (let i = 0; i < 12000; i += 1) {
    const firstName = firstNames[i % firstNames.length];
    const lastName = lastNames[(i * 3) % lastNames.length];
    const yearBase = 1940 + (i % 60);
    const month = 1 + ((i * 7) % 12);
    const day = 1 + ((i * 13) % 28);
    const dob = `${yearBase}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    const nationalId = i === 0 ? '04011400076' : makeNationalId(dob, i);
    profiles.push({
      firstName,
      lastName,
      dateOfBirth: i === 0 ? '2004-01-14' : dob,
      nationalId,
      previousName: '',
      phone: makePhone(i),
      email: makeEmail(firstName, lastName, i),
      region: towns[i % towns.length],
      employmentHistory: i === 0
        ? [
            { id: `emp-${i}-1`, employer: 'Government of Namibia', employeeNumber: `GOV-${i + 1000}`, startDate: '2022-01', endDate: '2024-12' },
            { id: `emp-${i}-2`, employer: 'Namibia Port Authority', employeeNumber: `NPA-${i + 2000}`, startDate: '2025-01', endDate: '' },
          ]
        : [
            { id: `emp-${i}-1`, employer: 'Government of Namibia', employeeNumber: `GOV-${i + 1000}`, startDate: '2000-01', endDate: '2015-12' },
            { id: `emp-${i}-2`, employer: 'Namibia Port Authority', employeeNumber: `NPA-${i + 2000}`, startDate: '2016-01', endDate: '' },
          ],
      consentGiven: i === 0,
      consentDate: i === 0 ? '2026-09-01' : null,
      profileCompletion: 86,
      verificationStatus: i === 0 ? 'verified' : 'pending',
    });
  }
  return profiles;
}

function buildInstitutions(): Institution[] {
  return institutionCatalog.map((entry) => ({
    id: entry.id,
    name: entry.name,
    type: entry.type,
    region: entry.region,
    matches: 0,
    claims: 0,
    pendingReview: 0,
    resolved: 0,
    avgResolutionDays: 0,
    demo: true,
    short: entry.short,
  }));
}

function buildAccountRecords(): Array<{
  id: string;
  beneficiaryId: string;
  institutionId: string;
  institutionName: string;
  reference: string;
  benefitType: BenefitRecord['type'];
  amount: number;
  status: 'active' | 'dormant' | 'unclaimed';
  region: string;
  dateJoined: string;
  dateExited: string | null;
}> {
  const institutions = buildInstitutions();
  const profiles = buildProfiles();
  const records: Array<{ id: string; beneficiaryId: string; institutionId: string; institutionName: string; reference: string; benefitType: BenefitRecord['type']; amount: number; status: 'active' | 'dormant' | 'unclaimed'; region: string; dateJoined: string; dateExited: string | null; }> = [];
  const rng = mulberry32(hashValue('owafind-synthetic-workspace-2026'));
  let remainingTarget = TOTAL_UNCLAIMED_BALANCE;
  let unclaimedCount = 0;

  institutions.forEach((institution, institutionIndex) => {
    const count = 900 + institutionIndex * 32;
    for (let idx = 0; idx < count; idx += 1) {
      const profileIndex = idx === 0 ? 0 : (institutionIndex * 29 + idx * 13) % profiles.length;
      const owner = profiles[profileIndex];
      const statusRoll = rng();
      let status: 'active' | 'dormant' | 'unclaimed';
      if (remainingTarget > 0 && unclaimedCount < 360 && statusRoll > 0.76) {
        status = 'unclaimed';
        unclaimedCount += 1;
      } else if (statusRoll > 0.42) {
        status = 'dormant';
      } else {
        status = 'active';
      }

      let amount = 12000 + Math.floor(rng() * 320000);
      if (status === 'unclaimed') {
        const nextAmount = Math.min(remainingTarget, Math.max(25000, amount));
        amount = nextAmount;
        remainingTarget = Math.max(0, remainingTarget - nextAmount);
      }

      const joinDate = new Date(2016 + (idx % 10), 1 + (idx % 11), 10 + (idx % 18));
      const nominalExitDate = new Date(2021 + (idx % 5), 2 + (idx % 6), 12 + (idx % 19));
      const exitDate = idx % 7 === 0 ? new Date(Math.max(nominalExitDate.getTime(), joinDate.getTime() + 30 * 24 * 60 * 60 * 1000)) : null;

      records.push({
        id: `ACC-${institution.id}-${idx + 1}`,
        beneficiaryId: owner.nationalId,
        institutionId: institution.id,
        institutionName: institution.name,
        reference: `${institution.short}-${String(idx + 1).padStart(6, '0')}`,
        benefitType: benefitKinds[(institutionIndex + idx) % benefitKinds.length],
        amount,
        status,
        region: owner.region,
        dateJoined: isoDate(joinDate),
        dateExited: exitDate ? isoDate(exitDate) : null,
      });
    }
  });

  const lastUnclaimed = records.filter((record) => record.status === 'unclaimed');
  const unclaimedSum = lastUnclaimed.reduce((sum, record) => sum + record.amount, 0);
  if (lastUnclaimed.length > 0 && unclaimedSum !== TOTAL_UNCLAIMED_BALANCE) {
    lastUnclaimed[0].amount += TOTAL_UNCLAIMED_BALANCE - unclaimedSum;
  }

  return records;
}

export function buildSyntheticWorkspace(): SyntheticWorkspace {
  const institutions = buildInstitutions();
  const profiles = buildProfiles();
  const accountRecords = buildAccountRecords();

  const benefitRecords: BenefitRecord[] = accountRecords.map((record) => ({
    id: record.id,
    type: record.benefitType,
    institutionId: record.institutionId,
    institutionName: record.institutionName,
    reference: record.reference,
    approximateValue: record.amount,
    region: record.region,
    status: record.status,
    beneficiaryId: record.beneficiaryId,
    dateJoined: record.dateJoined,
    dateExited: record.dateExited,
  }));

  const profilesById = new Map(profiles.map((profile) => [profile.nationalId, profile]));
  const matches: MatchRecord[] = benefitRecords.map((record, index) => {
    const owner = profilesById.get(record.beneficiaryId ?? '');
    if (!owner) {
      throw new Error(`Synthetic account ${record.id} has no matching beneficiary profile.`);
    }
    return {
      id: `MATCH-${index + 1}`,
      beneficiaryId: owner.nationalId,
      beneficiaryName: `${owner.firstName} ${owner.lastName}`,
      benefitType: record.type,
      institutionId: record.institutionId,
      institutionName: record.institutionName,
      institutionReference: record.reference,
      potentialValue: record.approximateValue,
      confidence: 62 + (index % 35),
      status: index % 3 === 0 ? 'green' : index % 3 === 1 ? 'amber' : 'red',
      signals: [
        { label: 'Name', strength: 'strong' },
        { label: 'Date of Birth', strength: 'exact' },
        { label: 'Employment History', strength: 'partial' },
      ],
      employmentPeriod: '2016-2026',
      dateIdentified: index < 2
        ? '2026-08-01'
        : matchDiscoveryDate({ id: record.id, dateJoined: record.dateJoined ?? AS_OF_DATE }),
      region: record.region,
    };
  });

  const claims: Claim[] = [
    {
      id: 'OWF-2026-00001',
      matchId: 'MATCH-1',
      beneficiaryId: '04011400076',
      beneficiaryName: 'Josua Uuyuni',
      benefitType: 'Retirement Fund',
      institutionId: 'gipf',
      institutionName: 'Government Institutions Pension Fund (GIPF)',
      referenceNumber: 'GIPF-000001',
      state: 'EVIDENCE_REVIEW',
      potentialValue: 125000,
      submittedAt: '2026-09-15T09:00:00.000Z',
      updatedAt: '2026-10-02T14:00:00.000Z',
      amount: 125000,
      createdAt: '2026-09-15T09:00:00.000Z',
      documents: [
        { id: 'DOC-001', name: 'id-document.pdf', type: 'ID Document', size: 245000, uploadStatus: 'verified', uploadedAt: '2026-09-15T09:05:00.000Z', verificationStatus: 'verified' },
      ],
      timeline: [
        { id: 'TL-01', timestamp: '2026-09-15T09:00:00.000Z', label: 'Claim Submitted', description: 'Claim was submitted.', completed: true, current: false },
        { id: 'TL-02', timestamp: '2026-09-18T10:00:00.000Z', label: 'Identity Review', description: 'Identity checks completed.', completed: true, current: false },
        { id: 'TL-03', timestamp: '2026-10-02T14:00:00.000Z', label: 'Evidence Review', description: 'Evidence is under review.', completed: false, current: true },
      ],
    },
    {
      id: 'OWF-2026-00002',
      matchId: 'MATCH-2',
      beneficiaryId: '04011400076',
      beneficiaryName: 'Josua Uuyuni',
      benefitType: 'Pension',
      institutionId: 'namcor-pension',
      institutionName: 'Namcor Pension Fund',
      referenceNumber: 'NAMCOR-000002',
      state: 'SUBMITTED',
      potentialValue: 54000,
      submittedAt: '2026-10-09T08:00:00.000Z',
      updatedAt: '2026-10-09T08:00:00.000Z',
      amount: 54000,
      createdAt: '2026-10-09T08:00:00.000Z',
      documents: [],
      timeline: [
        { id: 'TL-11', timestamp: '2026-10-09T08:00:00.000Z', label: 'Claim Submitted', description: 'Claim was submitted.', completed: true, current: true },
      ],
    },
  ];

  const secondMatch = matches[1];
  if (!secondMatch) {
    throw new Error('Synthetic workspace requires a second match for its seeded claim example.');
  }
  Object.assign(claims[1], {
    beneficiaryId: secondMatch.beneficiaryId,
    beneficiaryName: secondMatch.beneficiaryName,
    benefitType: secondMatch.benefitType,
    institutionId: secondMatch.institutionId,
    institutionName: secondMatch.institutionName,
    referenceNumber: secondMatch.institutionReference,
    potentialValue: secondMatch.potentialValue,
    amount: secondMatch.potentialValue,
  });
  claims.push(...buildHistoricalClaims(matches));

  const notifications: Notification[] = [
    { id: 'NT-001', title: 'Potential benefit identified', message: 'A potential retirement benefit was matched against your record.', type: 'match', read: false, createdAt: '2026-10-02T10:00:00.000Z', link: '/app/matches' },
    { id: 'NT-002', title: 'Evidence review', message: 'Your claim OWF-2026-00001 is under evidence review.', type: 'claim', read: false, createdAt: '2026-10-02T12:00:00.000Z', link: '/app/claims/OWF-2026-00001' },
    { id: 'NT-003', title: 'Document reminder', message: 'A supporting document is still pending.', type: 'document', read: true, createdAt: '2026-10-03T08:00:00.000Z', link: '/app/claims/OWF-2026-00001' },
  ];

  const riskAlerts: RiskAlert[] = [
    { id: 'RA-001', type: 'multiple_beneficiary', severity: 'medium', description: 'Multiple synthetic accounts are linked to the same identity in the benefit registry.', createdAt: '2026-10-03T10:00:00.000Z', status: 'open' },
    { id: 'RA-002', type: 'duplicate_identity', severity: 'low', description: 'Two claim references show overlapping identifiers in the same synthetic period.', createdAt: '2026-10-04T11:00:00.000Z', status: 'reviewing' },
  ];

  const auditEvents: AuditEvent[] = [
    { id: 'AE-001', timestamp: '2026-10-02T09:00:00.000Z', actor: 'Synthetic workspace', action: 'Data initialised', target: 'workspace-seed', details: 'Synthetic local workspace loaded for the current browser session.' },
    { id: 'AE-002', timestamp: '2026-10-02T11:00:00.000Z', actor: 'Claims Officer', action: 'Reviewed claim', target: 'OWF-2026-00001', details: 'Evidence review started for a synthetic retirement claim.' },
  ];

  const faqs: FAQ[] = [
    { id: 'FAQ-1', question: 'What is the synthetic workspace?', answer: 'This local workspace is a fictional dataset for prototyping in the browser. It does not connect to real institutions or live services.', category: 'General' },
    { id: 'FAQ-2', question: 'Are the records real?', answer: 'No. All records, claims, institutions, balances, and notifications are fictional synthetic data generated for this prototype only.', category: 'Data' },
  ];

  const supportTickets: SupportTicket[] = [
    { id: 'SUP-001', subject: 'Local workspace question', category: 'General', status: 'open', createdAt: '2026-10-09T08:00:00.000Z', updatedAt: '2026-10-09T08:00:00.000Z', messages: [{ author: 'User', message: 'How do I reset the synthetic workspace?', timestamp: '2026-10-09T08:00:00.000Z' }] },
  ];

  return {
    asOfDate: AS_OF_DATE,
    institutions,
    profiles,
    benefitRecords,
    matches,
    claims,
    notifications,
    riskAlerts,
    auditEvents,
    faqs,
    supportTickets,
    documents: [],
    totalUnclaimedBalance: TOTAL_UNCLAIMED_BALANCE,
  };
}

export function validateSyntheticWorkspace(workspace: SyntheticWorkspace): boolean {
  const unclaimedSum = workspace.benefitRecords.filter((record) => record.status === 'unclaimed').reduce((sum, record) => sum + record.approximateValue, 0);
  const uniqueIds = new Set(workspace.benefitRecords.map((record) => record.id));
  const hasNegativeBalance = workspace.benefitRecords.some((record) => record.approximateValue < 0);
  return unclaimedSum === TOTAL_UNCLAIMED_BALANCE && !hasNegativeBalance && uniqueIds.size === workspace.benefitRecords.length;
}

export const syntheticWorkspace = buildSyntheticWorkspace();
export default syntheticWorkspace;