/**
 * Application-wide context.
 *
 * State is divided into three categories:
 * Synthetic workspace records are loaded from the bundled baseline and
 * browser storage; no server or remote API is used by this context.
 */

import { createContext, useContext, useEffect, useRef, useState, type Dispatch, type ReactNode, type SetStateAction } from 'react';
import { useNavigate } from 'react-router-dom';
import type {
  Role,
  BeneficiaryProfile,
  Claim,
  UploadedDocument,
  SupportTicket,
  MatchRecord,
  Notification,
} from '@/types';
import {
  loadLocalWorkspaceState,
  resetLocalWorkspaceState,
  saveLocalWorkspaceState,
} from '@/services/workspaceRepository';

interface AppContextValue {
  role: Role;
  setRole: (role: Role) => void;
  switchRole: (role: Role) => void;
  switching: boolean;

  activeInstitutionId: string;
  setActiveInstitution: (id: string) => void;

  profile: BeneficiaryProfile;
  setProfile: (profile: BeneficiaryProfile) => void;

  notifications: Notification[];
  markNotificationRead: (id: string) => void;
  markAllNotificationsRead: () => void;
  unreadCount: number;

  claims: Claim[];
  setClaims: Dispatch<SetStateAction<Claim[]>>;
  addClaim: (claim: Claim) => void;
  updateClaim: (claim: Claim) => void;

  documents: UploadedDocument[];
  addDocument: (doc: UploadedDocument) => void;
  updateDocument: (doc: UploadedDocument) => void;
  removeDocument: (id: string) => void;

  tickets: SupportTicket[];
  addTicket: (t: SupportTicket) => void;

  searchResults: MatchRecord[];
  setSearchResults: (results: MatchRecord[]) => void;
  clearSearchResults: () => void;

  consentGiven: boolean;
  setConsentGiven: (v: boolean) => void;

  resetDemo: () => void;
  logout: () => void;
}

const AppContext = createContext<AppContextValue | undefined>(undefined);

const UI_PERSIST_KEY = 'owafind-ui-prefs';

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
  const [persisted] = useState(loadUIPrefs);
  const [local] = useState(loadLocalWorkspaceState);
  const navigate = useNavigate();

  const [role, setRole] = useState<Role>(persisted.role || 'beneficiary');
  const [activeInstitutionId, setActiveInstitutionId] = useState<string>(
    persisted.activeInstitutionId || 'gipf'
  );
  const [profile, setProfile] = useState<BeneficiaryProfile>(local.profile);
  const [searchResults, setSearchResults] = useState<MatchRecord[]>(local.searchResults);
  const [notifications, setNotifications] = useState<Notification[]>(local.notifications);
  const [claims, setClaims] = useState<Claim[]>(local.claims);
  const [documents, setDocuments] = useState<UploadedDocument[]>(local.documents);
  const [tickets, setTickets] = useState<SupportTicket[]>(local.tickets);
  const [consentGiven, setConsentGiven] = useState<boolean>(persisted.consentGiven ?? local.consentGiven);
  const [switching, setSwitching] = useState(false);
  const switchTimer = useRef<number | undefined>(undefined);

  useEffect(() => {
    saveUIPrefs({ role, activeInstitutionId, consentGiven });
  }, [role, activeInstitutionId, consentGiven]);

  useEffect(() => {
    saveLocalWorkspaceState({
      profile,
      searchResults,
      notifications,
      claims,
      documents,
      tickets,
      consentGiven,
    });
  }, [profile, searchResults, notifications, claims, documents, tickets, consentGiven]);

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

  const markNotificationRead = (id: string): void => {
    setNotifications((prev) => prev.map((notification) =>
      notification.id === id ? { ...notification, read: true } : notification,
    ));
  };

  const markAllNotificationsRead = (): void => {
    setNotifications((prev) => prev.map((notification) => ({ ...notification, read: true })));
  };

  const unreadCount = notifications.filter((notification) => !notification.read).length;

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
    const baseline = resetLocalWorkspaceState();
    setRole('beneficiary');
    setActiveInstitutionId('gipf');
    setProfile(baseline.profile);
    setSearchResults(baseline.searchResults);
    setNotifications(baseline.notifications);
    setClaims(baseline.claims);
    setDocuments(baseline.documents);
    setTickets(baseline.tickets);
    setConsentGiven(baseline.consentGiven);
  };

  const logout = (): void => {
    navigate('/', { replace: true });
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
        setClaims,
        addClaim,
        updateClaim,
        documents,
        addDocument,
        updateDocument,
        removeDocument,
        tickets,
        addTicket,
        searchResults,
        setSearchResults,
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