import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { Apartment } from '../../core/models';

@Component({
  selector: 'app-apartments',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('apartments') }}</h2>
      @if (isOwner()) {
        <button class="btn btn-primary" (click)="openModal()">
          <span class="material-icons">add</span> {{ lang.t('addApartment') }}
        </button>
      }
    </div>

    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('name') }}</th>
            <th>{{ lang.t('address') }}</th>
            <th>{{ lang.t('description') }}</th>
            <th class="col-actions"></th>
          </tr>
        </thead>
        <tbody>
          @for (a of apartments(); track a.id) {
            <tr>
              <td>{{ a.name }}</td>
              <td>{{ a.address || '—' }}</td>
              <td>{{ a.description || '—' }}</td>
              <td class="col-actions">
                @if (isOwner()) {
                  <button class="btn-icon" (click)="openModal(a)" [title]="lang.t('edit')">
                    <span class="material-icons">edit</span>
                  </button>
                  <button class="btn-icon btn-icon-warn" (click)="delete(a.id)" [title]="lang.t('delete')">
                    <span class="material-icons">delete</span>
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!apartments().length) {
        <div class="empty-state">{{ lang.t('noApartmentsYet') }}</div>
      }
    </div>

    @if (showModal()) {
      <div class="modal-overlay" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>{{ editItem() ? lang.t('editApartment') : lang.t('addApartment') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('name') }} *</label>
                <input class="form-control" formControlName="name">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('address') }}</label>
                <input class="form-control" formControlName="address">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('description') }}</label>
                <textarea class="form-control" formControlName="description"></textarea>
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
export class ApartmentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    name: ['', Validators.required],
    address: [''],
    description: [''],
    notes: ['']
  });

  apartments = signal<Apartment[]>([]);
  isOwner = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem = signal<Apartment | null>(null);

  ngOnInit() { this.load(); }

  load() {
    this.api.get<Apartment[]>('/apartments').subscribe(data => this.apartments.set(data));
  }

  openModal(apt?: Apartment) {
    this.editItem.set(apt ?? null);
    this.form.reset({ name: '', address: '', description: '', notes: '' });
    if (apt) this.form.patchValue(apt);
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  save() {
    if (this.form.invalid) return;
    const apt = this.editItem();
    const obs = apt
      ? this.api.put(`/apartments/${apt.id}`, this.form.value)
      : this.api.post('/apartments', this.form.value);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/apartments/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }
}
