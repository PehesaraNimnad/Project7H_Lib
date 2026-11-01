import type { Position, TimelineData } from '../types';

/** Task card with steps (P7H.UI.ShowTimeline): done steps are ticked and struck, the active one spins. */
export function Timeline({ data, position }: { data: TimelineData; position: Position }) {
  const done = data.steps.filter((s) => s.state === 'done').length;
  return (
    <div className={`ui-panel ui-timeline at-${data.position || position}`}>
      <header className="ui-tl-head">
        <span className="ui-tl-ico"><i className={data.icon} /></span>
        <div className="ui-tl-title"><b>{data.title}</b>{data.subtitle && <small>{data.subtitle}</small>}</div>
        <span className="ui-tl-count">{done}/{data.steps.length}</span>
      </header>
      <ol className="ui-tl-steps">
        {data.steps.map((s, i) => (
          <li key={i} className={`ui-tl-step is-${s.state}`}>
            <span className="ui-tl-dot">
              {s.state === 'done' ? <i className="fa-solid fa-check" /> : s.state === 'active' ? <i className="ui-tl-spin" /> : <i className="ui-tl-pip" />}
            </span>
            <div className="ui-tl-text">
              <b>{s.label}</b>
              {s.sub && <small>{s.sub}</small>}
              {s.state === 'active' && typeof s.progress === 'number' && (
                <span className="ui-tl-bar"><i style={{ width: `${Math.max(0, Math.min(100, s.progress))}%` }} /></span>
              )}
            </div>
          </li>
        ))}
      </ol>
    </div>
  );
}
