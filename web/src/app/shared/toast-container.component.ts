import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ToastService } from '../core/services/toast.service';

@Component({
  selector: 'app-toast-container',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="toast-container">
      @for (t of toast.toasts(); track t.id) {
        <div class="toast" [class]="'toast-' + t.type" (click)="toast.remove(t.id)">
          <span class="material-icons toast-icon">
            {{ t.type === 'success' ? 'check_circle' : t.type === 'error' ? 'error' : 'info' }}
          </span>
          <span class="toast-msg">{{ t.message }}</span>
        </div>
      }
    </div>
  `
})
export class ToastContainerComponent {
  toast = inject(ToastService);
}
