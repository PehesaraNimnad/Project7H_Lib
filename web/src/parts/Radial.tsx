import { useState } from 'react';
import { nui, useKeys } from '../nui';
import type { RadialData } from '../types';

/** Pie of up to 8 items per page; the mouse picks the slice, the centre goes back / closes. */
export function Radial({ data }: { data: RadialData }) {
  const [page, setPage] = useState(0);
  const [hover, setHover] = useState(-1);
  const per = 8;
  const pages = Math.max(1, Math.ceil(data.items.length / per));
  const items = data.items.slice(page * per, page * per + per);
  const n = Math.max(items.length, 3);
  const R = 150, r0 = 58;
  const slice = (i: number) => {
    const a0 = (i / n) * Math.PI * 2 - Math.PI / 2 - Math.PI / n;
    const a1 = a0 + (Math.PI * 2) / n;
    const p = (a: number, rad: number) => `${200 + Math.cos(a) * rad} ${200 + Math.sin(a) * rad}`;
    const large = a1 - a0 > Math.PI ? 1 : 0;
    return `M ${p(a0, r0)} L ${p(a0, R)} A ${R} ${R} 0 ${large} 1 ${p(a1, R)} L ${p(a1, r0)} A ${r0} ${r0} 0 ${large} 0 ${p(a0, r0)} Z`;
  };
  const center = (i: number) => {
    const a = (i / n) * Math.PI * 2 - Math.PI / 2;
    return { x: 200 + Math.cos(a) * ((R + r0) / 2), y: 200 + Math.sin(a) * ((R + r0) / 2) };
  };
  const pick = (i: number) => nui('ui:radialSelect', { index: page * per + i + 1 });
  useKeys((e) => {
    if (e.key === 'Escape') { e.preventDefault(); nui('ui:radialClose'); }
    if (e.key === 'Backspace') { e.preventDefault(); nui('ui:radialBack'); }
    if (/^[1-8]$/.test(e.key) && items[Number(e.key) - 1]) pick(Number(e.key) - 1);
  });
  return (
    <div className="ui-radial" onWheel={(e) => pages > 1 && setPage((page + (e.deltaY > 0 ? 1 : pages - 1)) % pages)}>
      <svg viewBox="0 0 400 400" className="ui-radial__svg">
        {items.map((_, i) => (
          <g key={`${page}-${i}`} className={`ui-radial__slice${hover === i ? ' is-on' : ''}`} onMouseEnter={() => setHover(i)} onMouseLeave={() => setHover(-1)} onClick={() => pick(i)}>
            <path d={slice(i)} />
          </g>
        ))}
        <circle cx="200" cy="200" r={r0 - 6} className="ui-radial__core" onClick={() => nui(data.back ? 'ui:radialBack' : 'ui:radialClose')} />
      </svg>
      {items.map((it, i) => {
        const c = center(i);
        return (
          <div key={`l${page}-${i}`} className={`ui-radial__label${hover === i ? ' is-on' : ''}`} style={{ left: `${(c.x / 400) * 100}%`, top: `${(c.y / 400) * 100}%` }}>
            {it.icon ? <i className={it.icon} /> : null}
            <span>{it.label}</span>
            {it.menu ? <i className="fa-solid fa-ellipsis ui-radial__more" /> : null}
          </div>
        );
      })}
      <div className="ui-radial__center">
        <i className={`fa-solid ${data.back ? 'fa-arrow-left' : 'fa-xmark'}`} />
        <small>{hover >= 0 ? items[hover]?.label : data.title || (pages > 1 ? `${page + 1}/${pages}` : '')}</small>
      </div>
    </div>
  );
}
