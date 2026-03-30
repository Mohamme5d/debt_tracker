import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { NgSelectModule } from '@ng-select/ng-select';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { RentPayment, RentContract } from '../../core/models';

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule, NgSelectModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('payments') }}</h2>
      <div style="display:flex;gap:8px">
        <button class="btn btn-primary" (click)="openModal()">
          <span class="material-icons">add</span> {{ lang.t('addPayment') }}
        </button>
        @if (isOwner()) {
          <button class="btn btn-accent" (click)="generateMonth()">
            <span class="material-icons">auto_awesome</span> {{ lang.t('generateThisMonth') }}
          </button>
        }
      </div>
    </div>

    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('apartment') }}</th>
            <th>{{ lang.t('renter') }}</th>
            <th>{{ lang.t('period') }}</th>
            <th>{{ lang.t('rent') }}</th>
            <th>{{ lang.t('paid') }}</th>
            <th>{{ lang.t('outstanding') }}</th>
            <th>{{ lang.t('status') }}</th>
            <th class="col-actions"></th>
          </tr>
        </thead>
        <tbody>
          @for (p of payments(); track p.id) {
            <tr>
              <td>{{ p.apartmentName }}</td>
              <td>{{ p.renterName || '—' }}</td>
              <td>{{ p.paymentMonth }}/{{ p.paymentYear }}</td>
              <td>{{ p.rentAmount | number:'1.0-0' }}</td>
              <td>{{ p.amountPaid | number:'1.0-0' }}</td>
              <td [style.color]="p.outstandingAfter > 0 ? 'var(--warn)' : 'inherit'">
                {{ p.outstandingAfter | number:'1.0-0' }}
              </td>
              <td>
                <span class="badge" [class]="statusClass(p.status)">
                  {{ lang.t(p.status?.toLowerCase() || 'pending') }}
                </span>
              </td>
              <td class="col-actions">
                <button class="btn-icon" (click)="openModal(p)" [title]="lang.t('edit')">
                  <span class="material-icons">edit</span>
                </button>
                @if (isOwner()) {
                  <button class="btn-icon btn-icon-warn" (click)="delete(p.id)" [title]="lang.t('delete')">
                    <span class="material-icons">delete</span>
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!payments().length) {
        <div class="empty-state">{{ lang.t('noPaymentsYet') }}</div>
      }
    </div>

    @if (showModal()) {
      <div class="modal-overlay" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>{{ editItem() ? lang.t('editPayment') : lang.t('addPayment') }}</h3>
          </div>
          <div class="modal-body">
            <form [formGroup]="form">
              <div class="form-group">
                <label class="form-label">{{ lang.t('contract') }}</label>
                <ng-select
                  [items]="contracts()"
                  bindValue="id"
                  formControlName="contractId"
                  [placeholder]="lang.t('selectContract')"
                  appendTo="body"
                  (change)="onContractSelect($event)">
                  <ng-template ng-label-tmp let-item="item">
                    {{ item.renterName }} — {{ item.apartmentName }}
                  </ng-template>
                  <ng-template ng-option-tmp let-item="item">
                    {{ item.renterName }} — {{ item.apartmentName }} | {{ item.monthlyRent | number:'1.0-0' }}
                  </ng-template>
                </ng-select>
              </div>
              <div style="display:flex;gap:10px">
                <div class="form-group" style="flex:1">
                  <label class="form-label">{{ lang.t('month') }} *</label>
                  <input class="form-control" type="number" formControlName="paymentMonth" min="1" max="12">
                </div>
                <div class="form-group" style="flex:1">
                  <label class="form-label">{{ lang.t('year') }} *</label>
                  <input class="form-control" type="number" formControlName="paymentYear" min="2020">
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('rentAmount') }} *</label>
                <input class="form-control" type="number" formControlName="rentAmount">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('outstandingBefore') }}</label>
                <input class="form-control" type="number" formControlName="outstandingBefore">
              </div>
              <div class="form-group">
                <label class="form-label">{{ lang.t('amountPaid') }} *</label>
                <input class="form-control" type="number" formControlName="amountPaid">
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
export class PaymentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  form = inject(FormBuilder).group({
    contractId:        [null as string | null],
    paymentMonth:      [new Date().getMonth() + 1, [Validators.required, Validators.min(1), Validators.max(12)]],
    paymentYear:       [new Date().getFullYear(), Validators.required],
    rentAmount:        [0, [Validators.required, Validators.min(0)]],
    outstandingBefore: [0],
    amountPaid:        [0, Validators.required],
    notes:             ['']
  });

  payments = signal<RentPayment[]>([]);
  contracts = signal<RentContract[]>([]);
  isOwner = signal(this.auth.isOwner);
  showModal = signal(false);
  editItem = signal<RentPayment | null>(null);

  ngOnInit() {
    this.load();
    this.api.get<RentContract[]>('/contracts').subscribe(data => this.contracts.set(data));
  }

  load() {
    this.api.get<RentPayment[]>('/payments').subscribe(data => this.payments.set(data));
  }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }

  openModal(payment?: RentPayment) {
    this.editItem.set(payment ?? null);
    this.form.reset({
      contractId: payment?.contractId ?? null,
      paymentMonth: payment?.paymentMonth ?? new Date().getMonth() + 1,
      paymentYear: payment?.paymentYear ?? new Date().getFullYear(),
      rentAmount: payment?.rentAmount ?? 0,
      outstandingBefore: payment?.outstandingBefore ?? 0,
      amountPaid: payment?.amountPaid ?? 0,
      notes: payment?.notes ?? ''
    });
    this.showModal.set(true);
  }

  closeModal() { this.showModal.set(false); this.editItem.set(null); }

  onContractSelect(contract: RentContract | null) {
    if (contract) this.form.patchValue({ rentAmount: contract.monthlyRent });
  }

  save() {
    if (this.form.invalid) return;
    const v = this.form.value;
    const body = {
      contractId: v.contractId || null,
      apartmentId: null,
      paymentMonth: Number(v.paymentMonth),
      paymentYear: Number(v.paymentYear),
      rentAmount: Number(v.rentAmount),
      outstandingBefore: Number(v.outstandingBefore),
      amountPaid: Number(v.amountPaid),
      isVacant: !v.contractId,
      notes: v.notes || null
    };
    const p = this.editItem();
    const obs = p
      ? this.api.put(`/payments/${p.id}`, body)
      : this.api.post('/payments', body);
    obs.subscribe({
      next: () => { this.toast.show(this.lang.t('saved')); this.closeModal(); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }

  delete(id: string) {
    if (!confirm(this.lang.t('delete') + '?')) return;
    this.api.delete(`/payments/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.show(e.error?.message || 'Delete failed', 'error')
    });
  }

  generateMonth() {
    const now = new Date();
    this.api.post<RentPayment[]>('/payments/generate-month', { month: now.getMonth() + 1, year: now.getFullYear() }).subscribe({
      next: (created) => { this.toast.show(`${this.lang.t('generateThisMonth')}: ${created.length}`); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }
}
