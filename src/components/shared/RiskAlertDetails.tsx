import { Modal } from '@/components/ui/Modal';
import { Badge } from '@/components/ui/Badge';
import { formatDateTime } from '@/utils/format';
import type { RiskAlert } from '@/types';

interface RiskAlertDetailsProps {
  alert: RiskAlert | null;
  onClose: () => void;
}

const severityVariant: Record<RiskAlert['severity'], 'default' | 'warning' | 'error'> = {
  low: 'default',
  medium: 'warning',
  high: 'error',
};

export function RiskAlertDetails({ alert, onClose }: RiskAlertDetailsProps) {
  return (
    <Modal
      open={alert !== null}
      onClose={onClose}
      title={alert ? `Risk Alert — ${alert.id}` : 'Risk Alert'}
    >
      {alert && (
        <div className="space-y-4">
          <div className="flex flex-wrap gap-2">
            <Badge variant={severityVariant[alert.severity]} dot>{alert.severity} severity</Badge>
            <Badge variant={alert.status === 'resolved' ? 'success' : alert.status === 'reviewing' ? 'warning' : 'info'}>
              {alert.status.replace(/_/g, ' ')}
            </Badge>
          </div>
          <div>
            <p className="text-xs font-medium uppercase tracking-wide text-slate-400">Alert type</p>
            <p className="mt-1 text-sm text-slate-700">{alert.type.replace(/_/g, ' ')}</p>
          </div>
          <div>
            <p className="text-xs font-medium uppercase tracking-wide text-slate-400">Synthetic alert details</p>
            <p className="mt-1 text-sm leading-relaxed text-slate-700">{alert.description}</p>
          </div>
          {alert.claimId && (
            <div>
              <p className="text-xs font-medium uppercase tracking-wide text-slate-400">Related claim reference</p>
              <p className="mt-1 font-mono text-sm text-slate-700">{alert.claimId}</p>
            </div>
          )}
          {alert.matchId && (
            <div>
              <p className="text-xs font-medium uppercase tracking-wide text-slate-400">Related match reference</p>
              <p className="mt-1 font-mono text-sm text-slate-700">{alert.matchId}</p>
            </div>
          )}
          <div>
            <p className="text-xs font-medium uppercase tracking-wide text-slate-400">Recorded</p>
            <p className="mt-1 text-sm text-slate-700">{formatDateTime(alert.createdAt)}</p>
          </div>
          <p className="border-t border-slate-100 pt-3 text-xs text-slate-400">
            This is fictional risk-alert data in the local synthetic workspace, not a verified institutional finding.
          </p>
        </div>
      )}
    </Modal>
  );
}
