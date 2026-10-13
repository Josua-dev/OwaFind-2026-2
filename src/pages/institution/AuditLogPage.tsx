import { useEffect, useState } from 'react';
import { ScrollText } from 'lucide-react';
import { Card, CardBody, CardHeader } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Search } from 'lucide-react';
import { Alert } from '@/components/ui/Alert';
import { auditService } from '@/services';
import { formatDateTime } from '@/utils/format';
import type { AuditEvent } from '@/types';

export function AuditLogPage() {
  const [events, setEvents] = useState<AuditEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState('');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadAuditEvents = async () => {
      setLoading(true);
      setError(null);
      try {
        const eventData = await auditService.getAuditEvents();
        setEvents(eventData);
      } catch (err) {
        console.error('Failed to load audit events:', err);
        setError('Failed to load audit log data. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    loadAuditEvents();
  }, []);

  if (loading) return <div className="animate-shimmer h-96 rounded-xl" />;

  if (error) {
    return (
      <div className="max-w-4xl mx-auto space-y-6">
        <Alert tone="error" title="Error Loading Audit Log">
          {error}
        </Alert>
      </div>
    );
  }

  const filtered = events.filter((e) =>
    !query || e.action.toLowerCase().includes(query.toLowerCase()) ||
    e.actor.toLowerCase().includes(query.toLowerCase()) ||
    e.target.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="font-display text-2xl font-bold text-slate-900">Audit Log</h1>
        <p className="text-slate-500 mt-1">All system and user actions are tracked</p>
      </div>

      <Alert tone="info" title="Audit Log Data Source">
        This page displays synthetic audit events generated for the local workspace. The log is fictional
        and is not a real institutional audit trail.
      </Alert>

      <Input placeholder="Search audit events..." value={query} onChange={(e) => setQuery(e.target.value)} icon={<Search className="w-4 h-4" />} />

      <Card>
        <CardHeader title="Activity Log" subtitle={`${filtered.length} events`} />
        <CardBody className="p-0">
          {events.length > 0 ? (
            <div className="divide-y divide-slate-50">
              {filtered.map((event) => (
                <div key={event.id} className="flex items-start gap-3 p-4">
                  <div className="w-9 h-9 rounded-lg bg-slate-100 flex items-center justify-center shrink-0">
                    <ScrollText className="w-4 h-4 text-slate-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-slate-800">
                      <span className="font-medium">{event.actor}</span> {event.action.toLowerCase()} <span className="font-mono text-xs text-primary-600">{event.target}</span>
                    </p>
                    <p className="text-xs text-slate-400 mt-0.5">{event.details}</p>
                    <p className="text-xs text-slate-300 mt-1">{formatDateTime(event.timestamp)}</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <p className="text-slate-500">No synthetic audit events are currently available in this workspace.</p>
              <p className="text-xs text-slate-400 mt-2">
                Local audit events will appear as fictional claims, matches, and review actions are created.
              </p>
            </div>
          )}
        </CardBody>
      </Card>
    </div>
  );
}