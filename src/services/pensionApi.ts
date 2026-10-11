/**
 * Typed client for the Namibia Pension Funds API.
 *
 * Maps the documented backend endpoints to promise-based methods.
 * All errors are wrapped in ApiError so UI components can handle
 * loading, success, empty, and error states uniformly.
 */

import { get, post, type ApiError } from './apiClient';

// ---------------------------------------------------------------------------
// API response types (documented contract)
// ---------------------------------------------------------------------------

export interface HealthResponse {
  status: 'ok';
}

export interface ServiceInfoResponse {
  service: string;
  databases: string[];
}

export interface PensionFirm {
  firm: string;
  label: string;
  members: number;
}

export interface FirmMember {
  id_number: string;
  first_name: string;
  last_name: string;
  date_of_birth?: string;
  phone?: string;
  email?: string;
  ref_number: string;
  employer?: string;
  date_joined?: string;
  date_left?: string;
  balance_nad?: number;
  status?: string;
}

export interface SearchByIdResults {
  id_number: string;
  funds_found: number;
  firms: string[];
  total_balance: number;
  dormant_balance: number;
  results: FirmMember[];
}

export interface SearchByNameResults {
  count: number;
  results: FirmMember[];
}

export interface PensionHolding {
  firm: string;
  label: string;
  ref_number: string;
  employer?: string;
  date_joined?: string;
  date_left?: string;
  balance_nad?: number;
  status?: string;
}

export interface ClientHolding {
  id_number?: string;
  first_name?: string;
  last_name?: string;
  date_of_birth?: string;
  phone?: string;
  email?: string;
  firms: string[];
  funds_found: number;
  dormant_balance: number;
  active_balance: number;
  total_balance: number;
  holdings: PensionHolding[];
}

export interface ClaimableResponse {
  clients: ClientHolding[];
  count?: number;
  total_balance?: number;
  dormant_balance?: number;
  active_balance?: number;
}

export interface DormantResults {
  count: number;
  total_dormant: number;
  results: FirmMember[];
}

export interface MultiFirmHolding {
  id_number?: string;
  first_name?: string;
  last_name?: string;
  firms: string[];
  funds_found: number;
  total_balance: number;
  holdings: PensionHolding[];
}

export interface MultiFirmResponse {
  count: number;
  clients: MultiFirmHolding[];
  total_balance?: number;
}

export interface ClaimRecord {
  id: string;
  id_number: string;
  firm: string;
  ref_number: string;
  claim_type?: string;
  amount_claimed?: number;
  notes?: string;
  created_at: string;
}

export interface ClaimsListResponse {
  claims: ClaimRecord[];
}

export interface CreateClaimRequest {
  id_number: string;
  firm: string;
  ref_number: string;
  claim_type?: string;
  amount_claimed?: number;
  notes?: string;
}

export interface CreateClaimResponse {
  id: string;
  id_number: string;
  firm: string;
  ref_number: string;
  claim_type: string;
  amount_claimed?: number;
  notes?: string;
  created_at: string;
}

// Validation / error payloads returned by the backend.
export interface ValidationError {
  detail: string;
  errors?: string[];
}

export type { ApiError };

// ---------------------------------------------------------------------------
// Health & service discovery
// ---------------------------------------------------------------------------

export async function getHealth(): Promise<HealthResponse> {
  return get<HealthResponse>('/health');
}

export async function getServiceInfo(): Promise<ServiceInfoResponse> {
  return get<ServiceInfoResponse>('/');
}

// ---------------------------------------------------------------------------
// Pension fund institutions
// ---------------------------------------------------------------------------

export async function listFirms(): Promise<PensionFirm[]> {
  return get<PensionFirm[]>('/api/firms/');
}

export async function getFirmMembers(firm: string): Promise<FirmMember[]> {
  return get<FirmMember[]>(`/api/firms/${firm}/members`);
}

// ---------------------------------------------------------------------------
// Search endpoints
// ---------------------------------------------------------------------------

export async function searchById(idNumber: string): Promise<SearchByIdResults> {
  return get<SearchByIdResults>(`/api/search/id/${idNumber}`);
}

export async function searchByName(q: string): Promise<SearchByNameResults> {
  return get<SearchByNameResults>(`/api/search/name?q=${encodeURIComponent(q)}`);
}

export async function searchClaimable(params: { id_number?: string; name?: string }): Promise<ClaimableResponse> {
  const query = new URLSearchParams();
  if (params.id_number) query.set('id_number', params.id_number);
  if (params.name) query.set('name', params.name);
  return get<ClaimableResponse>(`/api/search/claimable?${query}`);
}

export async function listDormant(): Promise<DormantResults> {
  return get<DormantResults>('/api/search/dormant');
}

export async function listMultiFirm(): Promise<MultiFirmResponse> {
  return get<MultiFirmResponse>('/api/search/multi-firm');
}

// ---------------------------------------------------------------------------
// Claims
// ---------------------------------------------------------------------------

export async function listClaims(): Promise<ClaimsListResponse> {
  return get<ClaimsListResponse>('/api/claims/');
}

export async function createClaim(body: CreateClaimRequest): Promise<CreateClaimResponse> {
  return post<CreateClaimResponse>('/api/claims/', body);
}

export const SUPPORTED_CLAIM_TYPES = ['Withdrawal', 'Retirement', 'Death', 'Transfer'] as const;
export const SUPPORTED_FIRMS = ['gipf', 'sanlam', 'oldmutual'] as const;

export function isSupportedFirm(firm: string): firm is (typeof SUPPORTED_FIRMS)[number] {
  return SUPPORTED_FIRMS.includes(firm as (typeof SUPPORTED_FIRMS)[number]);
}

export function isSupportedClaimType(type: string): type is (typeof SUPPORTED_CLAIM_TYPES)[number] {
  return SUPPORTED_CLAIM_TYPES.includes(type as (typeof SUPPORTED_CLAIM_TYPES)[number]);
}

export const DEFAULT_CLAIM_TYPE: (typeof SUPPORTED_CLAIM_TYPES)[number] = 'Withdrawal';
