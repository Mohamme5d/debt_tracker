import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { ToastService } from '../../core/services/toast.service';
import { RentPayment } from '../../core/models';

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Rent Payments</h2>
      @if (isOwner()) {
        <button class="btn btn-primary" (click)="generateMonth()">
          <span class="material-icons">auto_awesome</span> Generate This Month
        </button>
      }
    </div>
    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Apartment</th>
            <th>Renter</th>
            <th>Period</th>
            <th>Rent</th>
            <th>Paid</th>
            <th>Outstanding</th>
            <th>Status</th>
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
                  [class.badge-warning]="p.status === 'Pending'">
                  {{ p.status }}
                </span>
              </td>
            </tr>
          }
          @if (!payments().length) {
            <tr><td colspan="7" class="table-empty">No payments yet.</td></tr>
          }
        </tbody>
      </table>
    </div>
  `
})
export class PaymentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private toast = inject(ToastService);

  payments = signal<RentPayment[]>([]);
  isOwner = signal(this.auth.isOwner);

  ngOnInit() { this.load(); }
  load() { this.api.get<RentPayment[]>('/payments').subscribe(data => this.payments.set(data)); }

  generateMonth() {
    const now = new Date();
    this.api.post<RentPayment[]>('/payments/generate-month', { month: now.getMonth() + 1, year: now.getFullYear() }).subscribe({
      next: (created) => { this.toast.success(`Generated ${created.length} records`); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Error')
    });
  }
}
