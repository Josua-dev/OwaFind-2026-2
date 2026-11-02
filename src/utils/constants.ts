/** Success fee charged on the benefit amount that is approved and paid out. */
export const SUCCESS_FEE_PERCENTAGE = 2.5;

/** Success fee for a given amount, rounded to 2 decimal places. */
export function calculateSuccessFee(amount: number): number {
  if (!Number.isFinite(amount) || amount <= 0) return 0;
  // amount * pct / 100, rounded to cents (done in integer-cent space to avoid float drift).
  return Math.round(amount * SUCCESS_FEE_PERCENTAGE) / 100;
}
