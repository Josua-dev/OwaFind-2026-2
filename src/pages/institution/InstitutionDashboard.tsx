import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Target, FileText, CheckCircle2, TrendingUp, Building2, ShieldAlert, Clock, Users } from 'lucide-react';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Alert } from '@/components/ui/Alert';
import { RecentActivityCard } from '@/components/shared/RecentActivity';
import { institutionService, auditService, claimService } from '@/services';
import { formatCurrencyShort, timeAgo } from '@/utils/format';
import type { Institution, AuditEvent, Claim } from '@/types';

export function InstitutionDashboard() {
  const [institutions, setInstitutions] = useState<Institution[]>([]);
  const [auditEvents, setAuditEvents] = useState<AuditEvent[]>([]);
  const [claims, setClaims] = useState<Claim[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      setError(null);
      try {
        // Fetch institution data, audit events, and claims in parallel
        const [instData, auditData, claimsData] = await Promise.all([
          institutionService.getInstitutions(),
          auditService.getAuditEvents(),
          claimService.getClaims()
        ]);

        setInstitutions(instData);
        setAuditEvents(auditData);
        setClaims(claimsData);
      } catch (err) {
        console.error('Failed to load institution dashboard data:', err);
        setError('Failed to load dashboard data. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  if (loading) return <div className="animate-shimmer h-96 rounded-xl" />;

  if (error) {
    return (
      <Alert tone="error" title="Dashboard Error">
        {error}
      </Alert>
    );
  }

  // Calculate claims per institution
  const claimsPerInstitution: Record<string, number> = {};
  claims.forEach(claim => {
    claimsPerInstitution[claim.institutionId] = (claimsPerInstitution[claim.institutionId] || 0) + 1;
  });

  // Update institution data with real claims counts
  const institutionsWithClaims = institutions.map(inst => ({
    ...inst,
    claims: claimsPerInstitution[inst.id] || 0
  }));

  // Calculate stats from institution data
  const totalMatches = institutionsWithClaims.reduce((sum, inst) => sum + inst.matches, 0);
  const totalClaims = institutionsWithClaims.reduce((sum, inst) => sum + inst.claims, 0);
  const totalPendingReview = institutionsWithClaims.reduce((sum, inst) => sum + inst.pendingReview, 0);
  const avgResolutionDays = institutionsWithClaims.length > 0
    ? Math.round(institutionsWithClaims.reduce((sum, inst) => sum + inst.avgResolutionDays, 0) / institutionsWithClaims.length)
    : 0;

  // Split audit events: institution/system activity vs beneficiary activity
  const systemEvents = auditEvents.filter(
    (e) => e.actor === 'System' || e.actor.includes('Officer')
  );
  const beneficiaryEvents = auditEvents.filter((e) =>
    e.actor !== 'System' && !e.actor.includes('Officer')
  );

  const statCards = [
    { label: 'Total Matches', value: totalMatches.toLocaleString(), icon: Target, color: 'bg-primary-50 text-primary-600' },
    { label: 'Total Claims', value: totalClaims.toLocaleString(), icon: FileText, color: 'bg-blue-50 text-blue-600' },
    { label: 'Pending Review', value: totalPendingReview.toLocaleString(), icon: CheckCircle2, color: 'bg-success-50 text-success-600' },
    { label: 'Avg Resolution', value: `${avgResolutionDays} days`, icon: Clock, color: 'bg-warning-50 text-warning-600' },
    { label: 'Active Institutions', value: institutionsWithClaims.length.toString(), icon: Building2, color: 'bg-slate-100 text-slate-600' },
    { label: 'Open Risk Alerts', value: '0', icon: ShieldAlert, color: 'bg-error-50 text-error-600' }, // Placeholder - risk data would come from riskService
  ];

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="font-display text-2xl font-bold text-slate-900">Institution Dashboard</h1>
          <p className="text-slate-500 mt-1">Overview of institution performance and match statistics</p>
        </div>
      </div>

      <Alert tone="info" title="About this dashboard">
        This dashboard displays real-time institution data from the Pension Funds API.
        Historical data will accumulate over time as the platform processes claims and monitors institutions.
      </Alert>

      {/* Platform-wide stats */}
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

      {/* What's happening */}
      <div className="grid lg:grid-cols-3 gap-6">
        <RecentActivityCard
          subtitle="Live institution and system activity"
          events={systemEvents}
          max={6}
        />

        <Card>
          <CardHeader
            title="Recent Beneficiary Activity"
            subtitle="Latest beneficiary actions"
          />
          <CardBody className="pt-1">
            <div className="space-y-3">
              {beneficiaryEvents.slice(0, 6).map((e) => (
                <div key={e.id} className="py-2 border-b border-slate-50 last:border-0">
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-xs text-slate-400">{timeAgo(e.timestamp)}</span>
                  </div>
                  <p className="text-xs text-slate-600 mt-1.5 leading-relaxed">{e.action}</p>
                </div>
              ))}
              {beneficiaryEvents.length === 0 && (
                <p className="text-center text-sm text-slate-400 py-4">No recent beneficiary activity</p>
              )}
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Institution Performance Table */}
      <Card>
        <CardHeader title="Institution Performance" subtitle={`${institutionsWithClaims.length} institutions tracked`} />
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
                {institutionsWithClaims.map((inst) => (
                  <tr key={inst.id} className="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                    <td className="px-4 py-3 font-medium text-slate-700">{inst.name}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.type}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.matches.toLocaleString()}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.claims}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.pendingReview}</td>
                    <td className="px-4 py-3 text-slate-600">{inst.avgResolutionDays}</td>
                  </tr>
                ))}
                {institutionsWithClaims.length === 0 && (
                  <tr>
                    <td colSpan="6" className="px-4 py-3 text-center text-slate-400">
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