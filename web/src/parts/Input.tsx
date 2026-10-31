import { useEffect, useRef, useState, type ReactNode } from 'react';
import { nui, useKeys } from '../nui';
import type { InputData, InputRow } from '../types';

/** Custom dropdown: native <select> popups are unreliable in NUI. */
function Pick({ row, value, onChange }: { row: InputRow; value: number | null; onChange: (v: number) => void }) {
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState('');
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!open) return;
    const off = (e: MouseEvent) => { if (!ref.current?.contains(e.target as Node)) setOpen(false); };
    document.addEventListener('mousedown', off);
    return () => document.removeEventListener('mousedown', off);
  }, [open]);
  const opts = row.options || [];
  const cur = opts.find((o) => o.index === value);
  const list = q ? opts.filter((o) => o.label.toLowerCase().includes(q.toLowerCase())) : opts;
  return (
    <div className="ui-pick" ref={ref}>
      <button type="button" className="ui-field" disabled={row.disabled} onClick={() => { setOpen(!open); setQ(''); }}>
        <span>{cur ? cur.label : row.placeholder || 'Pick one'}</span><i className="fa-solid fa-chevron-down" />
      </button>
      {open ? (
        <div className="ui-pick__pop">
          {opts.length > 8 ? <input className="ui-field" autoFocus placeholder="Search…" value={q} onChange={(e) => setQ(e.target.value)} /> : null}
          {list.map((o) => (
            <button type="button" key={o.index} className={o.index === value ? 'is-on' : ''} onClick={() => { onChange(o.index); setOpen(false); }}>{o.label}</button>
          ))}
        </div>
      ) : null}
    </div>
  );
}

function initial(row: InputRow): unknown {
  switch (row.type) {
    case 'checkbox': return row.checked === true || row.default === true;
    case 'number': case 'slider': return typeof row.default === 'number' ? row.default : row.type === 'slider' ? row.min ?? 0 : '';
    case 'select': return typeof row.default === 'number' ? row.default : null;
    case 'multi-select': return Array.isArray(row.default) ? row.default : [];
    case 'color': return typeof row.default === 'string' ? row.default : '#ffffff';
    default: return row.default !== undefined && row.default !== null ? String(row.default) : '';
  }
}

export function InputDialog({ data, onDone }: { data: InputData; onDone: () => void }) {
  const [values, setValues] = useState<unknown[]>(() => data.rows.map(initial));
  const [tried, setTried] = useState(false);
  const set = (i: number, v: unknown) => setValues((prev) => prev.map((x, j) => (j === i ? v : x)));
  const missing = (i: number) => {
    const r = data.rows[i], v = values[i];
    if (!r.required) return false;
    if (r.type === 'multi-select') return !(v as unknown[]).length;
    return v === '' || v === null || v === undefined;
  };
  const submit = () => {
    setTried(true);
    if (data.rows.some((_, i) => missing(i))) return;
    const out = values.map((v, i) => {
      const r = data.rows[i];
      if (r.type === 'number' || r.type === 'slider') {
        if (v === '' || v === null) return null;
        let n = Number(v);
        if (typeof r.min === 'number') n = Math.max(r.min, n);
        if (typeof r.max === 'number') n = Math.min(r.max, n);
        return n;
      }
      return v;
    });
    nui('ui:inputSubmit', { values: out });
    onDone();
  };
  const cancel = () => {
    if (!data.allowCancel) return;
    nui('ui:inputSubmit', { cancel: true });
    onDone();
  };
  useKeys((e) => {
    if (e.key === 'Escape') { e.preventDefault(); cancel(); }
    if (e.key === 'Enter' && !(e.target instanceof HTMLTextAreaElement)) { e.preventDefault(); submit(); }
  });

  const field = (r: InputRow, i: number): ReactNode => {
    const v = values[i];
    switch (r.type) {
      case 'checkbox':
        return (
          <button type="button" className={`ui-check${v ? ' is-on' : ''}`} disabled={r.disabled} onClick={() => set(i, !v)}>
            <span className="ui-check__box"><i className="fa-solid fa-check" /></span>{r.label}
          </button>
        );
      case 'select':
        return <Pick row={r} value={v as number | null} onChange={(x) => set(i, x)} />;
      case 'multi-select':
        return (
          <div className="ui-chips">
            {(r.options || []).map((o) => {
              const on = (v as number[]).includes(o.index);
              return <button type="button" key={o.index} className={`ui-chip${on ? ' is-on' : ''}`} disabled={r.disabled}
                onClick={() => set(i, on ? (v as number[]).filter((x) => x !== o.index) : [...(v as number[]), o.index])}>{o.label}</button>;
            })}
          </div>
        );
      case 'slider': {
        const min = r.min ?? 0, max = r.max ?? 100;
        return (
          <div className="ui-slider">
            <input type="range" min={min} max={max} step={r.step ?? 1} value={Number(v)} disabled={r.disabled}
              style={{ ['--fill' as string]: `${((Number(v) - min) / (max - min || 1)) * 100}%` }} onChange={(e) => set(i, Number(e.target.value))} />
            <span className="mono">{String(v)}</span>
          </div>
        );
      }
      case 'textarea':
        return <textarea className="ui-field" rows={3} value={String(v)} placeholder={r.placeholder} disabled={r.disabled} onChange={(e) => set(i, e.target.value)} />;
      case 'color':
        return (
          <div className="ui-color">
            <span style={{ background: String(v) }} />
            <input className="ui-field mono" value={String(v)} maxLength={9} disabled={r.disabled} onChange={(e) => set(i, e.target.value)} />
          </div>
        );
      case 'number':
        return <input className="ui-field mono" type="number" min={r.min} max={r.max} step={r.step ?? 1} value={v as string | number} placeholder={r.placeholder} disabled={r.disabled}
          onChange={(e) => set(i, e.target.value === '' ? '' : Number(e.target.value))} />;
      case 'date':
        return <input className="ui-field mono" placeholder="YYYY-MM-DD" maxLength={10} value={String(v)} disabled={r.disabled} onChange={(e) => set(i, e.target.value)} />;
      default:
        return <input className="ui-field" type={r.password ? 'password' : 'text'} value={String(v)} placeholder={r.placeholder} disabled={r.disabled} onChange={(e) => set(i, e.target.value)} />;
    }
  };

  return (
    <div className="ui-layer">
      <section className="ui-panel ui-modal">
        <h2>{data.heading}</h2>
        <div className="ui-rows">
          {data.rows.map((r, i) => (
            <label key={i} className={`ui-rowfield${tried && missing(i) ? ' is-bad' : ''}`}>
              {r.type !== 'checkbox' ? <span className="ui-rowfield__label">{r.icon ? <i className={r.icon} /> : null} {r.label}{r.required ? <em>*</em> : null}</span> : null}
              {field(r, i)}
              {r.description ? <small>{r.description}</small> : null}
            </label>
          ))}
        </div>
        <div className="ui-actions">
          {data.allowCancel ? <button type="button" className="ui-btn" onClick={cancel}>Cancel</button> : null}
          <button type="button" className="ui-btn ui-btn--primary" onClick={submit}><i className="fa-solid fa-check" /> Confirm</button>
        </div>
      </section>
    </div>
  );
}
