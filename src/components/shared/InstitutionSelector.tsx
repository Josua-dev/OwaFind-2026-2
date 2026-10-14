import { useEffect, useRef, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Building2, ChevronDown, Check, MapPin } from 'lucide-react';
import { useApp } from '@/context/AppContext';
import { cn } from '@/utils/format';
import { institutionService } from '@/services';
import type { Institution } from '@/types';

// Presenter control: switch between real Namibian institutions from the
// Pension Funds API. All figures shown for any institution are real data
// from the API when available.
export function InstitutionSelector() {
  const { activeInstitutionId, setActiveInstitution } = useApp();
  const [open, setOpen] = useState(false);
  const [institutions, setInstitutions] = useState<Institution[]>([]);
  const [loading, setLoading] = useState(true);
  const ref = useRef<HTMLDivElement>(null);

  // Load institution data from API
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

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const current = institutions.find((i) => i.id === activeInstitutionId) || institutions[0];

  return (
    <div ref={ref} className="relative">
      <button
        onClick={() => setOpen((v) => !v)}
        aria-haspopup="listbox"
        aria-expanded={open}
        className="flex items-center gap-2 px-3 h-9 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 transition-colors max-w-[260px]"
      >
        <Building2 className="w-4 h-4 text-primary-600 shrink-0" />
        <span className="hidden xl:inline text-xs text-slate-400 shrink-0">Institution</span>
        <span className="text-sm font-medium text-slate-700 truncate">{current?.short ?? 'N/A'}</span>
        <ChevronDown className={cn('w-4 h-4 text-slate-400 transition-transform shrink-0', open && 'rotate-180')} />
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: -4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -4 }}
            transition={{ duration: 0.15 }}
            className="absolute right-0 mt-2 w-72 max-h-96 overflow-y-auto scrollbar-thin bg-white border border-slate-200 rounded-xl shadow-lg z-50 py-2"
            role="listbox"
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
                        setOpen(false);
                      }}
                      className={cn(
                        'w-full flex items-start gap-3 px-3 py-2 text-left hover:bg-slate-50 transition-colors',
                        selected && 'bg-primary-50'
                      )}
                    >
                      <div className="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center text-primary-700 font-semibold text-[11px] shrink-0 mt-0.5">
                        {inst.short.slice(0, 2).toUpperCase()}
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
                    ? 'No institution data available from the Pension Funds API.'
                    : 'Showing real institution data from the Pension Funds API.'}
                </p>
              </>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}