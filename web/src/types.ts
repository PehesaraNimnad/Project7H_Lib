export type Position = 'top-right' | 'top-left' | 'top' | 'bottom' | 'bottom-right' | 'bottom-left' | 'center-right' | 'center-left' | 'center';

export interface Theme {
  preset: 'clay' | 'ink' | 'glass' | 'paper' | 'steel';
  accent: string;
  scale: number;
  radius: number;
  opacity: number;
  positions: { notify: Position; progress: Position; menu: Position; list: Position; textui: Position; timeline: Position };
  radial: { enabled: boolean; key: string };
}

export const DEFAULT_THEME: Theme = {
  preset: 'clay',
  accent: '#f4f4f5',
  scale: 1,
  radius: 1,
  opacity: 0.96,
  positions: { notify: 'top-right', progress: 'bottom', menu: 'center-right', list: 'top-left', textui: 'center-left', timeline: 'center-right' },
  radial: { enabled: false, key: 'Z' },
};

export interface NotifyData { id?: string; title?: string; description?: string; type: 'success' | 'error' | 'warning' | 'info'; duration: number; icon?: string; position?: Position }

export interface MenuOption {
  title: string;
  description?: string;
  icon?: string;
  iconColor?: string;
  disabled?: boolean;
  readOnly?: boolean;
  arrow?: boolean;
  progress?: number;
  image?: string;
  metadata?: { label: string; value?: string }[];
}
export interface MenuData { id: string; title: string; back: boolean; canClose: boolean; options: MenuOption[]; position?: Position }

export interface ListOption { label: string; description?: string; icon?: string; values?: string[]; defaultIndex?: number; checked?: boolean; progress?: number }
export interface ListData { id: string; title: string; position?: Position; options: ListOption[]; canClose: boolean; start: number }

export interface InputRow {
  type: 'input' | 'number' | 'checkbox' | 'select' | 'multi-select' | 'slider' | 'textarea' | 'color' | 'date';
  label: string;
  description?: string;
  placeholder?: string;
  icon?: string;
  required?: boolean;
  disabled?: boolean;
  password?: boolean;
  min?: number;
  max?: number;
  step?: number;
  default?: unknown;
  checked?: boolean;
  options?: { label: string; index: number }[];
}
export interface InputData { heading: string; rows: InputRow[]; allowCancel: boolean }
export interface AlertData { header: string; content: string; cancel: boolean; labels: { confirm?: string; cancel?: string } }
export interface ProgressData { label: string; duration: number; circle: boolean; canCancel: boolean; position?: Position; started: number }
export interface TextUIData { text: string; icon?: string; position?: Position; key?: string }
export interface RadialData { title?: string; back: boolean; items: { label: string; icon?: string; menu: boolean }[] }

export interface TimelineStep { label: string; sub?: string; state: 'done' | 'active' | 'todo'; progress?: number }
export interface TimelineData { id: string; title: string; subtitle?: string; icon: string; position?: Position; steps: TimelineStep[] }
