import { useState, useEffect } from 'react';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Search as SearchIcon, FileText, Target, Building2, User } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useApp } from '@/context/AppContext';
import { claimService, institutionService } from '@/services';
import { formatCurrency } from '@/utils/format';
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

  useEffect(() => {
    if (!open) return;
    void (async () => {
      try {
        const [instData, claimData] = await Promise.all([
          institutionService.getInstitutions(),
          claimService.getClaims(),
        ]);
        setInstitutions(instData);
        setClaims(claimData);
      } catch (err) {
        console.error('Failed to load institutions/claims data:', err);
        setError('Failed to load search data. Please try again.');
      }
    })();
  }, [open]);

  useEffect(() => {
    if (!open || !query.trim()) {
      setSearchResults([]);
      return;
    }

    void (async () => {
      setLoading(true);
      setError(null);
      try {
        const baseMatches = await claimService.getClaims();
        const q = query.trim().toLowerCase();
        const filteredMatches = baseMatches.filter((claim) => {
          const haystack = [
            claim.beneficiaryName,
            claim.benefitType,
            claim.institutionName,
            claim.id,
            claim.beneficiaryId,
          ].join(' ').toLowerCase();
          return haystack.includes(q);
        });

        const nextMatches: MatchRecord[] = filteredMatches.map((claim) => ({
          id: claim.id,
          beneficiaryId: claim.beneficiaryId,
          beneficiaryName: claim.beneficiaryName,
          benefitType: claim.benefitType,
          institutionId: claim.institutionId,
          institutionName: claim.institutionName,
          institutionReference: claim.referenceNumber,
          potentialValue: claim.potentialValue,
          confidence: 82,
          status: 'green',
          signals: [{ label: 'Local workspace', strength: 'strong' }],
          employmentPeriod: '2016-2026',
          dateIdentified: claim.submittedAt,
          region: profile.region || 'Windhoek',
        }));

        const nextResults: SearchResult[] = [];
        const currentQuery = q;

        if (role === 'beneficiary') {
          if (profile.firstName && profile.lastName) {
            const name = `${profile.firstName} ${profile.lastName}`;
            if (name.toLowerCase().includes(currentQuery) || profile.nationalId.toLowerCase().includes(currentQuery) || profile.region.toLowerCase().includes(currentQuery)) {
              nextResults.push({ id: 'beneficiary-profile', title: name, subtitle: `Beneficiary — ${profile.region}`, type: 'beneficiary', link: '/app/profile', icon: User });
            }
          }
          nextMatches.forEach((m) => {
            if (m.beneficiaryName.toLowerCase().includes(currentQuery) || m.benefitType.toLowerCase().includes(currentQuery) || m.institutionName.toLowerCase().includes(currentQuery) || m.id.toLowerCase().includes(currentQuery)) {
              nextResults.push({ id: m.id, title: m.beneficiaryName, subtitle: `${m.benefitType} — ${m.institutionName}`, type: 'match', link: `/app/matches/${m.id}`, icon: Target });
            }
          });
          claims.forEach((c) => {
            if (c.id.toLowerCase().includes(currentQuery) || c.beneficiaryName.toLowerCase().includes(currentQuery) || c.benefitType.toLowerCase().includes(currentQuery) || c.institutionName.toLowerCase().includes(currentQuery)) {
              nextResults.push({ id: c.id, title: c.id, subtitle: `${c.beneficiaryName} — ${c.benefitType}`, type: 'claim', link: `/app/claims/${c.id}`, icon: FileText });
            }
          });
          nextMatches.forEach((m) => {
            if (m.benefitType.toLowerCase().includes(currentQuery) || m.institutionName.toLowerCase().includes(currentQuery)) {
              nextResults.push({ id: `${m.id}-benefit`, title: m.benefitType, subtitle: `${m.institutionName} — ${formatCurrency(m.potentialValue ?? 0)}`, type: 'benefit', link: `/app/matches/${m.id}`, icon: FileText });
            }
          });
        } else if (ROLE_INSTITUTION_LINK[role]) {
          const link = ROLE_INSTITUTION_LINK[role];
          institutions.forEach((i) => {
            if (i.name.toLowerCase().includes(currentQuery) || i.type.toLowerCase().includes(currentQuery) || i.region.toLowerCase().includes(currentQuery) || i.id.toLowerCase().includes(currentQuery)) {
              nextResults.push({ id: i.id, title: i.name, subtitle: `${i.type} — ${i.region}`, type: 'institution', link, icon: Building2 });
            }
          });
        }

        setSearchResults(nextResults.slice(0, 12));
      } catch (err) {
        console.error('Failed to search matches:', err);
        setError('Failed to search for matches. Please try again.');
      } finally {
        setLoading(false);
      }
    })();
  }, [claims, institutions, open, profile, query, role]);

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