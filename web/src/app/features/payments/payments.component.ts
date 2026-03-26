import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { ToastService } from '../../core/services/toast.service';
import { RentPayment, Apartment, Renter } from '../../core/models';

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Rent Payments</h2>
      <div style="display:flex;gap:8px">
        <button class="btn btn-primary" (click)="openDialog()">
          <span class="material-icons">add</span> Add Payment
        </button>
        @if (isOwner()) {
          <button class="btn btn-ghost" (click)="generateMonth()">
            <span class="material-icons">auto_awesome</span> Generate Month
          </button>
        }
      </div>
    </div>

    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Apartment</th><th>Renter</th><th>Period</th>
            <th>Rent</th><th>Paid</th><th>Outstanding</th>
            <th>Status</th><th style="width:80px"></th>
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
              <td [class.text-danger]="p.outstandingAfter > 0">{{ p.outstandingAfter | number:'1.0-0' }}</td>
              <td>
                <span class="badge"
                  [class.badge-success]="p.status === 'Approved'"
                  [class.badge-danger]="p.status === 'Rejected'"
                  [class.badge-warning]="p.status === 'Draft'">{{ p.status }}</span>
              </td>
              <td>
                <button class="btn-icon" (click)="openDialog(p)"><span class="material-icons">edit</span></button>
                @if (isOwner()) {
                  <button class="btn-icon danger" (click)="delete(p.id)"><span class="material-icons">delete</span></button>
                }
              </td>
            </tr>
          }
          @if (!payments().length) {
            <tr><td colspan="8" class="table-empty">No payments yet.</td></tr>
          }
        </tbody>
      </table>
    </div>

    @if (showDialog()) {
      <div class="modal-overlay" (click)="backdropClick($event)">
        <div class="modal-panel">
          <div class="modal-header">
            <span class="modal-title">{{ editing() ? 'Edit Payment' : 'Add Payment' }}</span>
            <button class="btn-icon" (click)="closeDialog()"><span class="material-icons">close</span></button>
          </div>
          <div class="modal-body">
            <form #f="ngForm">
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Apartment *</label>
                  <select class="form-control" [(ngModel)]="form.apartmentId" name="apartmentId" required>
                    <option value="">Select apartment</option>
                    @for (a of apartments(); track a.id) {
                      <option [value]="a.id">{{ a.name }}</option>
                    }
                  </select>
                </div>
                <div class="form-group">
                  <label class="form-label">Renter</label>
                  <select class="form-control" [(ngModel)]="form.renterId" name="renterId">
                    <option value="">Vacant</option>
                    @for (r of renters(); track r.id) {
                      <option [value]="r.id">{{ r.name }}</option>
                    }
                  </select>
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Month *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.paymentMonth" name="paymentMonth" required min="1" max="12" placeholder="1–12">
                </div>
                <div class="form-group">
                  <label class="form-label">Year *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.paymentYear" name="paymentYear" required min="2000" placeholder="e.g. 2025">
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Rent Amount *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.rentAmount" name="rentAmount" required min="0" placeholder="0">
                </div>
                <div class="form-group">
                  <label class="form-label">Outstanding Before</label>
                  <input class="form-control" type="number" [(ngModel)]="form.outstandingBefore" name="outstandingBefore" min="0" placeholder="0">
                </div>
                <div class="form-group">
                  <label class="form-label">Amount Paid *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.amountPaid" name="amountPaid" required min="0" placeholder="0">
                </div>
              </div>
              <div class="form-group" style="margin-bottom:8px">
                <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13px;color:var(--text)">
                  <input type="checkbox" [(ngModel)]="form.isVacant" name="isVacant"> Mark as vacant
                </label>
              </div>
              <div class="form-group" style="margin-bottom:0">
                <label class="form-label">Notes</label>
                <textarea class="form-control" [(ngModel)]="form.notes" name="notes" rows="2" placeholder="Optional notes"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-ghost" (click)="closeDialog()">Cancel</button>
            <button class="btn btn-primary" (click)="save(f)" [disabled]="f.invalid || saving()">
              @if (saving()) { <span class="spinner" style="border-top-color:#fff"></span> } @else { Save }
            </button>
          </div>
        </div>
      </div>
    }
  `
})
export class PaymentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private toast = inject(ToastService);

  payments = signal<RentPayment[]>([]);
  apartments = signal<Apartment[]>([]);
  renters = signal<Renter[]>([]);
  isOwner = signal(this.auth.isOwner);
  showDialog = signal(false);
  editing = signal<RentPayment | null>(null);
  saving = signal(false);

  form = { apartmentId: '', renterId: '', paymentMonth: new Date().getMonth() + 1, paymentYear: new Date().getFullYear(), rentAmount: 0, outstandingBefore: 0, amountPaid: 0, isVacant: false, notes: '' };

  ngOnInit() {
    this.load();
    this.api.get<Apartment[]>('/apartments').subscribe(d => this.apartments.set(d));
    this.api.get<Renter[]>('/renters').subscribe(d => this.renters.set(d));
  }

  load() { this.api.get<RentPayment[]>('/payments').subscribe(d => this.payments.set(d)); }

  openDialog(p?: RentPayment) {
    this.editing.set(p ?? null);
    this.form = p
      ? { apartmentId: p.apartmentId, renterId: p.renterId ?? '', paymentMonth: p.paymentMonth, paymentYear: p.paymentYear, rentAmount: p.rentAmount, outstandingBefore: p.outstandingBefore, amountPaid: p.amountPaid, isVacant: p.isVacant, notes: p.notes ?? '' }
      : { apartmentId: '', renterId: '', paymentMonth: new Date().getMonth() + 1, paymentYear: new Date().getFullYear(), rentAmount: 0, outstandingBefore: 0, amountPaid: 0, isVacant: false, notes: '' };
    this.showDialog.set(true);
  }

  closeDialog() { this.showDialog.set(false); }

  backdropClick(e: MouseEvent) { if ((e.target as HTMLElement).classList.contains('modal-overlay')) this.closeDialog(); }

  save(f: any) {
    if (f.invalid) return;
    this.saving.set(true);
    const body = { ...this.form, renterId: this.form.renterId || null };
    const p = this.editing();
    const req = p ? this.api.put(`/payments/${p.id}`, body) : this.api.post('/payments', body);
    req.subscribe({
      next: () => { this.toast.success('Saved'); this.closeDialog(); this.load(); this.saving.set(false); },
      error: e => { this.toast.error(e.error?.message || 'Error saving'); this.saving.set(false); }
    });
  }

  delete(id: string) {
    if (!confirm('Delete this payment?')) return;
    this.api.delete(`/payments/${id}`).subscribe({
      next: () => { this.toast.success('Deleted'); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Delete failed')
    });
  }

  generateMonth() {
    const now = new Date();
    this.api.post<RentPayment[]>('/payments/generate-month', { month: now.getMonth() + 1, year: now.getFullYear() }).subscribe({
      next: (created) => { this.toast.success(`Generated ${created.length} records`); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Error')
    });
  }
}
