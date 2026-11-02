/**
 * Test synthetic data generator for OwaFind local workspace
 * Simple version to test the concept
 */

import crypto from 'crypto';

// Deterministic random seed
const SEED = 'owafind-test-data';

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

// Generate deterministic ID
function generateId(prefix, seedModifier = '') {
  const hash = crypto.createHash('md5').update(`${SEED}:${prefix}:${seedModifier}`).digest();
  return hash.toString('hex').substring(0, 8);
}

// Generate deterministic Namibian-style name
function generateNamibianName(seedModifier = '') {
  const firstNames = ['Maria', 'Pendukeni', 'Gideon', 'Linea'];
  const lastNames = ['Doe', 'Hamukwaya', 'Nepembe', 'Shilongo'];

  const firstName = deterministicChoice(firstNames, `first:${seedModifier}`);
  const lastName = deterministicChoice(lastNames, `last:${seedModifier}`);

  return { firstName, lastName };
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
function generateInstitutions(count = 5) {
  const institutions = [];

  // Base institution data
  const baseInstitutions = [
    { id: 'gipf', name: 'Government Institutions Pension Fund (GIPF)', short: 'GIPF', type: 'Pension Fund', region: 'Windhoek' },
    { id: 'namcor-pension', name: 'Namcor Pension Fund', short: 'Namcor', type: 'Pension Fund', region: 'Windhoek' },
    { id: 'nampower-provident', name: 'Nampower Provident Fund', short: 'Nampower', type: 'Pension Fund', region: 'Windhoek' },
    { id: 'sanlam-namibia', name: 'Sanlam Namibia', short: 'Sanlam', type: 'Insurer', region: 'Windhoek' },
    { id: 'old-mutual-namibia', name: 'Old Mutual Namibia', short: 'Old Mutual', type: 'Insurer', region: 'Windhoek' }
  ];

  // Add base institutions
  for (let i = 0; i < Math.min(count, baseInstitutions.length); i++) {
    const inst = baseInstitutions[i];
    institutions.push({
      id: inst.id,
      name: inst.name,
      type: inst.type,
      region: inst.region,
      matches: deterministicRange(100, 500, `inst_matches_${i}`),
      claims: deterministicRange(20, 100, `inst_claims_${i}`),
      pendingReview: deterministicRange(5, 20, `inst_pending_${i}`),
      resolved: deterministicRange(10, 80, `inst_resolved_${i}`),
      avgResolutionDays: deterministicRange(10, 25, `inst_resolution_days_${i}`),
      demo: true,
      short: inst.short
    });
  }

  return institutions;
}

// Generate beneficiary profiles
function generateBeneficiaryProfiles(count = 10) {
  const profiles = [];

  for (let i = 0; i < count; i++) {
    const { firstName, lastName } = generateNamibianName(`profile_${i}`);
    const dateOfBirth = generateDateInRange(1950, 2000, `dob_${i}`);
    const phone = `+264 81 ${String(rng(1000000, `phone_${i}`)).padStart(7, '0')}`;
    const email = `${(firstName || '').toLowerCase()}.${(lastName || '').toLowerCase()}@example.com`;
    const region = deterministicChoice(['Windhoek', 'Walvis Bay', 'Oshakati'], `region_${i}`);

    profiles.push({
      firstName,
      lastName,
      dateOfBirth,
      nationalId: `${String(rng(1000000000, `nid_${i}`)).padStart(9, '0')}${String(rng(10, `check_${i}`))}`,
      previousName: '',
      phone,
      email,
      region,
      employmentHistory: [],
      consentGiven: rng(2, `consent_${i}`) === 1,
      consentDate: rng(2, `consent_${i}`) === 1 ? generateDateInRange(2020, 2026, `consent_date_${i}`) : null,
      profileCompletion: rng(100, `completion_${i}`),
      verificationStatus: rng(2, `verification_${i}`) === 1 ? 'verified' : 'unverified'
    });
  }

  return profiles;
}

// Generate benefit records
function generateBenefitRecords(profiles, institutions) {
  const benefitRecords = [];

  for (let i = 0; i < profiles.length * 2; i++) { // 2 records per profile on average
    const profileIndex = rng(profiles.length, `profile_${i}`);
    const profile = profiles[profileIndex];
    const institution = deterministicChoice(institutions, `inst_${i}`);
    const benefitType = deterministicChoice(['Pension', 'Retirement Fund', 'Life Insurance'], `benefit_${i}`);

    // Generate benefit value
    let value;
    const valueRoll = rng(100, `value_roll_${i}`);
    if (valueRoll < 70) {
      value = deterministicRange(5000, 50000, `value_small_${i}`);
    } else if (valueRoll < 90) {
      value = deterministicRange(50000, 200000, `value_medium_${i}`);
    } else {
      value = deterministicRange(200000, 1000000, `value_large_${i}`);
    }

    // Determine status
    const statusRoll = rng(100, `status_roll_${i}`);
    const status = statusRoll < 60 ? 'unclaimed' : (statusRoll < 80 ? 'dormant' : 'active');

    benefitRecords.push({
      id: `br_${i + 1}`,
      type: benefitType,
      institutionId: institution.id,
      institutionName: institution.name,
      reference: `${institution.short}-${String(i + 1).padStart(6, '0')}`,
      approximateValue: value,
      region: institution.region,
      status: status
    });
  }

  return benefitRecords;
}

// Main generation function
function generateTestData() {
  console.log('Starting test synthetic data generation...');

  // Generate core data
  console.log('Generating institutions...');
  const institutions = generateInstitutions(5);

  console.log('Generating beneficiary profiles...');
  const profiles = generateBeneficiaryProfiles(10);

  console.log('Generating benefit records...');
  const benefitRecords = generateBenefitRecords(profiles, institutions);

  // Calculate unclaimed balance
  const unclaimedSum = benefitRecords
    .filter(record => record.status === 'unclaimed')
    .reduce((sum, record) => sum + record.approximateValue, 0);

  console.log(`Generated unclaimed balance: N$${(unclaimedSum / 100).toLocaleString()}`);

  // Create final data structure
  const syntheticData = {
    institutions,
    profiles,
    benefitRecords,
    asOfDate: '2026-10-12',
    version: '1.0.0-test',
    totalUnclaimedBalance: unclaimedSum
  };

  return syntheticData;
}

// Generate and output data
const syntheticData = generateTestData();

// Write to file
import fs from 'fs';
const outputPath = 'src/data/synthetic/testData.json';

try {
  fs.writeFileSync(outputPath, JSON.stringify(syntheticData, null, 2));
  console.log(`Test synthetic data written to ${outputPath}`);

  // Also create a summary file
  const summary = {
    generationDate: new Date().toISOString(),
    recordCounts: {
      institutions: syntheticData.institutions.length,
      profiles: syntheticData.profiles.length,
      benefitRecords: syntheticData.benefitRecords.length
    },
    unclaimedBalance: syntheticData.totalUnclaimedBalance,
    unclaimedBalanceFormatted: `N$${(syntheticData.totalUnclaimedBalance / 100).toLocaleString()}`
  };

  const summaryPath = 'src/data/synthetic/testSummary.json';
  fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
  console.log(`Test summary written to ${summaryPath}`);

} catch (err) {
  console.error('Error writing synthetic data:', err);
  process.exit(1);
}

// Export for use in other modules
export { syntheticData };