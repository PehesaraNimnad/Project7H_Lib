import { useEffect, useState } from 'react';
import { nui, useKeys } from '../nui';
import type { AlertData, NotifyData, Position, ProgressData, TextUIData } from '../types';

const TYPE_ICON: Record<NotifyData['type'], string> = {
  success: 'fa-solid fa-circle-check',
  error: 'fa-solid fa-circle-xmark',
  warning: 'fa-solid fa-triangle-exclamation',
  info: 'fa-solid fa-circle-info',
};

export interface NotifyItem extends NotifyData { key: number; leaving?: boolean }

/** Stack of notifications per position. */
export function Notifications({ items, position }: { items: NotifyItem[]; position: Position }) {
  const groups = new Map<Position, NotifyItem[]>();
  for (const n of items) {
    const p = n.position || position;
    groups.set(p, [...(groups.get(p) || []), n]);
  }
  return (
    <>
      {[...groups.entries()].map(([pos, list]) => (
        <div key={pos} className={`ui-notify-stack at-${pos}`}>
          {list.map((n) => (
            <div key={n.key} className={`ui-notify is-${n.type}${n.leaving ? ' is-leaving' : ''}`}>
              <span className="ui-notify__icon"><i className={n.icon || TYPE_ICON[n.type] || TYPE_ICON.info} /></span>
              <div className="ui-notify__text">
                {n.title ? <b>{n.title}</b> : null}
                {n.description ? <span>{n.description}</span> : null}
              </div>
              <span className="ui-notify__time" style={{ animationDuration: `${n.duration}ms` }} />
            </div>
          ))}
        </div>
      ))}
    </>
  );
}

export function Progress({ data, position }: { data: ProgressData; position: Position }) {
  const [now, setNow] = useState(performance.now());
  useEffect(() => {
    let raf = 0;
    const tick = () => { setNow(performance.now()); raf = requestAnimationFrame(tick); };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, []);
  const pct = Math.min(1, (now - data.started) / data.duration);
  const pos = data.position || position;
  if (data.circle) {
    const r = 26, c = 2 * Math.PI * r;
    return (
      <div className={`ui-progress ui-progress--circle at-${pos === 'bottom' ? 'bottom' : pos}`}>
        <div className="ui-ring">
          <svg viewBox="0 0 64 64">
            <circle cx="32" cy="32" r={r} className="track" />
            <circle cx="32" cy="32" r={r} className="fill" style={{ strokeDasharray: c, strokeDashoffset: c * (1 - pct) }} />
          </svg>
          <b>{Math.floor(pct * 100)}%</b>
        </div>
        {data.label ? <span className="ui-progress__label">{data.label}</span> : null}
        {data.canCancel ? <small><kbd>X</kbd> cancel</small> : null}
      </div>
    );
  }
  return (
    <div className={`ui-progress at-${pos}`}>
      <div className="ui-progress__top"><span>{data.label}</span><b>{Math.floor(pct * 100)}%</b></div>
      <div className="ui-bar ui-bar--big"><span style={{ width: `${pct * 100}%` }} /></div>
      {data.canCancel ? <small><kbd>X</kbd> cancel</small> : null}
    </div>
  );
}

export function TextUI({ data, position }: { data: TextUIData; position: Position }) {
  const m = data.text.match(/^\s*\[([^\]]+)\]\s*(.*)$/s);
  const key = data.key || (m ? m[1] : null);
  const text = m ? m[2] : data.text;
  return (
    <div className={`ui-textui at-${data.position || position}`}>
      {key ? <kbd className="ui-textui__key">{key}</kbd> : data.icon ? <span className="ui-textui__icon"><i className={data.icon} /></span> : null}
      <span className="ui-textui__text">{text.split(/\s{2}\n|\n/).map((l, i) => <span key={i}>{l}</span>)}</span>
    </div>
  );
}

/** Plain text with **bold** and line breaks (ox_lib dialogs take markdown). */
export function Rich({ text }: { text: string }) {
  return (
    <>
      {text.split('\n').map((line, i) => (
        <p key={i}>{line.split(/(\*\*[^*]+\*\*)/g).map((part, j) => (part.startsWith('**') && part.endsWith('**') ? <b key={j}>{part.slice(2, -2)}</b> : part))}</p>
      ))}
    </>
  );
}

export function Alert({ data, onDone }: { data: AlertData; onDone: () => void }) {
  const answer = (a: 'confirm' | 'cancel') => { nui('ui:alertAnswer', { answer: a }); onDone(); };
  useKeys((e) => {
    if (e.key === 'Escape' && data.cancel) { e.preventDefault(); answer('cancel'); }
    if (e.key === 'Enter') { e.preventDefault(); answer('confirm'); }
  });
  return (
    <div className="ui-layer">
      <section className="ui-panel ui-modal ui-modal--alert">
        {data.header ? <h2>{data.header}</h2> : null}
        <div className="ui-text"><Rich text={data.content} /></div>
        <div className="ui-actions">
          {data.cancel ? <button type="button" className="ui-btn" onClick={() => answer('cancel')}>{data.labels.cancel || 'Cancel'}</button> : null}
          <button type="button" className="ui-btn ui-btn--primary" onClick={() => answer('confirm')}>{data.labels.confirm || 'Confirm'}</button>
        </div>
      </section>
    </div>
  );
}
