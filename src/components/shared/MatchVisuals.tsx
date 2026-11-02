import { cn } from '@/utils/format';
import type { SignalStrength, MatchStatus } from '@/types';

const signalConfig: Record<SignalStrength, { label: string; color: string }> = {
  exact: { label: 'Exact match', color: 'text-primary-700 bg-primary-50' },
  strong: { label: 'Strong match', color: 'text-primary-700 bg-primary-50' },
  partial: { label: 'Partial match', color: 'text-slate-600 bg-slate-100' },
  weak: { label: 'Weak match', color: 'text-slate-600 bg-slate-100' },
  none: { label: 'No match', color: 'text-slate-500 bg-slate-100' },
};

export function SignalBadge({ strength }: { strength: SignalStrength }) {
  const config = signalConfig[strength];
  return (
    <span className={cn('inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium', config.color)}>
      {config.label}
    </span>
  );
}

const statusConfig: Record<MatchStatus, { label: string; color: string; ring: string; bg: string }> = {
  green: { label: 'Strong Potential Match', color: 'text-primary-700', ring: 'ring-primary-200', bg: 'bg-primary-50' },
  amber: { label: 'More Information Required', color: 'text-slate-700', ring: 'ring-slate-200', bg: 'bg-slate-50' },
  red: { label: 'Low-Confidence Match', color: 'text-slate-500', ring: 'ring-slate-200', bg: 'bg-slate-50' },
};

export function MatchStatusBadge({ status }: { status: MatchStatus }) {
  const config = statusConfig[status];
  return (
    <span className={cn('inline-flex items-center gap-1.5 rounded-lg px-3 py-1 text-sm font-medium ring-1 ring-inset', config.color, config.ring, config.bg)}>
      <span className={cn('w-2 h-2 rounded-full', status === 'green' ? 'bg-primary-600' : status === 'amber' ? 'bg-slate-500' : 'bg-slate-300')} />
      {config.label}
    </span>
  );
}

export function ConfidenceScore({ score, className }: { score: number; className?: string }) {
  const color = score >= 80 ? 'text-primary-700' : 'text-slate-600';
  const barColor = score >= 80 ? 'bg-primary-600' : score >= 50 ? 'bg-slate-500' : 'bg-slate-300';
  return (
    <div className={cn('flex items-center gap-3', className)}>
      <div className="flex items-baseline gap-1">
        <span className={cn('text-2xl font-bold font-display', color)}>{score}%</span>
        <span className="text-xs text-slate-400">match</span>
      </div>
      <div className="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden max-w-[120px]">
        <div className={cn('h-full rounded-full transition-all duration-700', barColor)} style={{ width: `${score}%` }} />
      </div>
    </div>
  );
}
