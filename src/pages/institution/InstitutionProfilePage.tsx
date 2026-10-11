import { Building2, MapPin, Globe, ShieldCheck, BarChart3, Info } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useApp } from '@/context/AppContext';
import { Card, CardHeader, CardBody } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Alert } from '@/components/ui/Alert';
import { institutionService } from '@/services';
import type { Institution } from '@/types';

function Field({ label, value, icon }: { label: string; value: string; icon?: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between py-3 border-b border-slate-100 last:border-0">
      <div className="flex items-center gap-2 text-sm text-slate-500">
        {icon}
        <span>{label}</span>
      </div>
      <span className="text-sm font-medium text-slate-800 text-right max-w-[60%]">{value}</span>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="bg-slate-50 rounded-lg px-4 py-3 border border-slate-100">
      <p className="text-xs text-slate-400">{label}</p>
      <p className="text-lg font-display font-semibold text-slate-800 mt-0.5">{value}</p>
    </div>
  );
}

// Institution Profile — displays real institutional information from the Pension Funds API
export function InstitutionProfilePage() {
  const { activeInstitutionId } = useApp();
  const [institution, setInstitution] = useState<Institution | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadInstitution = async () => {
      setLoading(true);
      setError(null);
      try {
        // Fetch all institutions and find the active one
        const institutions = await institutionService.getInstitutions();
        const inst = institutions.find(i => i.id === activeInstitutionId);

        if (inst) {
          setInstitution(inst);
        } else {
          setError('Institution not found');
        }
      } catch (err) {
        console.error('Failed to load institution data:', err);
        setError('Failed to load institution data. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    loadInstitution();
  }, [activeInstitutionId]);

  if (loading) {
    return (
      <div className="max-w-5xl mx-auto space-y-5">
        <div className="animate-shimmer h-96 rounded-xl" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-5xl mx-auto space-y-5">
        <Alert tone="error" title="Error Loading Institution">
          {error}
        </Alert>
      </div>
    );
  }

  if (!institution) {
    return (
      <div className="max-w-5xl mx-auto space-y-5">
        <Alert tone="warning" title="Institution Not Found">
          No institution data available for the selected institution.
        </Alert>
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto space-y-5">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
        <div className="flex items-start gap-4">
          <div className="w-12 h-12 rounded-xl bg-primary-100 flex items-center justify-center text-primary-700 font-semibold text-sm shrink-0">
            {institution.short.slice(0, 2).toUpperCase()}
          </div>
          <div>
            <h1 className="font-display text-2xl font-semibold text-slate-900">{institution.name}</h1>
            <p className="text-sm text-slate-500 mt-0.5 flex items-center gap-2 flex-wrap">
              <span className="inline-flex items-center gap-1"><MapPin className="w-3.5 h-3.5" />{institution.region}, Namibia</span>
              <span className="inline-flex items-center gap-1"><Building2 className="w-3.5 h-3.5" />{institution.type}</span>
            </p>
          </div>
        </div>
      </div>

      {/* Public institutional information */}
      <Card>
        <CardHeader
          title="Public Institutional Information"
          subtitle="Verified information from the Pension Funds API"
          action={<Globe className="w-5 h-5 text-slate-300" />}
        />
        <CardBody className="pt-1">
          <Field label="Institution name" value={institution.name} />
          <Field label="Institution type" value={institution.type} icon={<Building2 className="w-4 h-4" />} />
          <Field label="Country" value="Namibia" icon={<Globe className="w-4 h-4" />} />
          <Field label="Head office" value={institution.region} icon={<MapPin className="w-4 h-4" />} />
          <Field label="Status" value="Registered" icon={<ShieldCheck className="w-4 h-4" />} />
          <Field label="API Identifier" value={institution.id} />
        </CardBody>
      </Card>

      {/* Institution Statistics from API */}
      <Card>
        <CardHeader
          title="Institution Statistics"
          subtitle="Real-time statistics from the Pension Funds API"
          action={<BarChart3 className="w-5 h-5 text-slate-300" />}
        />
        <CardBody>
          <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
            <Stat label="Total Matches" value={institution.matches.toLocaleString()} />
            <Stat label="Total Claims" value={institution.claims.toLocaleString()} />
            <Stat label="Pending Review" value={institution.pendingReview.toLocaleString()} />
            <Stat label="Resolved Claims" value={institution.resolved.toLocaleString()} />
            <Stat label="Avg. Resolution (days)" value={`${institution.avgResolutionDays}`} />
          </div>
          {institution.matches === 0 && institution.claims === 0 && institution.pendingReview === 0 && institution.resolved === 0 && (
            <p className="mt-4 text-xs text-slate-400 flex items-start gap-1.5 leading-relaxed">
              <Info className="w-3.5 h-3.5 shrink-0 mt-0.5" />
              No activity data available yet for this institution. Statistics will appear as matches and claims are processed.
            </p>
          )}
        </CardBody>
      </Card>
    </div>
  );
}