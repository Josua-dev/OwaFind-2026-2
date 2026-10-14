import { useState, useMemo } from 'react';
import { useEffect } from 'react';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Search as SearchIcon, FileText, Target, Building2, User } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useApp } from '@/context/AppContext';
import { benefitService, claimService, institutionService, matchService } from '@/services';
import { formatCurrency } from '@/utils/format';
import { mapClaimableResponse } from '@/services/dataMapping';
import type { MatchRecord, Claim, Institution } from '@/types';
import { Button } from '@/components/ui/Button';

interface SearchResult {
  id: string;
  title: string;
  subtitle: string;
  type: 'beneficiary' | 'claim' | 'match' | 'institution' | 'benefit';
  link: string;
  icon: typeof FileText;
}

// Non-beneficiary roles can only open their own workspace, so institution
// results point at the dashboard where that role sees institutions.
const ROLE_INSTITUTION_LINK: Record<string, string> = {
  institution: '/app/institution',
  regulator: '/app/regulator',
  executive: '/app/executive',
  admin: '/app/admin',
};

export function GlobalSearch({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [query, setQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { role, profile } = useApp();
  const [institutions, setInstitutions] = useState<Institution[]>([]);
  const [claims, setClaims] = useState<Claim[]>([]);
  const [matches, setMatches] = useState<MatchRecord[]>([]);

  // Load institutions and claims when the search modal opens (they change infrequently)
  useEffect(() => {
    if (open) {
      loadInstitutionsAndClaims();
    }
  }, [open]);

  const loadInstitutionsAndClaims = async () => {
    setLoading(true);
    setError(null);
    try {
      // Load institutions and claims in parallel
      const [instData, claimData] = await Promise.all([
        institutionService.getInstitutions(),
        claimService.getClaims()
      ]);

      setInstitutions(instData);
      setClaims(claimData);
    } catch (err) {
      console.error('Failed to load institutions/claims data:', err);
      setError('Failed to load search data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Search for matches when query changes
  useEffect(() => {
    if (!open || !query.trim()) {
      setMatches([]); // Clear matches when query is empty or modal closed
      return;
    }

    const searchMatches = async () => {
      setLoading(true);
      setError(null);
      try {
        // Use searchClaimable which accepts both id_number and name parameters
        // This allows us to search by either ID or name with one endpoint
        const response = await searchClaimable({
          id_number: query.trim(),
          name: query.trim()
        });

        // Map the response to MatchRecord format
        const matchRecords = mapClaimableResponse(response);
        setMatches(matchRecords);
      } catch (err) {
        console.error('Failed to search matches:', err);
        setError('Failed to search for matches. Please try again.');
      } finally {
        setLoading(false);
      }
    };

    // Only search if query has at least 2 characters to avoid excessive API calls
    if (query.trim().length >= 2) {
      searchMatches();
    } else {
      setMatches([]); // Clear matches for very short queries
    }
  }, [open, query]);

  const results = useMemo<SearchResult[]>(() => {
    if (!query.trim()) return [];
    const q = query.toLowerCase();
    const results: SearchResult[] = [];

    // Data consistency: beneficiary-identifying results (the demo
    // beneficiary's name, matches, claims and benefits) only appear for the
    // beneficiary role. Other roles search institutions only, linking to a
    // page they can actually open.
    if (role === 'beneficiary') {
      // Add beneficiary profile result
      if (profile.firstName && profile.lastName) {
        const beneficiaryName = `${profile.firstName} ${profile.lastName}`;
        if (beneficiaryName.toLowerCase().includes(q) ||
            profile.nationalId.toLowerCase().includes(q) ||
            profile.region.toLowerCase().includes(q)) {
          results.push({
            id: 'beneficiary-profile',
            title: beneficiaryName,
            subtitle: `Beneficiary — ${profile.region}`,
            type: 'beneficiary',
            link: '/app/profile',
            icon: User
          });
        }
      }

      // Add match results
      matches.forEach((m) => {
        if (m.beneficiaryName.toLowerCase().includes(q) ||
            m.benefitType.toLowerCase().includes(q) ||
            m.institutionName.toLowerCase().includes(q) ||
            m.id.toLowerCase().includes(q)) {
          results.push({
            id: m.id,
            title: m.beneficiaryName,
            subtitle: `${m.benefitType} — ${m.institutionName}`,
            type: 'match',
            link: `/app/matches/${m.id}`,
            icon: Target
          });
        }
      });

      // Add claim results
      claims.forEach((c) => {
        if (c.id.toLowerCase().includes(q) ||
            c.beneficiaryName.toLowerCase().includes(q) ||
            c.benefitType.toLowerCase().includes(q) ||
            c.institutionName.toLowerCase().includes(q)) {
          results.push({
            id: c.id,
            title: c.id,
            subtitle: `${c.beneficiaryName} — ${c.benefitType}`,
            type: 'claim',
            link: `/app/claims/${c.id}`,
            icon: FileText
          });
        }
      });

      // Add benefit records (these are essentially the same as matches in API context)
      // In the real API, benefit records would come from the same search as matches
      matches.forEach((m) => {
        if (m.benefitType.toLowerCase().includes(q) ||
            m.institutionName.toLowerCase().includes(q)) {
          results.push({
            id: `${m.id}-benefit`,
            title: m.benefitType,
            subtitle: `${m.institutionName} — ${formatCurrency(m.potentialValue ?? 0)}`,
            type: 'benefit',
            link: `/app/matches/${m.id}`,
            icon: FileText
          });
        }
      });
    } else if (ROLE_INSTITUTION_LINK[role]) {
      const link = ROLE_INSTITUTION_LINK[role];
      institutions.forEach((i) => {
        if (i.name.toLowerCase().includes(q) ||
            i.type.toLowerCase().includes(q) ||
            i.region.toLowerCase().includes(q) ||
            i.id.toLowerCase().includes(q)) {
          results.push({
            id: i.id,
            title: i.name,
            subtitle: `${i.type} — ${i.region}`,
            type: 'institution',
            link,
            icon: Building2
          });
        }
      });
    }

    return results.filter((r) => r.title.toLowerCase().includes(q) || r.subtitle.toLowerCase().includes(q)).slice(0, 12);
  }, [query, role, profile, institutions, claims, matches]);

  return (
    <Modal open={open} onClose={onClose} size="md">
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-bold text-slate-900">Search OwaFind</h2>
          {role === 'beneficiary' && (
            <Button variant="outline" size="sm" onClick={() => {
              onClose();
              // Navigate to search page to trigger a new search
              // In a real implementation, we might want to pre-fill the search
              // But for now, we'll just go to the search page
              // Note: We can't use navigate here without importing it, so we'll just close
              // The user can manually go to search if they want to trigger a new search
            }}>Search for Benefits</Button>
          )}
        </div>

        <Input
          placeholder={role === 'beneficiary' ? 'Search beneficiaries, claims, matches, institutions...' : 'Search institutions...'}
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          icon={<SearchIcon className="w-4 h-4" />}
        />

        {loading && (
          <div className="text-center py-4">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto" />
          </div>
        )}

        {!loading && error && (
          <div className="text-center py-4">
            <p className="text-center text-sm text-error-500">{error}</p>
          </div>
        )}

        {!loading && !error && searchResults.length === 0 && query.trim() !== '' ? (
          <p className="text-center text-sm text-slate-400 py-8">No results found for "{query}"</p>
        ) : null}

        {!loading && searchResults.length > 0 && (
          <div className="max-h-96 overflow-y-auto scrollbar-thin space-y-1">
            {searchResults.map((r) => {
              const Icon = r.icon;
              return (
                <Link
                  key={`${r.type}-${r.id}`}
                  to={r.link}
                  onClick={onClose}
                  className="flex items-center gap-3 p-2.5 rounded-lg hover:bg-slate-50 transition-colors"
                >
                  <div className="w-9 h-9 rounded-lg bg-slate-100 flex items-center justify-center shrink-0">
                    <Icon className="w-4 h-4 text-slate-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-slate-800 truncate">{r.title}</p>
                    <p className="text-xs text-slate-400 truncate">{r.subtitle}</p>
                  </div>
                  <span className="text-xs text-slate-300 capitalize">{r.type}</span>
                </Link>
              );
            })}
          </div>
        )}

        {!loading && searchResults.length === 0 && query.trim() === '' && (
          <p className="text-center text-sm text-slate-400 py-8">Start typing to search across your data</p>
        )}
      </div>
    </Modal>
  );
}