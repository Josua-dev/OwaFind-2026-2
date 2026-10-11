/**
 * Application-wide context.
 *
 * State is divided into three categories:
 *  - UI preferences (role, activeInstitutionId, sidebar/theme) — stored
 *    client-side as they are not server-owned business data.
 *  - User-entered search input (profile) — kept client-side because the
 *    backend only uses it as search criteria; there is no user-account API.
 *  - Server-owned records (beneficiary search results, claims, documents,
 *    tickets) — retrieved from the Pension Funds API. These are NOT
 *    persisted in localStorage and cannot be restored from it.
 *
 * If the app reloads, UI preferences are preserved but live records are
 * re-fetched from the API on next navigation.
 */

import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import type {
  Role,
  BeneficiaryProfile,
  Claim,
  UploadedDocument,
  SupportTicket,
  MatchRecord,
} from '@/types';

interface AppContextValue {
  role: Role;
  setRole: (role: Role) => void;
  switchRole: (role: Role) => void;
  switching: boolean;

  activeInstitutionId: string;
  setActiveInstitution: (id: string) => void;

  profile: BeneficiaryProfile;
  setProfile: (profile: BeneficiaryProfile) => void;

  notifications: unknown[]; // no notification API endpoint
  markNotificationRead: (id: string) => void;
  markAllNotificationsRead: () => void;
  unreadCount: number;

  claims: Claim[];
  addClaim: (claim: Claim) => void;
  updateClaim: (claim: Claim) => void;

  documents: UploadedDocument[];
  addDocument: (doc: UploadedDocument) => void;
  updateDocument: (doc: UploadedDocument) => void;
  removeDocument: (id: string) => void;

  tickets: SupportTicket[];
  addTicket: (t: SupportTicket) => void;

  searchResults: MatchRecord[]; // results of the last beneficiary search (from API)
  clearSearchResults: () => void;

  consentGiven: boolean;
  setConsentGiven: (v: boolean) => void;

  resetDemo: () => void;
  logout: () => void;
}

const AppContext = createContext<AppContextValue | undefined>(undefined);

// Keep only UI preferences in localStorage; business records are never
// restored from the browser store.
const UI_PERSIST_KEY = 'owafind-ui-prefs';

const DEFAULT_PROFILE: BeneficiaryProfile = {
  firstName: '',
  lastName: '',
  dateOfBirth: '',
  nationalId: '',
  previousName: '',
  phone: '',
  email: '',
  region: '',
  employmentHistory: [],
  consentGiven: false,
  consentDate: null,
  profileCompletion: 0,
  verificationStatus: 'unverified',
};

interface UIPrefs {
  role: Role;
  activeInstitutionId: string;
  consentGiven: boolean;
}

function loadUIPrefs(): Partial<UIPrefs> {
  try {
    const raw = localStorage.getItem(UI_PERSIST_KEY);
    if (raw) return JSON.parse(raw);
  } catch {
    // ignore
  }
  return {};
}

function saveUIPrefs(prefs: UIPrefs) {
  try {
    localStorage.setItem(UI_PERSIST_KEY, JSON.stringify(prefs));
  } catch {
    // ignore
  }
}

export function ROLE_HOME(role: Role): string {
  switch (role) {
    case 'beneficiary':
      return '/app/dashboard';
    case 'institution':
      return '/app/institution';
    case 'regulator':
      return '/app/regulator';
    case 'executive':
      return '/app/executive';
    case 'admin':
      return '/app/admin';
    default:
      return '/app/dashboard';
  }
}

export function roleHomePath(role: Role): string {
  return ROLE_HOME(role);
}

export function AppProvider({ children }: { children: ReactNode }) {
  const persisted = loadUIPrefs();
  const navigate = useNavigate();

  const [role, setRole] = useState<Role>(persisted.role || 'beneficiary');
  const [activeInstitutionId, setActiveInstitutionId] = useState<string>(
    persisted.activeInstitutionId || 'gipf'
  );
  const [profile, setProfile] = useState<BeneficiaryProfile>(DEFAULT_PROFILE);
  const [searchResults, setSearchResults] = useState<MatchRecord[]>([]);
  const [notifications, setNotifications] = useState<unknown[]>([]);
  const [claims, setClaims] = useState<Claim[]>([]);
  const [documents, setDocuments] = useState<UploadedDocument[]>([]);
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [consentGiven, setConsentGiven] = useState<boolean>(persisted.consentGiven ?? false);
  const [switching, setSwitching] = useState(false);
  const switchTimer = useRef<number | undefined>(undefined);

  useEffect(() => {
    saveUIPrefs({ role, activeInstitutionId, consentGiven });
  }, [role, activeInstitutionId, consentGiven]);

  useEffect(() => () => window.clearTimeout(switchTimer.current), []);

  const switchRole = (next: Role) => {
    if (next !== role) {
      setSwitching(true);
      setRole(next);
    }
    navigate(ROLE_HOME(next), { replace: true });
    window.clearTimeout(switchTimer.current);
    switchTimer.current = window.setTimeout(() => setSwitching(false), 350);
  };

  const markNotificationRead = (_id: string): void => {
    setNotifications((prev) => prev.map((n) => n));
  };

  const markAllNotificationsRead = (): void => {
    setNotifications([]);
  };

  const unreadCount = notifications.filter((n) => n !== null).length;

  const addClaim = (claim: Claim): void => {
    setClaims((prev) => [claim, ...prev]);
  };

  const updateClaim = (claim: Claim): void => {
    setClaims((prev) => prev.map((c) => (c.id === claim.id ? claim : c)));
  };

  const addDocument = (doc: UploadedDocument): void => {
    setDocuments((prev) => [doc, ...prev]);
  };

  const updateDocument = (doc: UploadedDocument): void => {
    setDocuments((prev) => prev.map((d) => (d.id === doc.id ? doc : d)));
  };

  const removeDocument = (id: string): void => {
    setDocuments((prev) => prev.filter((d) => d.id !== id));
  };

  const addTicket = (t: SupportTicket): void => {
    setTickets((prev) => [t, ...prev]);
  };

  const clearSearchResults = (): void => {
    setSearchResults([]);
  };

  const resetDemo = (): void => {
    localStorage.removeItem(UI_PERSIST_KEY);
    setRole('beneficiary');
    setActiveInstitutionId('gipf');
    setProfile(DEFAULT_PROFILE);
    setSearchResults([]);
    setNotifications([]);
    setClaims([]);
    setDocuments([]);
    setTickets([]);
    setConsentGiven(false);
  };

  const logout = (): void => {
    resetDemo();
    navigate('/login', { replace: true });
  };

  return (
    <AppContext.Provider
      value={{
        role,
        setRole,
        switchRole,
        switching,
        activeInstitutionId,
        setActiveInstitution: setActiveInstitutionId,
        profile,
        setProfile,
        notifications,
        markNotificationRead,
        markAllNotificationsRead,
        unreadCount,
        claims,
        addClaim,
        updateClaim,
        documents,
        addDocument,
        updateDocument,
        removeDocument,
        tickets,
        addTicket,
        searchResults,
        clearSearchResults,
        consentGiven,
        setConsentGiven,
        resetDemo,
        logout,
      }}
    >
      {children}
    </AppContext.Provider>
  );
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}