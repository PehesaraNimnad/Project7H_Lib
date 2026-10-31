import { useRef, useState, type CSSProperties } from 'react';
import { isBrowser, send, useNuiMessage } from './nui';
import { DEFAULT_THEME, type AlertData, type InputData, type ListData, type MenuData, type NotifyData, type ProgressData, type RadialData, type TextUIData, type Theme } from './types';
import { Alert, Notifications, Progress, TextUI, type NotifyItem } from './parts/Small';
import { ContextMenu, ListMenu } from './parts/Menus';
import { InputDialog } from './parts/Input';
import { Radial } from './parts/Radial';

/** Dark or light text that reads on top of `hex`. */
function inkFor(hex: string) {
  const n = parseInt(hex.slice(1), 16);
  const lum = 0.2126 * ((n >> 16) & 255) + 0.7152 * ((n >> 8) & 255) + 0.0722 * (n & 255);
  return lum > 150 ? '#0b0b0b' : '#f7f7f8';
}

export default function App() {
  const [theme, setTheme] = useState<Theme>(DEFAULT_THEME);
  const [notes, setNotes] = useState<NotifyItem[]>([]);
  const [progress, setProgress] = useState<ProgressData | null>(null);
  const [menu, setMenu] = useState<MenuData | null>(null);
  const [menuKey, setMenuKey] = useState(0);
  const [list, setList] = useState<ListData | null>(null);
  const [listKey, setListKey] = useState(0);
  const [input, setInput] = useState<InputData | null>(null);
  const [alert, setAlert] = useState<AlertData | null>(null);
  const [text, setText] = useState<TextUIData | null>(null);
  const [radial, setRadial] = useState<RadialData | null>(null);
  const counter = useRef(0);

  const dropNote = (key: number) => {
    setNotes((n) => n.map((x) => (x.key === key ? { ...x, leaving: true } : x)));
    setTimeout(() => setNotes((n) => n.filter((x) => x.key !== key)), 260);
  };

  useNuiMessage(({ action, data }) => {
    switch (action) {
      case 'theme': setTheme({ ...DEFAULT_THEME, ...(data as Partial<Theme>) }); break;
      case 'notify': {
        const d = data as NotifyData;
        const key = ++counter.current;
        setNotes((n) => {
          // same id replaces the old one (e.g. a counter that updates)
          const kept = d.id ? n.filter((x) => x.id !== d.id) : n;
          return [...kept.slice(-5), { ...d, key }];
        });
        setTimeout(() => dropNote(key), d.duration || 4000);
        break;
      }
      case 'progress': setProgress({ ...(data as ProgressData), started: performance.now() }); break;
      case 'progressEnd': setProgress(null); break;
      case 'menu': setMenu(data as MenuData); setMenuKey((k) => k + 1); break;
      case 'menuClose': setMenu(null); break;
      case 'list': setList(data as ListData); setListKey((k) => k + 1); break;
      case 'listClose': setList(null); break;
      case 'input': setInput(data as InputData); break;
      case 'inputClose': setInput(null); break;
      case 'alert': setAlert(data as AlertData); break;
      case 'alertClose': setAlert(null); break;
      case 'textui': setText(data as TextUIData); break;
      case 'textuiHide': setText(null); break;
      case 'radial': setRadial(data as RadialData); break;
      case 'radialClose': setRadial(null); break;
    }
  });

  const modal = !!(input || alert);
  const style = {
    '--accent': theme.accent,
    '--accent-ink': inkFor(theme.accent),
    '--scale': theme.scale,
    '--rs': theme.radius,
    '--op': theme.opacity,
  } as CSSProperties;

  return (
    <div className="ui-root" data-preset={theme.preset} style={style}>
      <Notifications items={notes} position={theme.positions.notify} />
      {text ? <TextUI data={text} position={theme.positions.textui} /> : null}
      {progress ? <Progress data={progress} position={theme.positions.progress} /> : null}
      {list ? <ListMenu key={listKey} menu={list} position={theme.positions.list} blocked={modal} /> : null}
      {menu ? <ContextMenu key={menuKey} menu={menu} position={theme.positions.menu} blocked={modal} /> : null}
      {radial ? <Radial data={radial} /> : null}
      {input ? <InputDialog data={input} onDone={() => setInput(null)} /> : null}
      {alert ? <Alert data={alert} onDone={() => setAlert(null)} /> : null}
    </div>
  );
}

/* ---------------- browser preview: ?demo=all|notify|menu|list|input|alert|progress|circle|textui|radial &preset= &accent= ---------------- */
if (isBrowser) {
  const q = new URLSearchParams(location.search);
  const demo = q.get('demo') || 'all';
  const on = (k: string) => demo === 'all' || demo.split(',').includes(k);
  document.body.style.background = 'radial-gradient(ellipse 16% 34% at 50% 52%, #c9b8a6 0%, #6c5b4e 55%, transparent 100%), radial-gradient(ellipse at 50% 45%, #7d8a8f 0%, #3d4a52 50%, #1b2227 90%)';
  setTimeout(() => {
    if (q.get('preset') || q.get('accent')) send('theme', { ...DEFAULT_THEME, preset: q.get('preset') || 'clay', accent: q.get('accent') ? `#${q.get('accent')}` : DEFAULT_THEME.accent });
    if (on('notify')) {
      send('notify', { title: 'Vehicle stored', description: 'Pegassi Zentorno is parked in Pillbox Garage.', type: 'success', duration: 60000 });
      send('notify', { description: 'You do not have enough money.', type: 'error', duration: 60000 });
      send('notify', { title: 'Police', description: 'Someone reported a robbery nearby.', type: 'warning', duration: 60000 });
    }
    if (on('textui')) send('textui', { text: '[E] Open garage' });
    if (on('progress')) send('progress', { label: 'Repairing the engine', duration: 60000, circle: false, canCancel: true });
    if (on('circle')) send('progress', { label: 'Lockpicking', duration: 60000, circle: true, canCancel: true });
    if (on('menu')) send('menu', { id: 'demo', title: 'Pillbox Garage', back: true, canClose: true, options: [
      { title: 'Pegassi Zentorno', description: 'Plate 07AB1234 · in garage', icon: 'fa-solid fa-car', arrow: true, metadata: [{ label: 'Fuel', value: '82%' }, { label: 'Engine', value: '97%' }], progress: 82 },
      { title: 'Karin Sultan RS', description: 'Shared with you', icon: 'fa-solid fa-car-side', arrow: true },
      { title: 'Park vehicle', icon: 'fa-solid fa-square-parking' },
      { title: 'Impounded cars', description: 'Go to the depot', icon: 'fa-solid fa-truck-pickup', disabled: true },
    ] });
    if (on('list')) send('list', { id: 'l', title: 'Vehicle options', canClose: true, start: 1, options: [
      { label: 'Livery', icon: 'fa-solid fa-paintbrush', values: ['Stock', 'Racing', 'Police'], defaultIndex: 2, description: 'Changes the livery right away' },
      { label: 'Neon lights', icon: 'fa-solid fa-lightbulb', checked: true },
      { label: 'Engine sound', icon: 'fa-solid fa-volume-high', values: ['Stock', 'V8', 'V12'] },
      { label: 'Repair', icon: 'fa-solid fa-wrench', progress: 60 },
    ] });
    if (on('input')) send('input', { heading: 'Transfer money', allowCancel: true, rows: [
      { type: 'number', label: 'Amount', min: 1, max: 100000, required: true, default: 2500 },
      { type: 'select', label: 'Account', options: [{ label: 'Cash', index: 1 }, { label: 'Bank', index: 2 }], default: 2 },
      { type: 'checkbox', label: 'Send a receipt', checked: true },
      { type: 'input', label: 'Note', placeholder: 'Optional' },
    ] });
    if (on('alert')) send('alert', { header: 'Sell this vehicle?', content: 'You get **$45,000** and the car is gone.\nThis cannot be undone.', cancel: true, labels: { confirm: 'Sell' } });
    if (on('radial')) send('radial', { back: false, items: [
      { label: 'Vehicle', icon: 'fa-solid fa-car', menu: true }, { label: 'Walk style', icon: 'fa-solid fa-person-walking', menu: true }, { label: 'Emotes', icon: 'fa-solid fa-face-smile', menu: true },
      { label: 'Garage', icon: 'fa-solid fa-warehouse', menu: false }, { label: 'Clothing', icon: 'fa-solid fa-shirt', menu: true }, { label: 'Phone', icon: 'fa-solid fa-mobile-screen', menu: false },
    ] });
  }, 200);
}

