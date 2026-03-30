import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { UserDto } from '../../core/models';

@Component({
  selector: 'app-employees',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('employees') }}</h2>
      <button class="btn btn-primary" (click)="openModal()">
        <span class="material-icons">person_add</span> {{ lang.t('inviteEmployee') }}
      </button>
    </div>

    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('name') }}</th>
            <th>{{ lang.t('email') }}</th>
            <th>{{ lang.t('phone') }}</th>
            <th>{{ lang.t('active') }}</th>
            <th class="col-actions"></th>
          </tr>
        </thead>
        <tbody>
          @for (e of employees(); track e.id) {
            <tr>
              <td>{{ e.name }}</td>
              <td>{{ e.email }}</td>
              <td>{{ e.phone || '—' }}</td>
              <td>
                <span class="badge" [class]="e.isActive ? 'badge-primary' : 'badge-muted'">
                  {{ e.isActive ? lang.t('yes') : lang.t('no') }}
                </span>
              </td>
              <td class="col-actions">
                <button class="btn-icon btn-icon-warn" (click)="delete(e.id)" [title]="lang.t('delete')">
                  <span class="material-icons">person_remove</span>
                </button>
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!employees().length) {
        <div class="empty-state">{{ lang.t('noEmployeesYet') }}</div>
      }
    </div>

    @if (showModal()) {
      <div class="modal-overlay" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>{{ lang.t('inviteEmployee') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('name') }} *</label>
                <input class="form-control" formControlName="name">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('email') }} *</label>
                <input class="form-control" type="email" formControlName="email">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('phone') }}</label>
                <input class="form-control" formControlName="phone">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('password') }} *</label>
                <div style="position:relative">
                  <input class="form-control" [type]="hide ? 'password' : 'text'" formControlName="password">
                  <button type="button" class="btn-icon"
                    style="position:absolute;inset-inline-end:6px;top:50%;transform:translateY(-50%)"
                    (click)="hide = !hide">
                    <span class="material-icons">{{ hide ? 'visibility_off' : 'visibility' }}</span>
                  </button>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" (click)="closeModal()">{{ lang.t('cancel') }}</button>
            <button class="btn btn-primary" (click)="save()" [disabled]="form.invalid">{{ lang.t('invite') }}</button>
          </div>
        </div>
      </div>
    }
  `
})
export class EmployeesComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    name:     ['', Validators.required],
    email:    ['', [Validators.required, Validators.email]],
    phone:    [''],
    password: ['', [Validators.required, Validators.minLength(6)]]
  });

  employees = signal<UserDto[]>([]);
  showModal = signal(false);
  hide = true;

  ngOnInit() { this.load(); }
  load() { this.api.get<UserDto[]>('/employees').subscribe(d => this.employees.set(d)); }

  openModal() {
    this.form.reset({ name: '', email: '', phone: '', password: '' });
    this.hide = true;
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); }

  save() {
    if (this.form.invalid) return;
    this.api.post('/employees', this.form.value).subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/employees/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }
}
