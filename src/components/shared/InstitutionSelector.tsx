import { useCallback, useEffect, useRef, useState } from 'react';
import { Building2, ChevronDown, Check, MapPin } from 'lucide-react';
import { useApp } from '@/context/AppContext';
import { cn } from '@/utils/format';
import { institutionService } from '@/services';
import type { Institution } from '@/types';
import { FloatingPopover } from '@/components/shared/FloatingPopover';

// Switch between institution catalogue entries with local synthetic figures.
export function InstitutionSelector() {
  const { activeInstitutionId, setActiveInstitution } = useApp();
  const [open, setOpen] = useState(false);
  const [institutions, setInstitutions] = useState<Institution[]>([]);
  const [loading, setLoading] = useState(true);
  const ref = useRef<HTMLDivElement>(null);
  const close = useCallback(() => setOpen(false), []);

  // Load the local synthetic institution catalogue.
  useEffect(() => {
    const loadInstitutions = async () => {
      setLoading(true);
      try {
        const data = await institutionService.getInstitutions();
        setInstitutions(data);
      } catch (err) {
        console.error('Failed to load institutions:', err);
        setInstitutions([]);
      } finally {
        setLoading(false);
      }
    };

    loadInstitutions();
  }, []);

  const current = institutions.find((i) => i.id === activeInstitutionId) || institutions[0];

  return (
    <div ref={ref} className="relative">
      <button
        onClick={() => setOpen((v) => !v)}
        aria-label={`Select institution. Current institution: ${current?.name ?? 'Unavailable'}`}
        aria-haspopup="listbox"
        aria-expanded={open}
        className="flex min-w-0 items-center gap-2 px-3 h-9 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 transition-colors max-w-[260px]"
      >
        <Building2 className="w-4 h-4 text-primary-600 shrink-0" />
        <span className="hidden xl:inline text-xs text-slate-400 shrink-0">Institution</span>
        <span className="min-w-0 text-sm font-medium text-slate-700 truncate">{current?.short ?? 'N/A'}</span>
        <ChevronDown className={cn('w-4 h-4 text-slate-400 transition-transform shrink-0', open && 'rotate-180')} />
      </button>

      <FloatingPopover
        open={open}
        anchorRef={ref}
        onClose={close}
        width={288}
        maxHeight={384}
        label="Namibian Institutions"
        panelRole="listbox"
        className="overflow-y-auto scrollbar-thin bg-white border border-slate-200 rounded-xl shadow-lg py-2"
      >
            <p className="px-3 pb-2 text-xs font-semibold text-slate-400 uppercase tracking-wide">
              Namibian Institutions
            </p>
            {loading ? (
              <div className="text-center py-4">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto" />
              </div>
            ) : institutions.length === 0 ? (
              <div className="text-center py-4">
                <p className="text-sm text-slate-400">No institution data available</p>
              </div>
            ) : (
              <>
                {institutions.map((inst) => {
                  const selected = inst.id === activeInstitutionId;
                  return (
                    <button
                      key={inst.id}
                      role="option"
                      aria-selected={selected}
                      onClick={() => {
                        setActiveInstitution(inst.id);
                        close();
                      }}
                      className={cn(
                        'w-full flex items-start gap-3 px-3 py-2 text-left hover:bg-slate-50 transition-colors',
                        selected && 'bg-primary-50'
                      )}
                    >
                      <div className="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center text-primary-700 font-semibold text-[11px] shrink-0 mt-0.5">
                        {(inst.short ?? inst.name).slice(0, 2).toUpperCase()}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className={cn('text-sm font-medium truncate', selected ? 'text-primary-700' : 'text-slate-700')}>
                          {inst.name}
                        </p>
                        <p className="text-xs text-slate-400 flex items-center gap-1 mt-0.5">
                          <MapPin className="w-3 h-3" />
                          {inst.region} · {inst.type}
                        </p>
                      </div>
                      {selected && <Check className="w-4 h-4 text-primary-600 shrink-0 mt-1" />}
                    </button>
                  );
                })}
                <p className="px-3 pt-2 mt-1 border-t border-slate-100 text-[11px] text-slate-400 leading-snug">
                  {institutions.length === 0
                    ? 'No local institution data is available.'
                    : 'Catalogue names only; all associated records and metrics are fictional.'}
                </p>
              </>
            )}
      </FloatingPopover>
    </div>
  );
}