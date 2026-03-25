import { Injectable, signal } from '@angular/core';

export interface Toast {
  id: number;
  type: 'success' | 'error' | 'info';
  message: string;
}

@Injectable({ providedIn: 'root' })
export class ToastService {
  toasts = signal<Toast[]>([]);
  private _next = 0;

  private add(type: Toast['type'], message: string) {
    const id = ++this._next;
    this.toasts.update(t => [...t, { id, type, message }]);
    setTimeout(() => this.remove(id), 3000);
  }

  success(message: string) { this.add('success', message); }
  error(message: string)   { this.add('error', message); }
  info(message: string)    { this.add('info', message); }

  remove(id: number) {
    this.toasts.update(t => t.filter(x => x.id !== id));
  }
}
