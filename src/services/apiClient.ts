/**
 * Centralized HTTP client for the Namibia Pension Funds API.
 *
 * Reads the base URL from VITE_PENSION_API_BASE_URL and sends the
 * ngrok-skip-browser-warning header on every request. Handles JSON
 * parsing, network failures, timeouts, and non-JSON responses (including
 * ngrok warning pages) with typed errors.
 */

const BASE_URL = (import.meta.env.VITE_PENSION_API_BASE_URL as string) || '';
const REQUEST_TIMEOUT_MS = 15000;

export class ApiError extends Error {
  status?: number;
  body?: unknown;
  constructor(message: string, opts: { status?: number; body?: unknown } = {}) {
    super(message);
    this.name = 'ApiError';
    this.status = opts.status;
    this.body = opts.body;
  }
}

export interface RequestInitEx {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: unknown;
  signal?: AbortSignal;
}

function buildUrl(path: string): string {
  // Allow callers to pass either a full URL or a path relative to BASE_URL.
  if (/^https?:\/\//i.test(path)) return path;
  const base = BASE_URL.replace(/\/+$/, '');
  const rel = path.replace(/^\/+/, '');
  return `${base}/${rel}`;
}

async function parseResponse<T>(res: Response): Promise<T> {
  const text = await res.text();
  if (!text) return undefined as unknown as T;
  try {
    return JSON.parse(text) as T;
  } catch {
    throw new ApiError(
      `Expected JSON response but received non-JSON content (status ${res.status}).`,
      { status: res.status, body: text.slice(0, 200) }
    );
  }
}

export async function request<T>(path: string, init: RequestInitEx = {}): Promise<T> {
  if (!BASE_URL) {
    throw new ApiError(
      'API base URL is not configured. Set VITE_PENSION_API_BASE_URL in your environment.'
    );
  }

  const url = buildUrl(path);
  const controller = new AbortController();
  const signal = init.signal ?? controller.signal;
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const res = await fetch(url, {
      method: init.method ?? 'GET',
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: init.body != null ? JSON.stringify(init.body) : undefined,
      signal,
    });

    if (!res.ok) {
      let body: unknown;
      try {
        body = await parseResponse<unknown>(res);
      } catch {
        body = undefined;
      }
      const message =
        (body && typeof body === 'object' && 'detail' in (body as object)
          ? String((body as { detail: unknown }).detail)
          : undefined) ||
        `Request failed with status ${res.status}`;
      throw new ApiError(message, { status: res.status, body });
    }

    return parseResponse<T>(res);
  } catch (err) {
    if (err instanceof ApiError) throw err;
    if (err instanceof DOMException && err.name === 'AbortError') {
      throw new ApiError('Request timed out. Please try again.');
    }
    if (err instanceof TypeError) {
      throw new ApiError(
        'Could not connect to the pension funds service. Check your network connection and the API base URL.'
      );
    }
    throw new ApiError(err instanceof Error ? err.message : 'Unknown network error');
  } finally {
    clearTimeout(timeout);
  }
}

export function get<T>(path: string, init?: RequestInitEx): Promise<T> {
  return request<T>(path, { ...init, method: 'GET' });
}

export function post<T>(path: string, body: unknown, init?: RequestInitEx): Promise<T> {
  return request<T>(path, { ...init, method: 'POST', body });
}