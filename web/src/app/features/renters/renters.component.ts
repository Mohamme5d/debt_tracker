import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { Renter } from '../../core/models';

@Component({
  selector: 'app-renters',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('renters') }}</h2>
      <button class="btn btn-primary" (click)="openModal()">
        <span class="material-icons">add</span> {{ lang.t('addRenter') }}
      </button>
    </div>

    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('name') }}</th>
            <th>{{ lang.t('phone') }}</th>
            <th>{{ lang.t('email') }}</th>
            <th>{{ lang.t('status') }}</th>
            <th class="col-actions"></th>
          </tr>
        </thead>
        <tbody>
          @for (r of renters(); track r.id) {
            <tr>
              <td>{{ r.name }}</td>
              <td>{{ r.phone || '—' }}</td>
              <td>{{ r.email || '—' }}</td>
              <td>
                <span class="badge" [class]="statusClass(r.status)">
                  {{ lang.t(r.status?.toLowerCase() || 'pending') }}
                </span>
              </td>
              <td class="col-actions">
                <button class="btn-icon" (click)="openModal(r)" [title]="lang.t('edit')">
                  <span class="material-icons">edit</span>
                </button>
                @if (isOwner()) {
                  <button class="btn-icon btn-icon-warn" (click)="delete(r.id)" [title]="lang.t('delete')">
                    <span class="material-icons">delete</span>
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!renters().length) {
        <div class="empty-state">{{ lang.t('noRentersYet') }}</div>
      }
    </div>

    @if (showModal()) {
      <div class="modal-overlay" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>{{ editItem() ? lang.t('editRenter') : lang.t('addRenter') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('name') }} *</label>
                <input class="form-control" formControlName="name">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('phone') }}</label>
                <input class="form-control" formControlName="phone">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('email') }}</label>
                <input class="form-control" type="email" formControlName="email">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('notes') }}</label>
                <textarea class="form-control" formControlName="notes"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" (click)="closeModal()">{{ lang.t('cancel') }}</button>
            <button class="btn btn-primary" (click)="save()" [disabled]="form.invalid">{{ lang.t('save') }}</button>
          </div>
        </div>
      </div>
    }
  `
})
export class RentersComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    name:  ['', Validators.required],
    phone: [''],
    email: [''],
    notes: ['']
  });

  renters = signal<Renter[]>([]);
  isOwner = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem = signal<Renter | null>(null);

  ngOnInit() { this.load(); }

  load() {
    this.api.get<Renter[]>('/renters').subscribe(data => this.renters.set(data));
  }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }

  openModal(renter?: Renter) {
    this.editItem.set(renter ?? null);
    this.form.reset({ name: '', phone: '', email: '', notes: '' });
    if (renter) this.form.patchValue(renter);
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  save() {
    if (this.form.invalid) return;
    const r = this.editItem();
    const body = { ...this.form.value };
    const obs = r ? this.api.put(`/renters/${r.id}`, body) : this.api.post('/renters', body);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/renters/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }
}
