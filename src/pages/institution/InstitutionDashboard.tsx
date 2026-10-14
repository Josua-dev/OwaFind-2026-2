import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { Target, FileText, CheckCircle2, Building2, Clock, WalletCards, Users } from 'lucide-react';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Alert } from '@/components/ui/Alert';
import { StateBadge } from '@/components/shared/Timeline';
import { institutionService, claimService } from '@/services';
import { formatCurrency, formatCurrencyShort, timeAgo } from '@/utils/format';
import { useApp } from '@/context/AppContext';
import { syntheticWorkspace } from '@/data/synthetic';
import type { Claim, Institution } from '@/types';

export function InstitutionDashboard() {
  const { activeInstitutionId } = useApp();
  const [institutions, setInstitutions] = useState<Institution[]>([]);
  const [claims, setClaims] = useState<Claim[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      setError(null);
      try {
        const [instData, claimsData] = await Promise.all([
          institutionService.getInstitutions(),
          claimService.getClaims()
        ]);

        setInstitutions(instData);
        setClaims(claimsData);
      } catch (err) {
        console.error('Failed to load institution dashboard data:', err);
        setError('Failed to load dashboard data. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [activeInstitutionId]);

  if (loading) return <div className="animate-shimmer h-96 rounded-xl" />;

  if (error) {
    return (
      <Alert tone="error" title="Dashboard Error">
        {error}
      </Alert>
    );
  }

  const selectedInstitution = institutions.find((institution) => institution.id === activeInstitutionId);
  const institutionClaims = claims
    .filter((claim) => claim.institutionId === activeInstitutionId)
    .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  const institutionRecords = syntheticWorkspace.benefitRecords.filter(
    (record) => record.institutionId === activeInstitutionId,
  );
  const activeAccounts = institutionRecords.filter((record) => record.status === 'active').length;
  const unclaimedBalance = institutionRecords
    .filter((record) => record.status === 'unclaimed')
    .reduce((sum, record) => sum + record.approximateValue, 0);
  const institutionStats = selectedInstitution ?? {
    matches: 0,
    claims: 0,
    pendingReview: 0,
    resolved: 0,
    avgResolutionDays: 0,
  };

  const statCards = [
    { label: 'Account Records', value: institutionStats.matches.toLocaleString(), icon: Target, color: 'bg-primary-50 text-primary-600' },
    { label: 'Active Accounts', value: activeAccounts.toLocaleString(), icon: Users, color: 'bg-blue-50 text-blue-600' },
    { label: 'Claims', value: institutionStats.claims.toLocaleString(), icon: FileText, color: 'bg-success-50 text-success-600' },
    { label: 'Pending Review', value: institutionStats.pendingReview.toLocaleString(), icon: CheckCircle2, color: 'bg-warning-50 text-warning-600' },
    { label: 'Unclaimed Balance', value: formatCurrencyShort(unclaimedBalance), icon: WalletCards, color: 'bg-primary-50 text-primary-600' },
    { label: 'Avg Resolution', value: `${institutionStats.avgResolutionDays} days`, icon: Clock, color: 'bg-slate-100 text-slate-600' },
  ];

  return (
    <div className="max-w-screen-2xl mx-auto space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="font-display text-2xl font-bold text-slate-900">{selectedInstitution?.name ?? 'Institution Dashboard'}</h1>
          <p className="text-slate-500 mt-1">Synthetic performance summary for the selected institution</p>
        </div>
      </div>

      <Alert tone="info" title="About this dashboard">
        Institution names are catalogue labels; all records and metrics shown here are fictional synthetic data for this local workspace.
      </Alert>

      <div className="grid grid-cols-2 lg:grid-cols-6 gap-4">
        {statCards.map((s, i) => {
          const Icon = s.icon;
          return (
            <motion.div key={s.label} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.05 }}>
              <Card className="p-5">
                <div className={`w-10 h-10 rounded-xl ${s.color} flex items-center justify-center mb-3`}><Icon className="w-5 h-5" /></div>
                <p className="text-2xl font-bold font-display text-slate-900">{s.value}</p>
                <p className="text-sm text-slate-500 mt-0.5">{s.label}</p>
              </Card>
            </motion.div>
          );
        })}
      </div>

      <div className="grid lg:grid-cols-3 gap-6">
        <Card>
          <CardHeader
            title="Recent Claims Activity"
            subtitle={`${institutionClaims.length} claims for ${selectedInstitution?.short ?? selectedInstitution?.name ?? 'this institution'}`}
          />
          <CardBody className="pt-1">
            <div className="space-y-3">
              {institutionClaims.slice(0, 6).map((claim) => (
                <Link
                  key={claim.id}
                  to={`/app/claims/${claim.id}`}
                  className="flex items-center justify-between gap-3 py-2 border-b border-slate-50 last:border-0 hover:bg-slate-50 rounded-md px-2 -mx-2"
                >
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-slate-700 truncate">{claim.beneficiaryName}</p>
                    <p className="text-xs text-slate-400 truncate">{claim.id} · {timeAgo(claim.updatedAt)}</p>
                  </div>
                  <StateBadge state={claim.state} />
                </Link>
              ))}
              {institutionClaims.length === 0 && (
                <p className="text-center text-sm text-slate-400 py-4">No claims for this institution yet.</p>
              )}
            </div>
          </CardBody>
        </Card>
        <Card className="lg:col-span-2">
          <CardHeader title="Selected Institution" subtitle="Current local workspace selection" />
          <CardBody className="space-y-3">
            <p className="text-lg font-semibold text-slate-800">{selectedInstitution?.name ?? 'Institution not found'}</p>
            <p className="text-sm text-slate-500">{selectedInstitution?.region ?? '—'} · {selectedInstitution?.type ?? '—'}</p>
            <div className="grid grid-cols-2 gap-3 pt-2">
              <div className="rounded-lg bg-slate-50 p-3">
                <p className="text-xs text-slate-400">Resolved claims</p>
                <p className="text-xl font-semibold text-slate-800">{institutionStats.resolved.toLocaleString()}</p>
              </div>
              <div className="rounded-lg bg-slate-50 p-3">
                <p className="text-xs text-slate-400">Unclaimed account balance</p>
                <p className="text-xl font-semibold text-slate-800">{formatCurrency(unclaimedBalance)}</p>
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      <Card>
        <CardHeader title="Institution Comparison" subtitle={`${institutions.length} catalogue institutions · selected institution highlighted`} />
        <CardBody className="p-0">
          <div className="overflow-x-auto scrollbar-thin">
            <table className="w-full text-sm">
              <thead><tr className="text-left text-xs text-slate-400 border-b border-slate-100">
                <th className="px-4 py-3 font-medium">Institution</th>
                <th className="px-4 py-3 font-medium">Type</th>
                <th className="px-4 py-3 font-medium">Matches</th>
                <th className="px-4 py-3 font-medium">Claims</th>
                <th className="px-4 py-3 font-medium">Pending Review</th>
                <th className="px-4 py-3 font-medium">Avg Resolution Days</th>
              </tr></thead>
              <tbody>
                {institutions.map((inst) => (
                  <tr key={inst.id} className={`border-b border-slate-50 hover:bg-slate-50 transition-colors ${inst.id === activeInstitutionId ? 'bg-primary-50/70' : ''}`}>
                    <td className="px-4 py-3 font-medium text-slate-700">{inst.name}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.type}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.matches.toLocaleString()}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.claims}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.pendingReview}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.avgResolutionDays}</td>
                  </tr>
                ))}
                {institutions.length === 0 && (
                  <tr>
                    <td colSpan={6} className="px-4 py-3 text-center text-slate-400">
                      No institution data available yet. Data will appear as institutions are registered in the system.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}