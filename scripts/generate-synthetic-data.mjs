/**
 * Synthetic data generator for OwaFind local workspace
 * Generates deterministic synthetic data for local development/testing
 */

import crypto from 'crypto';
import fs from 'fs';

// Deterministic random seed
const SEED = 'owafind-synthetic-data-2026';

// Create deterministic random number generator
function createDeterministicRng(seed) {
  let state = crypto.createHash('sha256').update(seed).digest();
  let pos = 0;

  return function(max) {
    if (pos + 4 > state.length) {
      state = crypto.createHash('sha256').update(state).digest();
      pos = 0;
    }

    const value = state.readUInt32LE(pos);
    pos += 4;
    return value % max;
  };
}

// Initialize RNG
const rng = createDeterministicRng(SEED);

// Helper functions
function deterministicChoice(array, seedModifier = '') {
  const index = rng(`${SEED}:${seedModifier}`) % array.length;
  return array[index];
}

function deterministicRange(min, max, seedModifier = '') {
  return min + (rng(`${SEED}:${seedModifier}`) % (max - min + 1));
}

// Namibian towns and regions
const NAMIBIAN_REGIONS = [
  'Windhoek', 'Walvis Bay', 'Swakopmund', 'Oshakati', 'Ongwediva',
  'Rundu', 'Katima Mulilo', 'Otjiwarongo', 'Gobabis', 'Keetmanshoop',
  'Luderitz', 'Tsumeh', 'Outjo', 'Karibib', 'Omaruru', 'Otavi',
  'Tsumeb', 'Okahandja', 'Rehoboth', 'Mariental', 'Karibib'
];

// Benefit types
const BENEFIT_TYPES = [
  'Pension',
  'Retirement Fund',
  'Life Insurance',
  'Funeral Benefit',
  'Employee Benefit',
  'Death Benefit'
];

// Statuses
const BENEFIT_STATUSES = ['active', 'dormant', 'unclaimed'];
const CLAIM_STATUSES = [
  'DRAFT', 'SUBMITTED', 'IDENTITY_REVIEW', 'EVIDENCE_REVIEW',
  'INSTITUTION_REVIEW', 'MORE_INFORMATION_REQUIRED', 'RESUBMITTED',
  'APPROVED', 'REJECTED', 'APPEAL', 'CLOSED'
];

// Match statuses
const MATCH_STATUSES = ['green', 'amber', 'red'];

// Signal strengths
const SIGNAL_STRENGTHS = ['exact', 'strong', 'partial', 'weak', 'none'];

// Institution types
const INSTITUTION_TYPES = ['Pension Fund', 'Insurer', 'Employer', 'Administrator'];

// Document types
const DOCUMENT_TYPES = [
  'ID Document',
  'Proof of Employment',
  'Marriage Certificate',
  'Death Certificate',
  'Beneficiary Documentation',
  'Other Supporting Evidence'
];

// Notification types
const NOTIFICATION_TYPES = ['match', 'document', 'claim', 'system'];

// Risk alert types
const RISK_ALERT_TYPES = [
  'duplicate_identity',
  'reused_document',
  'multiple_beneficiary',
  'suspicious_pattern'
];

// Risk alert severities
const RISK_ALERT_SEVERITIES = ['low', 'medium', 'high'];

// Risk alert statuses
const RISK_ALERT_STATUSES = ['open', 'reviewing', 'resolved'];

// Audit event actions
const AUDIT_EVENT_ACTIONS = [
  'Submitted claim', 'Uploaded document', 'Verified document',
  'Reviewed claim', 'Updated claim status', 'Identity verification completed',
  'State transition', 'Risk alert generated', 'Support ticket created'
];

// Generate deterministic ID
function generateId(prefix, seedModifier = '') {
  const hash = crypto.createHash('md5').update(`${SEED}:${prefix}:${seedModifier}`).digest();
  return hash.toString('hex').substring(0, 8);
}

// Generate deterministic Namibian-style name
function generateNamibianName(seedModifier = '') {
  const firstNames = [
    'Maria', 'Pendukeni', 'Gideon', 'Linea', 'Kornelius', 'Victoria',
    'Fanuel', 'Selma', 'Barney', 'Ndeshi', 'Mateus', 'Frieda', 'Kauna',
    'Ester', 'Johannes', 'Rosalia', 'Petrus', 'Magrieta', 'Immanuel',
    'Lukas', 'Abraham', 'Sarah', 'David', 'Leah', 'Rachel', 'Jacob',
    'Benjamin', 'Joseph', 'Samuel', 'Daniel', 'Matthew', 'Mark', 'Luke',
    'John', 'Mary', 'Anna', 'Ruth', 'Esther', 'Deborah', 'Rebecca'
  ];

  const lastNames = [
    'Doe', 'Hamukwaya', 'Nepembe', 'Shilongo', 'Shipepe', 'Amukwaya',
    'Tjirera', 'Amutenya', 'Haufiku', 'Andreas', 'Sheya', 'Namwandi',
    'Shikwambi', 'Nangolo', 'Gawanas', 'Muvangua', 'Ndjarakana', 'Hoveka',
    'Tjipuka', 'Mutinga', 'Nankudhu', 'Shaningwa', 'Amadhila', 'Amukoshi',
    'Ngeleka', 'Shilongo', 'Shaetonimwe', 'Nandjala', 'Haipinge', 'Haufiku'
  ];

  const firstName = deterministicChoice(firstNames, `first:${seedModifier}`);
  const lastName = deterministicChoice(lastNames, `last:${seedModifier}`);

  return { firstName, lastName };
}

// Generate deterministic national ID (Namibian format: YYMMDDSSSSC)
function generateNationalId(dateOfBirth, seedModifier = '') {
  const [year, month, day] = dateOfBirth.split('-');
  const yearSuffix = year.substring(2, 4); // Last 2 digits of year
  const paddedMonth = month.padStart(2, '0');
  const paddedDay = day.padStart(2, '0');

  // Generate sequence number and check digit
  const sequence = String(rng(10000, `seq:${seedModifier}`)).padStart(4, '0');
  const checkDigit = String(rng(10, `check:${seedModifier}`));

  return `${yearSuffix}${paddedMonth}${paddedDay}${sequence}${checkDigit}`;
}

// Generate deterministic phone number
function generatePhoneNumber(seedModifier = '') {
  const prefixes = ['+264 81', '+264 85', '+264 82'];
  const prefix = deterministicChoice(prefixes, `phone_prefix:${seedModifier}`);
  const number = String(rng(1000000, `phone_num:${seedModifier}`)).padStart(7, '0');
  return `${prefix} ${number.substring(0, 3)} ${number.substring(3)}`;
}

// Generate deterministic email
function generateEmail(firstName, lastName, seedModifier = '') {
  const domains = ['example.com', 'example.org', 'test.com'];
  const domain = deterministicChoice(domains, `email_domain:${seedModifier}`);
  const safeFirstName = (firstName || 'unknown').toLowerCase();
  const safeLastName = (lastName || 'user').toLowerCase();
  return `${safeFirstName}.${safeLastName}@${domain}`;
}

// Generate date within range
function generateDateInRange(startYear, endYear, seedModifier = '') {
  const startDate = new Date(`${startYear}-01-01`);
  const endDate = new Date(`${endYear}-12-31`);
  const timeDiff = endDate.getTime() - startDate.getTime();
  const randomTime = rng(timeDiff, `date:${seedModifier}`);
  const randomDate = new Date(startDate.getTime() + randomTime);

  return randomDate.toISOString().split('T')[0]; // YYYY-MM-DD format
}

// Generate institution data
function generateInstitutions(count = 35) {
  const institutions = [];

  // Base institution data from existing registry
  const baseInstitutions = [
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
    { id: 'old-mutual-namibia', name: 'Old Mutual Namibia', short: 'Old Mutual', type: 'Insurer', region: 'Windhoek' }
  ];

  // Add base institutions
  baseInstitutions.forEach((inst, index) => {
    institutions.push({
      id: inst.id,
      name: inst.name,
      type: inst.type,
      region: inst.region,
      matches: deterministicRange(100, 2000, `inst_matches_${index}`),
      claims: deterministicRange(20, 500, `inst_claims_${index}`),
      pendingReview: deterministicRange(5, 100, `inst_pending_${index}`),
      resolved: deterministicRange(10, 400, `inst_resolved_${index}`),
      avgResolutionDays: deterministicRange(10, 30, `inst_resolution_days_${index}`),
      demo: true,
      short: inst.short
    });
  });

  // Generate additional institutions if needed
  while (institutions.length < count) {
    const index = institutions.length;
    const region = deterministicChoice(NAMIBIAN_REGIONS, `inst_region_${index}`);
    const type = deterministicChoice(INSTITUTION_TYPES, `inst_type_${index}`);
    const shortName = `INST${String(index + 1).padStart(3, '0')}`;

    institutions.push({
      id: `inst_${index + 1}`,
      name: `${type} ${region} ${shortName}`,
      type: type,
      region: region,
      matches: deterministicRange(50, 500, `inst_matches_${index}`),
      claims: deterministicRange(10, 100, `inst_claims_${index}`),
      pendingReview: deterministicRange(2, 20, `inst_pending_${index}`),
      resolved: deterministicRange(5, 80, `inst_resolved_${index}`),
      avgResolutionDays: deterministicRange(8, 25, `inst_resolution_days_${index}`),
      demo: true,
      short: shortName
    });
  }

  return institutions.slice(0, count);
}

// Generate beneficiary profiles
function generateBeneficiaryProfiles(count = 12000) {
  const profiles = [];

  for (let i = 0; i < count; i++) {
    const { firstName, lastName } = generateNamibianName(`profile_${i}`);
    const dateOfBirth = generateDateInRange(1940, 2008, `dob_${i}`); // Ages 18-86
    const nationalId = generateNationalId(dateOfBirth, `nid_${i}`);
    const phone = generatePhoneNumber(`phone_${i}`);
    const email = generateEmail(firstName, lastName, `email_${i}`);
    const region = deterministicChoice(NAMIBIAN_REGIONS, `region_${i}`);

    // Generate employment history (0-3 jobs)
    const employmentCount = rng(4, `emp_count_${i}`); // 0-3
    const employmentHistory = [];

    for (let j = 0; j < employmentCount; j++) {
      const startYear = deterministicRange(1970, 2020, `emp_start_year_${i}_${j}`);
      const startDate = generateDateInRange(startYear, startYear, `emp_start_date_${i}_${j}`);
      const endYear = deterministicRange(parseInt(startYear) + 1, 2023, `emp_end_year_${i}_${j}`);
      const endDate = generateDateInRange(endYear, endYear, `emp_end_date_${i}_${j}`);

      employmentHistory.push({
        id: `emp_${i}_${j}`,
        employer: deterministicChoice([
          'NamPower', 'TransNamib', 'Water Corp', 'Telecom Namibia',
          'Air Namibia', 'Namibia Breweries', 'Fishcor', 'Namibian Mills',
          'Government', 'Ministry of Education', 'Ministry of Health',
            'City of Windhoek', 'Walvis Bay Municipality', 'Oshakati Town Council'
        ], `employer_${i}_${j}`),
        employeeNumber: `EMP${String(rng(9999, `emp_num_${i}_${j}`)).padStart(4, '0')}`,
        startDate: startDate,
        endDate: j === employmentCount - 1 && rng(3, `current_job_${i}_${j}`) > 1 ? null : endDate // Null means current job
      });
    }

    // Calculate profile completion based on filled fields
    let completion = 60; // Base completion
    if (firstName && lastName) completion += 10;
    if (dateOfBirth) completion += 10;
    if (nationalId) completion += 10;
    if (phone) completion += 5;
    if (email) completion += 5;

    profiles.push({
      firstName,
      lastName,
      dateOfBirth,
      nationalId,
      previousName: rng(4, `has_prev_name_${i}`) > 2 ? `${deterministicChoice(['', 'Previous Name'])}` : '',
      phone,
      email,
      region,
      employmentHistory,
      consentGiven: rng(3, `consent_${i}`) > 1, // 66% chance
      consentDate: rng(3, `consent_${i}`) > 1 ? generateDateInRange(2020, 2026, `consent_date_${i}`) : null,
      profileCompletion: Math.min(100, completion),
      verificationStatus: rng(3, `verification_${i}`) > 1 ? 'verified' : 'unverified' // 66% verified
    });
  }

  return profiles;
}

// Generate benefit records
function generateBenefitRecords(profiles, institutions, targetUnclaimedBalance = 218700000) {
  const benefitRecords = [];
  let unclaimedSum = 0;
  const recordsPerProfile = 2; // Average 2 benefit records per person

  // Track which profiles have been used for benefit records to ensure distribution
  const profileUsage = Array(profiles.length).fill(0);

  // Generate benefit records until we reach target unclaimed balance
  // or we've created enough records
  let recordId = 1;
  let attempts = 0;
  const maxAttempts = 50000; // Prevent infinite loop

  while ((unclaimedSum < targetUnclaimedBalance || benefitRecords.length < profiles.length * recordsPerProfile) && attempts < maxAttempts) {
    attempts++;

    // Select a profile (weighted toward those with fewer records)
    const weightedIndices = profiles.map((_, index) => {
      const weight = Math.max(1, 5 - profileUsage[index]); // Higher weight for less used profiles
      return Array(weight).fill(index);
    }).flat();

    if (weightedIndices.length === 0) break;

    const profileIndex = deterministicChoice(weightedIndices, `profile_select_${recordId}`);
    profileUsage[profileIndex]++;

    const profile = profiles[profileIndex];
    const institution = deterministicChoice(institutions, `inst_select_${recordId}`) || institutions[0];
    const benefitType = deterministicChoice(BENEFIT_TYPES, `benefit_type_${recordId}`);

    // Generate benefit value (mostly smaller amounts, few large ones)
    let value;
    const valueRoll = rng(100, `value_roll_${recordId}`);
    if (valueRoll < 70) { // 70% chance of smaller amount
      value = deterministicRange(5000, 50000, `value_small_${recordId}`);
    } else if (valueRoll < 90) { // 20% chance of medium amount
      value = deterministicRange(50000, 200000, `value_medium_${recordId}`);
    } else { // 10% chance of larger amount
      value = deterministicRange(200000, 1000000, `value_large_${recordId}`);
    }

    // Determine status (weighted toward unclaimed to meet target)
    const statusRoll = rng(100, `status_roll_${recordId}`);
    let status;
    if (unclaimedSum < targetUnclaimedBalance * 0.8) { // Still need more unclaimed
      status = statusRoll < 60 ? 'unclaimed' : (statusRoll < 80 ? 'dormant' : 'active');
    } else if (unclaimedSum < targetUnclaimedBalance * 0.95) { // Getting close
      status = statusRoll < 40 ? 'unclaimed' : (statusRoll < 70 ? 'dormant' : 'active');
    } else { // Very close or over target
      status = statusRoll < 20 ? 'unclaimed' : (statusRoll < 50 ? 'dormant' : 'active');
    }

    // Adjust if we'd exceed target
    if (status === 'unclaimed' && unclaimedSum + value > targetUnclaimedBalance) {
      // Make it dormant instead to avoid exceeding target
      status = 'dormant';
    }

    if (status === 'unclaimed') {
      unclaimedSum += value;
    }

    benefitRecords.push({
      id: `br_${recordId}`,
      type: benefitType,
      institutionId: institution.id,
      institutionName: institution.name,
      reference: `${institution.short}-${String(recordId).padStart(6, '0')}`,
      approximateValue: value,
      region: institution.region,
      status: status
    });

    recordId++;
  }

  // If we're under target, adjust some records to be unclaimed
  if (unclaimedSum < targetUnclaimedBalance) {
    const needed = targetUnclaimedBalance - unclaimedSum;
    const recordsToUpgrade = Math.ceil(needed / 50000); // Assume ~50k average upgrade

    // Sort by value ascending to upgrade smaller records first
    const sortedRecords = [...benefitRecords].sort((a, b) => a.approximateValue - b.approximateValue);

    for (let i = 0; i < Math.min(recordsToUpgrade, sortedRecords.length); i++) {
      const record = sortedRecords[i];
      if (record.status === 'dormant' || record.status === 'active') {
        const oldValue = record.approximateValue;
        record.status = 'unclaimed';
        unclaimedSum += oldValue; // Add back the value since we're changing status
      }
    }
  }

  // If we're over target, adjust some records from unclaimed to dormant/active
  if (unclaimedSum > targetUnclaimedBalance) {
    const excess = unclaimedSum - targetUnclaimedBalance;
    const unclaimedRecords = benefitRecords.filter(r => r.status === 'unclaimed');

    // Sort by value descending to reduce larger records first
    const sortedUnclaimed = [...unclaimedRecords].sort((a, b) => b.approximateValue - a.approximateValue);

    let reduced = 0;
    for (const record of sortedUnclaimed) {
      if (reduced >= excess) break;

      if (record.approximateValue <= excess) {
        record.status = deterministicChoice(['dormant', 'active'], `downgrade_${record.id}`);
        reduced += record.approximateValue;
      } else if (excess > 0) {
        // Partially reduce this record's value
        const reduction = Math.min(excess, record.approximateValue - 1000); // Keep at least 1000
        record.approximateValue -= reduction;
        reduced += reduction;
      }
    }

    // Recalculate unclaimed sum
    unclaimedSum = benefitRecords
      .filter(r => r.status === 'unclaimed')
      .reduce((sum, r) => sum + r.approximateValue, 0);
  }

  // Final adjustment loop to get exact target
  while (unclaimedSum !== targetUnclaimedBalance) {
    const diff = targetUnclaimedBalance - unclaimedSum;

    if (diff > 0) {
      // Need more unclaimed - find a non-unclaimed record to convert
      const candidate = benefitRecords.find(r =>
        r.status !== 'unclaimed' &&
        r.approximateValue >= Math.abs(diff) &&
        rng(2, `adjust_up_${r.id}`) > 0 // 50% chance
      );

      if (candidate) {
        candidate.status = 'unclaimed';
        unclaimedSum += candidate.approximateValue;
      } else {
        // Find any non-unclaimed record and adjust its value
        const candidate = benefitRecords.find(r =>
          r.status !== 'unclaimed' &&
          r.approximateValue > 1000
        );

        if (candidate) {
          const adjustment = Math.min(Math.abs(diff), candidate.approximateValue - 1000);
          candidate.approximateValue += adjustment;
          unclaimedSum += adjustment;
          candidate.status = 'unclaimed';
        }
      }
    } else if (diff < 0) {
      // Need less unclaimed - find an unclaimed record to convert
      const candidate = benefitRecords.find(r =>
        r.status === 'unclaimed' &&
        r.approximateValue >= Math.abs(diff)
      );

      if (candidate) {
        candidate.status = deterministicChoice(['dormant', 'active'], `adjust_down_${candidate.id}`);
        unclaimedSum -= candidate.approximateValue;
      } else {
        // Find any unclaimed record and reduce its value
        const candidate = benefitRecords.find(r =>
          r.status === 'unclaimed' &&
          r.approximateValue > 1000
        );

        if (candidate) {
          const reduction = Math.min(Math.abs(diff), candidate.approximateValue - 1000);
          candidate.approximateValue -= reduction;
          unclaimedSum -= reduction;

          // Change status if value is now low enough
          if (candidate.approximateValue < 5000) {
            candidate.status = deterministicChoice(['dormant', 'active'], `status_change_${candidate.id}`);
          }
        }
      }
    }

    // Prevent infinite loop
    if (Math.abs(targetUnclaimedBalance - unclaimedSum) < 100) {
      break;
    }
  }

  return benefitRecords;
}

// Generate matches
function generateMatches(profiles, benefitRecords, matchCount = 18500) {
  const matches = [];

  // Create matches linking profiles to benefit records
  for (let i = 0; i < matchCount; i++) {
    const profileIndex = rng(profiles.length, `match_profile_${i}`);
    const profile = profiles[profileIndex];

    // Find benefit records for this profile's institutions
    const profileBenefitRecords = benefitRecords.filter(br =>
      // Simple heuristic: match by region or just pick random
      rng(2, `match_heuristic_${i}`) > 0
    );

    const benefitRecord = deterministicChoice(
      profileBenefitRecords.length > 0 ? profileBenefitRecords : benefitRecords,
      `match_benefit_${i}`
    );

    // Generate match-specific data
    const confidence = deterministicRange(30, 95, `confidence_${i}`);
    const status =
      confidence >= 80 ? 'green' :
      confidence >= 50 ? 'amber' : 'red';

    const signalCount = deterministicRange(2, 5, `signal_count_${i}`);
    const signals = [];
    const signalLabels = ['Name', 'Date of Birth', 'National ID', 'Employment History', 'Previous Name'];

    for (let j = 0; j < signalCount; j++) {
      const labelIndex = rng(signalLabels.length, `signal_label_${i}_${j}`);
      const strengthIndex = rng(SIGNAL_STRENGTHS.length, `signal_strength_${i}_${j}`);
      signals.push({
        label: signalLabels[labelIndex],
        strength: SIGNAL_STRENGTHS[strengthIndex]
      });
    }

    matches.push({
      id: `match_${i + 1}`,
      beneficiaryId: profile.nationalId,
      beneficiaryName: `${profile.firstName} ${profile.lastName}`,
      benefitType: benefitRecord.type,
      institutionId: benefitRecord.institutionId,
      institutionName: benefitRecord.institutionName,
      institutionReference: benefitRecord.reference,
      potentialValue: benefitRecord.approximateValue,
      confidence,
      status,
      signals,
      employmentPeriod: profile.employmentHistory.length > 0 ?
        `${profile.employmentHistory[0].startDate.slice(0, 7)}–${profile.employmentHistory[0].endDate?.slice(0, 7) || 'present'}` :
        undefined,
      dateIdentified: generateDateInRange(2020, 2026, `date_identified_${i}`),
      region: benefitRecord.region
    });
  }

  return matches;
}

// Generate claims
function generateClaims(matches, claimCount = 2000) {
  const claims = [];

  for (let i = 0; i < claimCount; i++) {
    const match = deterministicChoice(matches, `claim_match_${i}`);
    const claimStatus = deterministicChoice(CLAIM_STATUSES, `claim_status_${i}`);

    // Generate timeline based on claim status
    const timeline = [];
    const baseDate = new Date('2026-01-01');

    // Always start with claim submitted
    timeline.push({
      id: 't1',
      timestamp: generateDateInRange(2026, 2026, `claim_submitted_${i}`),
      label: 'Claim Submitted',
      description: 'Claim has been submitted to the pension fund.',
      completed: true,
      current: claimStatus === 'SUBMITTED'
    });

    // Add subsequent events based on status
    if (claimStatus !== 'SUBMITTED' && claimStatus !== 'DRAFT') {
      timeline.push({
        id: 't2',
        timestamp: generateDateInRange(2026, 2026, `identity_review_${i}`),
        label: 'Identity Verification',
        description: 'Your identity was verified successfully.',
        completed: true,
        current: claimStatus === 'IDENTITY_REVIEW'
      });
    }

    if (['EVIDENCE_REVIEW', 'INSTITUTION_REVIEW', 'APPROVED', 'REJECTED'].includes(claimStatus)) {
      timeline.push({
        id: 't3',
        timestamp: generateDateInRange(2026, 2026, `evidence_review_${i}`),
        label: 'Evidence Review',
        description: 'Your submitted documents are currently being reviewed.',
        completed: ['EVIDENCE_REVIEW', 'INSTITUTION_REVIEW', 'APPROVED', 'REJECTED'].includes(claimStatus),
        current: claimStatus === 'EVIDENCE_REVIEW'
      });
    }

    if (['INSTITUTION_REVIEW', 'APPROVED', 'REJECTED', 'APPEAL'].includes(claimStatus)) {
      timeline.push({
        id: 't4',
        timestamp: generateDateInRange(2026, 2026, `institution_review_${i}`),
        label: 'Institution Review',
        description: 'The pension fund is reviewing your claim.',
        completed: ['INSTITUTION_REVIEW', 'APPROVED', 'REJECTED', 'APPEAL'].includes(claimStatus),
        current: claimStatus === 'INSTITUTION_REVIEW'
      });
    }

    if (['APPROVED', 'REJECTED', 'APPEAL', 'CLOSED'].includes(claimStatus)) {
      timeline.push({
        id: 't5',
        timestamp: generateDateInRange(2026, 2026, `resolution_${i}`),
        label: 'Resolution',
        description: 'The pension fund has made a final decision on your claim.',
        completed: ['APPROVED', 'REJECTED', 'APPEAL', 'CLOSED'].includes(claimStatus),
        current: claimStatus === 'APPROVED' || claimStatus === 'REJECTED' || claimStatus === 'APPEAL'
      });
    }

    claims.push({
      id: `OWF-2026-${String(10000 + i + 1).padStart(4, '0')}`,
      matchId: match.id,
      beneficiaryId: match.beneficiaryId,
      beneficiaryName: match.beneficiaryName,
      benefitType: match.benefitType,
      institutionId: match.institutionId,
      institutionName: match.institutionName,
      referenceNumber: match.institutionReference,
      state: claimStatus,
      potentialValue: match.potentialValue,
      amount: match.potentialValue, // For now, same as potential
      submittedAt: timeline[0].timestamp,
      updatedAt: timeline[timeline.length - 1].timestamp,
      documents: [], // Will be populated separately if needed
      timeline,
      notes: rng(4, `claim_notes_${i}`) > 2 ? `Claim notes for ${match.benefitType}` : undefined
    });
  }

  return claims;
}

// Generate notifications
function generateNotifications(profiles, matches, claims, notificationCount = 3000) {
  const notifications = [];

  for (let i = 0; i < notificationCount; i++) {
    const type = deterministicChoice(NOTIFICATION_TYPES, `notification_type_${i}`);
    const isRead = rng(3, `notification_read_${i}`) > 1; // 66% chance of being read

    let title, message, link;

    switch (type) {
      case 'match':
        const match = deterministicChoice(matches, `notification_match_${i}`);
        title = 'Potential benefit identified';
        message = `A potential ${match.benefitType} benefit of N$ ${match.potentialValue.toLocaleString()} was found with ${match.institutionName}.`;
        link = `/app/matches/${match.id}`;
        break;

      case 'claim':
        const claimForNotification = deterministicChoice(claims, `notification_claim_${i}`);
        title = 'Claim update';
        message = `Your claim ${claimForNotification.id} has moved to ${claimForNotification.state.replace(/_/g, ' ').toLowerCase()} stage.`;
        link = `/app/claims/${claimForNotification.id}`;
        break;

      case 'document':
        const claimForDocNotification = deterministicChoice(claims, `notification_document_${i}`);
        title = 'Document required';
        message = `Additional evidence is required for your claim ${claimForDocNotification.id}.`;
        link = `/app/claims/${claimForDocNotification.id}`;
        break;

      case 'system':
        title = 'Welcome to OwaFind';
        message = 'Your account has been set up. Complete your profile to improve match accuracy.';
        link = '/app/profile';
        break;
    }

    notifications.push({
      id: `n_${i + 1}`,
      title,
      message,
      type,
      read: isRead,
      createdAt: generateDateInRange(2026, 2026, `notification_date_${i}`),
      link
    });
  }

  return notifications;
}

// Generate risk alerts
function generateRiskAlerts(claims, matches, alertCount = 100) {
  const alerts = [];

  for (let i = 0; i < alertCount; i++) {
    const type = deterministicChoice(RISK_ALERT_TYPES, `alert_type_${i}`);
    const severity = deterministicChoice(RISK_ALERT_SEVERITIES, `alert_severity_${i}`);
    const status = deterministicChoice(RISK_ALERT_STATUSES, `alert_status_${i}`);

    let description, claimId, matchId;

    switch (type) {
      case 'duplicate_identity':
        description = 'Two claims reference the same national ID but different names. Requires human review.';
        claimId = deterministicChoice(claims, `alert_claim_${i}`).id;
        break;

      case 'reused_document':
        description = 'Document uploaded for claim was previously used in a different claim.';
        claimId = deterministicChoice(claims, `alert_claim_${i}`).id;
        break;

      case 'multiple_beneficiary':
        description = 'Beneficiary linked to three different benefit records across institutions.';
        matchId = deterministicChoice(matches, `alert_match_${i}`).id;
        break;

      case 'suspicious_pattern':
        description = 'Rapid sequential claims from same device fingerprint within 24 hours.';
        break;
    }

    alerts.push({
      id: `ra_${i + 1}`,
      type,
      severity,
      description,
      claimId: claimId || undefined,
      matchId: matchId || undefined,
      createdAt: generateDateInRange(2026, 2026, `alert_date_${i}`),
      status
    });
  }

  return alerts;
}

// Generate audit events
function generateAuditEvents(claims, notifications, eventCount = 2000) {
  const events = [];

  for (let i = 0; i < eventCount; i++) {
    const action = deterministicChoice(AUDIT_EVENT_ACTIONS, `event_action_${i}`);
    const actorChoices = [
      'System',
      'Claims Officer',
      'Beneficiary',
      'Regulator',
      'Administrator'
    ];
    const actor = `${deterministicChoice(actorChoices, `event_actor_${i}`)} ${deterministicChoice(['Jr.', 'Sr.', ''], `event_actor_suffix_${i}`)}`;

    let target, details;

    switch (action) {
      case 'Submitted claim':
        const auditEventClaim1 = deterministicChoice(claims, `event_claim_${i}`);
        target = auditEventClaim1.id;
        details = `Claim submitted for ${auditEventClaim1.benefitType} benefit`;
        break;

      case 'Uploaded document':
      case 'Verified document':
        const auditEventClaim2 = deterministicChoice(claims, `event_claim_${i}`);
        target = auditEventClaim2.id;
        details = `Document processed for claim ${auditEventClaim2.id}`;
        break;

      case 'Reviewed claim':
        const auditEventClaim3 = deterministicChoice(claims, `event_claim_${i}`);
        target = auditEventClaim3.id;
        details = `Claim reviewed and moved to ${auditEventClaim3.state}`;
        break;

      case 'Updated claim status':
        const auditEventClaim4 = deterministicChoice(claims, `event_claim_${i}`);
        target = auditEventClaim4.id;
        details = `Claim status updated to ${auditEventClaim4.state}`;
        break;

      case 'Identity verification completed':
        const auditEventClaim5 = deterministicChoice(claims, `event_claim_${i}`);
        target = auditEventClaim5.id;
        details = 'Automated identity check passed';
        break;

      case 'State transition':
        const auditEventClaim6 = deterministicChoice(claims, `event_claim_${i}`);
        target = auditEventClaim6.id;
        details = `State transition: ${auditEventClaim6.state}`;
        break;

      case 'Risk alert generated':
        // Would reference a risk alert, but we'll keep it simple
        target = `alert_${deterministicRange(1, 50, `event_alert_ref_${i}`)}`;
        details = 'Risk alert generated for potential fraud pattern';
        break;

      case 'Support ticket created':
        target = `ticket_${deterministicRange(1, 100, `event_ticket_ref_${i}`)}`;
        details = 'Support ticket created for beneficiary assistance';
        break;

      default:
        target = `entity_${i}`;
        details = `Action performed: ${action}`;
    }

    events.push({
      id: `ae_${i + 1}`,
      timestamp: generateDateInRange(2026, 2026, `event_timestamp_${i}`),
      actor,
      action,
      target,
      details
    });
  }

  return events;
}

// Generate FAQs
function generateFAQs() {
  return [
    {
      id: 'faq1',
      question: 'What is OwaFind?',
      answer: 'OwaFind is a platform that helps you discover financial benefits that may belong to you — such as pension benefits, retirement funds, life insurance, funeral benefits, and more. We identify potential matches and guide you through the claims process.',
      category: 'General'
    },
    {
      id: 'faq2',
      question: 'Does OwaFind hold my money?',
      answer: 'No. OwaFind does not hold customer funds. We help you discover potential benefits and connect you with the institution that holds the benefit. The institution remains responsible for verification, approval, and payment.',
      category: 'General'
    },
    {
      id: 'faq3',
      question: 'What does a potential match mean?',
      answer: 'A potential match means our system has identified a benefit record that may belong to you based on your identity information. It does NOT mean you are legally entitled to the benefit. Final verification is done by the holding institution.',
      category: 'Matching'
    },
    {
      id: 'faq4',
      question: 'How accurate is the matching?',
      answer: 'Our matching system uses multiple signals — name, date of birth, national ID, and employment history — to assess confidence. Higher confidence scores indicate stronger matches, but all matches require institution verification.',
      category: 'Matching'
    },
    {
      id: 'faq5',
      question: 'What documents do I need to claim?',
      answer: 'Typically you will need your ID document, proof of employment, and any relevant certificates (marriage, death, beneficiary). The specific documents depend on the benefit type and will be listed during the claim process.',
      category: 'Claims'
    },
    {
      id: 'faq6',
      question: 'How long does a claim take?',
      answer: 'Claim resolution times vary by institution and benefit type. On average, institutions resolve claims within 10–21 days. You can track your claim status in real time through your dashboard.',
      category: 'Claims'
    },
    {
      id: 'faq7',
      question: 'Is my information safe?',
      answer: 'OwaFind protects sensitive information. Your data is encrypted and used only for matching and claims purposes. We do not share your information with third parties without your consent.',
      category: 'Privacy'
    },
    {
      id: 'faq8',
      question: 'Can I withdraw consent?',
      answer: 'Yes. You can withdraw consent at any time from your Settings page under Privacy. Withdrawing consent will pause ongoing searches but will not affect claims already submitted.',
      category: 'Privacy'
    },
    {
      id: 'faq9',
      question: 'What if my claim is rejected?',
      answer: 'If your claim is rejected, the institution will provide a reason. You may be able to submit an appeal or provide additional information. Check your claim tracking page for details.',
      category: 'Claims'
    },
    {
      id: 'faq10',
      question: 'Does OwaFind charge fees?',
      answer: 'OwaFind is a free service for beneficiaries. There are no charges for searching, matching, or submitting claims.',
      category: 'General'
    }
  ];
}

// Generate support tickets
function generateSupportTickets(profiles, ticketCount = 100) {
  const tickets = [];

  const categories = ['Claims', 'Matching', 'Documents', 'Technical', 'General'];

  for (let i = 0; i < ticketCount; i++) {
    const profile = deterministicChoice(profiles, `ticket_profile_${i}`);
    const category = deterministicChoice(categories, `ticket_category_${i}`);
    const status = rng(4, `ticket_status_${i}`) > 2 ? 'open' :
                   rng(4, `ticket_status_${i}`) > 1 ? 'in_progress' :
                   rng(4, `ticket_status_${i}`) > 0 ? 'resolved' : 'closed';

    let subject, message;

    switch (category) {
      case 'Claims':
        subject = 'Question about claim requirements';
        message = `I need help understanding what documents are required for my ${deterministicChoice(BENEFIT_TYPES)} claim.`;
        break;

      case 'Matching':
        subject = 'Question about match results';
        message = `I received a match notification but I'm not sure if it's correct. Can you help me verify?`;
        break;

      case 'Documents':
        subject = 'Help with document upload';
        message = `I'm having trouble uploading my documents. The system keeps giving me an error.`;
        break;

      case 'Technical':
        subject = 'Website technical issue';
        message = `The website is running slowly and some features aren't working properly.`;
        break;

      case 'General':
        subject = 'General inquiry about OwaFind';
        message = `I'd like to learn more about how OwaFind works and what benefits I might be eligible for.`;
        break;
    }

    tickets.push({
      id: `OWF-${String(4000 + i + 1).padStart(4, '0')}`,
      subject,
      category,
      status,
      createdAt: generateDateInRange(2026, 2026, `ticket_created_${i}`),
      updatedAt: generateDateInRange(2026, 2026, `ticket_updated_${i}`),
      messages: [
        {
          author: `${profile.firstName} ${profile.lastName}`,
          message,
          timestamp: generateDateInRange(2026, 2026, `ticket_message_${i}_0`)
        },
        {
          author: 'OwaFind Support',
          message: `Thank you for contacting OwaFind Support. I'll help you with your ${category.toLowerCase()} inquiry.`,
          timestamp: generateDateInRange(2026, 2026, `ticket_message_${i}_1`)
        }
      ]
    });
  }

  return tickets;
}

// Generate uploaded documents
function generateUploadedDocuments(claims, docCount = 1500) {
  const documents = [];

  for (let i = 0; i < docCount; i++) {
    const claim = deterministicChoice(claims, `doc_claim_${i}`);
    const type = deterministicChoice(DOCUMENT_TYPES, `doc_type_${i}`);
    const size = deterministicRange(50000, 5000000, `doc_size_${i}`); // 50KB to 5MB
    const uploadStatus = rng(4, `doc_upload_status_${i}`) > 2 ? 'verified' :
                         rng(4, `doc_upload_status_${i}`) > 1 ? 'needs_review' :
                         rng(4, `doc_upload_status_${i}`) > 0 ? 'scanning' : 'uploading';
    const verificationStatus = uploadStatus === 'verified' ? 'verified' :
                              uploadStatus === 'needs_review' ? 'needs_review' : 'pending';

    documents.push({
      id: `doc_${i + 1}`,
      claimId: claim.id,
      name: `${type.replace(/\s+/g, '_')}_${String(i + 1).padStart(4, '0')}.pdf`,
      type,
      size,
      uploadStatus,
      uploadedAt: generateDateInRange(2026, 2026, `doc_uploaded_${i}`),
      verificationStatus
    });
  }

  return documents;
}

// Main generation function
function generateSyntheticData() {
  console.log('Starting synthetic data generation...');

  // Generate core data
  console.log('Generating institutions...');
  const institutions = generateInstitutions(35); // Match existing count

  console.log('Generating beneficiary profiles...');
  const profiles = generateBeneficiaryProfiles(12000); // ~12k distinct beneficiaries

  console.log('Generating benefit records...');
  const benefitRecords = generateBenefitRecords(profiles, institutions);

  // Verify unclaimed balance
  const unclaimedSum = benefitRecords
    .filter(record => record.status === 'unclaimed')
    .reduce((sum, record) => sum + record.approximateValue, 0);

  console.log(`Generated unclaimed balance: N$${(unclaimedSum / 100).toLocaleString()}`);
  console.log(`Target unclaimed balance: N$${218700000 / 100}.00`);

  console.log('Generating matches...');
  const matches = generateMatches(profiles, benefitRecords, 18500); // Target 18.5k matches

  console.log('Generating claims...');
  const claims = generateClaims(matches, 2000);

  console.log('Generating notifications...');
  const notifications = generateNotifications(profiles, matches, claims, 3000);

  console.log('Generating risk alerts...');
  const riskAlerts = generateRiskAlerts(claims, matches, 100);

  console.log('Generating audit events...');
  const auditEvents = generateAuditEvents(claims, notifications, 2000);

  console.log('Generating FAQs...');
  const faqs = generateFAQs();

  console.log('Generating support tickets...');
  const supportTickets = generateSupportTickets(profiles, 100);

  console.log('Generating uploaded documents...');
  const documents = generateUploadedDocuments(claims, 1500);

  // Create final data structure
  const syntheticData = {
    institutions,
    profiles: profiles.slice(0, 1000), // Limit profiles in data for performance
    benefitRecords,
    matches,
    claims,
    notifications,
    riskAlerts,
    auditEvents,
    faqs,
    supportTickets,
    documents,
    asOfDate: '2026-10-12',
    version: '1.0.0',
    totalUnclaimedBalance: benefitRecords
      .filter(record => record.status === 'unclaimed')
      .reduce((sum, record) => sum + record.approximateValue, 0)
  };

  // Validate the unclaimed balance
  const isValid = validateSyntheticData(syntheticData);
  console.log(`Synthetic data validation: ${isValid ? 'PASS' : 'FAIL'}`);

  if (!isValid) {
    console.error('ERROR: Unclaimed balance does not match target!');
    process.exit(1);
  }

  return syntheticData;
}

// Validation function
function validateSyntheticData(data) {
  const unclaimedSum = data.benefitRecords
    .filter(record => record.status === 'unclaimed')
    .reduce((sum, record) => sum + record.approximateValue, 0);

  return unclaimedSum === 218700000; // N$218,700,000.00 in cents
}

// Generate and output data
const syntheticData = generateSyntheticData();

// Write to file
const outputPath = 'src/data/synthetic/generatedData.json';

try {
  fs.writeFileSync(outputPath, JSON.stringify(syntheticData, null, 2));
  console.log(`Synthetic data written to ${outputPath}`);

  // Also create a summary file
  const summary = {
    generationDate: new Date().toISOString(),
    recordCounts: {
      institutions: syntheticData.institutions.length,
      profiles: syntheticData.profiles.length,
      benefitRecords: syntheticData.benefitRecords.length,
      matches: syntheticData.matches.length,
      claims: syntheticData.claims.length,
      notifications: syntheticData.notifications.length,
      riskAlerts: syntheticData.riskAlerts.length,
      auditEvents: syntheticData.auditEvents.length,
      faqs: syntheticData.faqs.length,
      supportTickets: syntheticData.supportTickets.length,
      documents: syntheticData.documents.length
    },
    unclaimedBalance: syntheticData.totalUnclaimedBalance,
    unclaimedBalanceFormatted: `N$${(syntheticData.totalUnclaimedBalance / 100).toLocaleString()}`,
    validation: validateSyntheticData(syntheticData) ? 'PASS' : 'FAIL'
  };

  const summaryPath = 'src/data/synthetic/generationSummary.json';
  fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
  console.log(`Generation summary written to ${summaryPath}`);

} catch (err) {
  console.error('Error writing synthetic data:', err);
  process.exit(1);
}

// Export for use in other modules
export { syntheticData, validateSyntheticData };