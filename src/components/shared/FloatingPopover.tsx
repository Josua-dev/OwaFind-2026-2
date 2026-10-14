import { AnimatePresence, motion } from 'framer-motion';
import { useLayoutEffect, useRef, useState, type AriaRole, type ReactNode, type RefObject } from 'react';
import { createPortal } from 'react-dom';

interface FloatingPopoverProps {
  open: boolean;
  anchorRef: RefObject<HTMLElement>;
  onClose: () => void;
  width: number;
  maxHeight: number;
  label: string;
  panelRole?: AriaRole;
  className: string;
  children: ReactNode;
}

interface Placement {
  top: number;
  left: number;
  width: number;
  maxHeight: number;
}

export function FloatingPopover({
  open,
  anchorRef,
  onClose,
  width,
  maxHeight,
  label,
  panelRole = 'region',
  className,
  children,
}: FloatingPopoverProps) {
  const panelRef = useRef<HTMLDivElement>(null);
  const [placement, setPlacement] = useState<Placement | null>(null);

  useLayoutEffect(() => {
    if (!open) {
      setPlacement(null);
      return;
    }

    const updatePlacement = () => {
      const anchor = anchorRef.current;
      const panel = panelRef.current;
      if (!anchor || !panel) return;

      const viewportWidth = document.documentElement.clientWidth;
      const viewportHeight = window.innerHeight;
      const panelWidth = Math.min(width, viewportWidth - 16);
      panel.style.width = `${panelWidth}px`;

      const anchorRect = anchor.getBoundingClientRect();
      const roomBelow = Math.max(0, viewportHeight - anchorRect.bottom - 8);
      const roomAbove = Math.max(0, anchorRect.top - 8);
      const placeAbove = roomBelow < Math.min(panel.scrollHeight, maxHeight) && roomAbove > roomBelow;
      const availableHeight = Math.max(0, Math.min(maxHeight, placeAbove ? roomAbove : roomBelow));
      const panelHeight = Math.min(panel.scrollHeight, availableHeight);
      const left = Math.max(8, Math.min(anchorRect.right - panelWidth, viewportWidth - panelWidth - 8));

      setPlacement({
        top: placeAbove ? anchorRect.top - panelHeight - 8 : anchorRect.bottom + 8,
        left,
        width: panelWidth,
        maxHeight: availableHeight,
      });
    };

    const handleOutsidePointer = (event: PointerEvent) => {
      const target = event.target as Node;
      if (!anchorRef.current?.contains(target) && !panelRef.current?.contains(target)) {
        onClose();
      }
    };
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };

    updatePlacement();
    window.addEventListener('resize', updatePlacement);
    window.addEventListener('scroll', updatePlacement, true);
    document.addEventListener('pointerdown', handleOutsidePointer);
    document.addEventListener('keydown', handleKeyDown);

    const resizeObserver = panelRef.current && typeof ResizeObserver !== 'undefined'
      ? new ResizeObserver(updatePlacement)
      : null;
    if (panelRef.current) resizeObserver?.observe(panelRef.current);

    return () => {
      window.removeEventListener('resize', updatePlacement);
      window.removeEventListener('scroll', updatePlacement, true);
      document.removeEventListener('pointerdown', handleOutsidePointer);
      document.removeEventListener('keydown', handleKeyDown);
      resizeObserver?.disconnect();
    };
  }, [anchorRef, maxHeight, onClose, open, width]);

  if (typeof document === 'undefined') return null;

  return createPortal(
    <AnimatePresence>
      {open && (
        <motion.div
          ref={panelRef}
          initial={{ opacity: 0, y: 8, scale: 0.96 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 8, scale: 0.96 }}
          transition={{ duration: 0.15 }}
          role={panelRole}
          aria-label={label}
          className={className}
          style={{
            position: 'fixed',
            top: placement?.top ?? 0,
            left: placement?.left ?? 0,
            width: placement?.width ?? Math.min(width, 320),
            maxHeight: placement?.maxHeight ?? 0,
            visibility: placement ? 'visible' : 'hidden',
            zIndex: 100,
          }}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>,
    document.body
  );
}
