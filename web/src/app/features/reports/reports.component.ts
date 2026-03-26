import { Component, signal, inject, computed } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  template: `
    <h2 class="page-title" style="margin-bottom:24px">Monthly Report</h2>

    <div class="card" style="margin-bottom:24px">
      <form [formGroup]="form" style="display:flex;gap:16px;align-items:flex-end;flex-wrap:wrap">
        <div class="form-group" style="margin-bottom:0">
          <label class="form-label">Month</label>
          <input class="form-control" type="number" formControlName="month" min="1" max="12" style="width:100px">
        </div>
        <div class="form-group" style="margin-bottom:0">
          <label class="form-label">Year</label>
          <input class="form-control" type="number" formControlName="year" min="2000" max="2099" style="width:110px">
        </div>
        <button class="btn btn-primary" type="button" (click)="load()">
          <span class="material-icons">search</span> Load Report
        </button>
        @if (isOwner) {
          <button class="btn btn-ghost" type="button" (click)="loadCommission()">
            <span class="material-icons">percent</span> Commission
          </button>
        }
      </form>
    </div>

    @if (report()) {
      <div class="stats-grid" style="margin-bottom:24px">
        <div class="stat-card">
          <div class="stat-value">{{ report().totalRentCollected | number:'1.0-0' }}</div>
          <div class="stat-label">Rent Collected</div>
        </div>
        <div class="stat-card">
          <div class="stat-value text-danger">{{ report().totalOutstanding | number:'1.0-0' }}</div>
          <div class="stat-label">Outstanding</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ report().totalExpenses | number:'1.0-0' }}</div>
          <div class="stat-label">Expenses</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ report().totalDeposit | number:'1.0-0' }}</div>
          <div class="stat-label">Deposit</div>
        </div>
        <div class="stat-card">
          <div class="stat-value" [class.text-success]="report().netBalance >= 0" [class.text-danger]="report().netBalance < 0">
            {{ report().netBalance | number:'1.0-0' }}
          </div>
          <div class="stat-label">Net Balance</div>
        </div>
      </div>

      <h3 style="margin-bottom:12px;font-size:1rem">Payments</h3>
      <div class="card" style="padding:0;overflow:hidden;margin-bottom:24px">
        <table class="data-table">
          <thead>
            <tr>
              <th>Apartment</th>
              <th>Renter</th>
              <th>Paid</th>
              <th>Outstanding</th>
            </tr>
          </thead>
          <tbody>
            @for (p of report().payments; track p.id) {
              <tr>
                <td>{{ p.apartmentName }}</td>
                <td>{{ p.renterName || '—' }}</td>
                <td>{{ p.amountPaid | number:'1.0-0' }}</td>
                <td [class.text-danger]="p.outstanding > 0">{{ p.outstanding | number:'1.0-0' }}</td>
              </tr>
            }
            @if (!report().payments?.length) {
              <tr><td colspan="4" class="table-empty">No payments for this period.</td></tr>
            }
          </tbody>
        </table>
      </div>
    }

    @if (commission()) {
      <div class="card mt-24">
        <h3 style="margin-bottom:16px">Commission — {{ commission().month }}/{{ commission().year }}</h3>
        <p>Total Collected: <strong>{{ commission().totalRentCollected | number:'1.0-0' }}</strong></p>
        <p>Rate: <strong>{{ commission().commissionRate }}%</strong></p>
        <p>Commission Due: <strong>{{ commission().commissionAmount | number:'1.0-2' }}</strong></p>
      </div>
    }
  `
})
export class ReportsComponent {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private fb = inject(FormBuilder);
  report = signal<any>(null);
  commission = signal<any>(null);
  get isOwner() { return this.auth.isOwner; }

  form = this.fb.group({
    month: [new Date().getMonth() + 1],
    year: [new Date().getFullYear()]
  });

  load() {
    const { month, year } = this.form.value;
    this.api.get<any>('/reports/monthly', { month: month!, year: year! }).subscribe(d => this.report.set(d));
  }

  loadCommission() {
    const { month, year } = this.form.value;
    this.api.get<any>('/reports/commission', { month: month!, year: year!, rate: 10 }).subscribe(d => this.commission.set(d));
  }
}
