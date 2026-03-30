import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { NgSelectModule } from '@ng-select/ng-select';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { RentContract, Renter, Apartment } from '../../core/models';

@Component({
  selector: 'app-contracts',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule, NgSelectModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('contracts') }}</h2>
      <button class="btn btn-primary" (click)="openModal()">
        <span class="material-icons">add</span> {{ lang.t('addContract') }}
      </button>
    </div>

    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('renter') }}</th>
            <th>{{ lang.t('apartment') }}</th>
            <th>{{ lang.t('monthlyRent') }}</th>
            <th>{{ lang.t('startDate') }}</th>
            <th>{{ lang.t('endDate') }}</th>
            <th>{{ lang.t('isActive') }}</th>
            <th>{{ lang.t('status') }}</th>
            <th class="col-actions"></th>
          </tr>
        </thead>
        <tbody>
          @for (c of contracts(); track c.id) {
            <tr>
              <td>{{ c.renterName }}</td>
              <td>{{ c.apartmentName }}</td>
              <td>{{ c.monthlyRent | number:'1.0-0' }}</td>
              <td>{{ c.startDate }}</td>
              <td>{{ c.endDate || '—' }}</td>
              <td>
                <span class="badge" [class]="c.isActive ? 'badge-primary' : 'badge-muted'">
                  {{ c.isActive ? lang.t('active') : lang.t('inactive') }}
                </span>
              </td>
              <td>
                <span class="badge" [class]="statusClass(c.status)">{{ c.status }}</span>
              </td>
              <td class="col-actions">
                <button class="btn-icon" (click)="openModal(c)" [title]="lang.t('edit')">
                  <span class="material-icons">edit</span>
                </button>
                @if (isOwner()) {
                  <button class="btn-icon btn-icon-warn" (click)="delete(c.id)" [title]="lang.t('delete')">
                    <span class="material-icons">delete</span>
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!contracts().length) {
        <div class="empty-state">{{ lang.t('noContractsYet') }}</div>
      }
    </div>

    @if (showModal()) {
      <div class="modal-overlay" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>{{ editItem() ? lang.t('editContract') : lang.t('addContract') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('renter') }} *</label>
                <ng-select
                  [items]="renters()"
                  bindLabel="name"
                  bindValue="id"
                  formControlName="renterId"
                  [placeholder]="lang.t('selectRenter')"
                  appendTo="body">
                </ng-select>
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('apartment') }} *</label>
                <ng-select
                  [items]="apartments()"
                  bindLabel="name"
                  bindValue="id"
                  formControlName="apartmentId"
                  [placeholder]="lang.t('selectApartment')"
                  appendTo="body">
                </ng-select>
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('monthlyRent') }} *</label>
                <input class="form-control" type="number" formControlName="monthlyRent">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('startDate') }} *</label>
                <input class="form-control" type="date" formControlName="startDate">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('endDate') }}</label>
                <input class="form-control" type="date" formControlName="endDate">
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
export class ContractsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    renterId:    ['', Validators.required],
    apartmentId: ['', Validators.required],
    monthlyRent: [0, [Validators.required, Validators.min(0)]],
    startDate:   ['', Validators.required],
    endDate:     [''],
    notes:       ['']
  });

  contracts = signal<RentContract[]>([]);
  renters = signal<Renter[]>([]);
  apartments = signal<Apartment[]>([]);
  isOwner = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem = signal<RentContract | null>(null);

  ngOnInit() {
    this.load();
    this.api.get<Renter[]>('/renters').subscribe(data => this.renters.set(data));
    this.api.get<Apartment[]>('/apartments').subscribe(data => this.apartments.set(data));
  }

  load() {
    this.api.get<RentContract[]>('/contracts').subscribe(data => this.contracts.set(data));
  }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }

  openModal(contract?: RentContract) {
    this.editItem.set(contract ?? null);
    this.form.reset({ renterId: '', apartmentId: '', monthlyRent: 0, startDate: '', endDate: '', notes: '' });
    if (contract) {
      this.form.patchValue({
        renterId: contract.renterId,
        apartmentId: contract.apartmentId,
        monthlyRent: contract.monthlyRent,
        startDate: contract.startDate,
        endDate: contract.endDate || '',
        notes: contract.notes || ''
      });
    }
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  save() {
    if (this.form.invalid) return;
    const v = this.form.value;
    const body = {
      renterId: v.renterId,
      apartmentId: v.apartmentId,
      monthlyRent: Number(v.monthlyRent),
      startDate: v.startDate,
      endDate: v.endDate || null,
      notes: v.notes || null
    };
    const c = this.editItem();
    const obs = c ? this.api.put(`/contracts/${c.id}`, body) : this.api.post('/contracts', body);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/contracts/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }
}
