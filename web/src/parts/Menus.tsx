import { useRef, useState } from 'react';
import { nui, useKeys } from '../nui';
import type { ListData, MenuData, Position } from '../types';

/* Context menu (mouse + keyboard) */
export function ContextMenu({ menu, position, blocked }: { menu: MenuData; position: Position; blocked: boolean }) {
  const usable = menu.options.map((o, i) => (!o.disabled && !o.readOnly ? i : -1)).filter((i) => i >= 0);
  const [hover, setHover] = useState(usable[0] ?? -1);
  const listRef = useRef<HTMLDivElement>(null);
  const select = (i: number) => {
    const o = menu.options[i];
    if (o && !o.disabled && !o.readOnly) nui('ui:menuSelect', { id: menu.id, index: i + 1 });
  };
  useKeys((e) => {
    if (blocked) return;
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      if (!usable.length) return;
      const at = usable.indexOf(hover);
      const next = e.key === 'ArrowDown' ? usable[(at + 1) % usable.length] : usable[(at - 1 + usable.length) % usable.length];
      setHover(next);
      listRef.current?.children[next]?.scrollIntoView({ block: 'nearest' });
    } else if (e.key === 'Enter') { e.preventDefault(); select(hover); }
    else if (e.key === 'Backspace' && menu.back) { e.preventDefault(); nui('ui:menuBack'); }
    else if (e.key === 'Escape' && menu.canClose) { e.preventDefault(); nui('ui:menuExit'); }
  });
  return (
    <section className={`ui-panel ui-menu at-${menu.position || position}`}>
      <header className="ui-menu__head">
        {menu.back ? <button type="button" className="ui-iconbtn" title="Back" onClick={() => nui('ui:menuBack')}><i className="fa-solid fa-chevron-left" /></button> : null}
        <h2>{menu.title}</h2>
        {menu.canClose ? <button type="button" className="ui-iconbtn" title="Close" onClick={() => nui('ui:menuExit')}><i className="fa-solid fa-xmark" /></button> : null}
      </header>
      <div className="ui-menu__list" ref={listRef}>
        {menu.options.map((o, i) => (
          <button type="button" key={i}
            className={`ui-opt${i === hover ? ' is-hover' : ''}${o.disabled ? ' is-disabled' : ''}${o.readOnly ? ' is-read' : ''}`}
            onMouseEnter={() => !o.disabled && !o.readOnly && setHover(i)} onClick={() => select(i)}>
            {o.image ? <img className="ui-opt__img" src={o.image} alt="" /> : o.icon ? <span className="ui-opt__icon"><i className={o.icon} style={o.iconColor ? { color: o.iconColor } : undefined} /></span> : null}
            <span className="ui-opt__text">
              <b>{o.title}</b>
              {o.description ? <small>{o.description}</small> : null}
              {o.metadata?.length ? (
                <span className="ui-opt__meta">{o.metadata.map((m, j) => <span key={j}>{m.label}{m.value !== undefined ? <em>{m.value}</em> : null}</span>)}</span>
              ) : null}
              {typeof o.progress === 'number' ? <span className="ui-bar"><span style={{ width: `${Math.max(0, Math.min(100, o.progress))}%` }} /></span> : null}
            </span>
            {o.arrow ? <i className="fa-solid fa-chevron-right ui-opt__arrow" /> : null}
          </button>
        ))}
      </div>
      <footer className="ui-menu__foot">
        <span><kbd>↑↓</kbd> move</span><span><kbd>ENTER</kbd> pick</span>{menu.back ? <span><kbd>⌫</kbd> back</span> : null}
      </footer>
    </section>
  );
}

/* List menu (keyboard only, side values and checkboxes, like lib.registerMenu) */
export function ListMenu({ menu, position, blocked }: { menu: ListData; position: Position; blocked: boolean }) {
  const [index, setIndex] = useState(Math.max(0, Math.min(menu.options.length - 1, (menu.start || 1) - 1)));
  const [scroll, setScroll] = useState<Record<number, number>>(() => Object.fromEntries(menu.options.map((o, i) => [i, o.defaultIndex || 1])));
  const [checks, setChecks] = useState<Record<number, boolean>>(() => Object.fromEntries(menu.options.map((o, i) => [i, !!o.checked])));
  const listRef = useRef<HTMLDivElement>(null);
  const move = (to: number) => {
    const n = (to + menu.options.length) % menu.options.length;
    setIndex(n);
    listRef.current?.children[n]?.scrollIntoView({ block: 'nearest' });
    nui('ui:listChange', { kind: 'move', index: n + 1, scroll: scroll[n] });
  };
  useKeys((e) => {
    if (blocked || !menu.options.length) return;
    const o = menu.options[index];
    if (e.key === 'ArrowDown') { e.preventDefault(); move(index + 1); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); move(index - 1); }
    else if ((e.key === 'ArrowLeft' || e.key === 'ArrowRight') && o.values?.length) {
      e.preventDefault();
      const len = o.values.length;
      const cur = scroll[index] || 1;
      const next = e.key === 'ArrowRight' ? (cur % len) + 1 : ((cur - 2 + len) % len) + 1;
      setScroll({ ...scroll, [index]: next });
      nui('ui:listChange', { kind: 'side', index: index + 1, scroll: next });
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (o.checked !== undefined) {
        const v = !checks[index];
        setChecks({ ...checks, [index]: v });
        nui('ui:listChange', { kind: 'check', index: index + 1, checked: v });
      } else nui('ui:listSelect', { index: index + 1, scroll: scroll[index] });
    } else if (e.key === 'Escape' || e.key === 'Backspace') {
      if (menu.canClose) { e.preventDefault(); nui('ui:listClose'); }
    }
  });
  const desc = menu.options[index]?.description;
  return (
    <section className={`ui-panel ui-list at-${menu.position || position}`}>
      <header className="ui-list__head"><h2>{menu.title}</h2><span>{index + 1}/{menu.options.length}</span></header>
      <div className="ui-list__rows" ref={listRef}>
        {menu.options.map((o, i) => (
          <div key={i} className={`ui-row${i === index ? ' is-on' : ''}`}>
            {o.icon ? <i className={`${o.icon} ui-row__icon`} /> : null}
            <span className="ui-row__label">{o.label}</span>
            {o.values?.length ? <span className="ui-row__values"><i className="fa-solid fa-chevron-left" />{o.values[(scroll[i] || 1) - 1]}<i className="fa-solid fa-chevron-right" /></span> : null}
            {o.checked !== undefined ? <span className={`ui-row__check${checks[i] ? ' is-on' : ''}`}><i className="fa-solid fa-check" /></span> : null}
            {typeof o.progress === 'number' ? <span className="ui-bar ui-row__bar"><span style={{ width: `${o.progress}%` }} /></span> : null}
          </div>
        ))}
      </div>
      {desc ? <footer className="ui-list__desc">{desc}</footer> : null}
    </section>
  );
}
