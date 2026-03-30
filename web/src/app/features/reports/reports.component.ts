import { Component, signal, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  template: `
    <h2 style="margin:0 0 24px">{{ lang.t('reports') }}</h2>

    <div style="display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;margin-bottom:24px">
      <div class="form-group">
        <label class="form-label">{{ lang.t('month') }}</label>
        <input class="form-control" type="number" [formControl]="$any(form.get('month'))" min="1" max="12" style="width:100px">
      </div>
      <div class="form-group">
        <label class="form-label">{{ lang.t('year') }}</label>
        <input class="form-control" type="number" [formControl]="$any(form.get('year'))" min="2000" max="2099" style="width:110px">
      </div>
      <button class="btn btn-primary" (click)="load()">
        <span class="material-icons">search</span> Load
      </button>
      <button class="btn btn-outline" (click)="loadCommission()">
        Commission
      </button>
    </div>

    @if (report()) {
      <div class="stats-grid" style="margin-bottom:24px">
        <div class="stat-card">
          <span class="material-icons">payments</span>
          <div class="stat-value">{{ report().totalRentCollected | number:'1.0-0' }}</div>
          <div class="stat-label">Rent Collected</div>
        </div>
        <div class="stat-card">
          <span class="material-icons" style="color:var(--warn)">warning</span>
          <div class="stat-value" style="color:var(--warn)">{{ report().totalOutstanding | number:'1.0-0' }}</div>
          <div class="stat-label">{{ lang.t('outstanding') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons" style="color:var(--accent)">receipt</span>
          <div class="stat-value">{{ report().totalExpenses | number:'1.0-0' }}</div>
          <div class="stat-label">{{ lang.t('expenses') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons">savings</span>
          <div class="stat-value">{{ report().totalDeposit | number:'1.0-0' }}</div>
          <div class="stat-label">{{ lang.t('deposits') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons" [style.color]="report().netBalance < 0 ? 'var(--warn)' : 'var(--accent)'">account_balance</span>
          <div class="stat-value" [style.color]="report().netBalance < 0 ? 'var(--warn)' : 'var(--accent)'">
            {{ report().netBalance | number:'1.0-0' }}
          </div>
          <div class="stat-label">Net Balance</div>
        </div>
      </div>

      <h3 style="margin:0 0 12px;font-weight:700">{{ lang.t('payments') }}</h3>
      <div class="card">
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ lang.t('apartment') }}</th>
              <th>{{ lang.t('renter') }}</th>
              <th>{{ lang.t('paid') }}</th>
              <th>{{ lang.t('outstanding') }}</th>
            </tr>
          </thead>
          <tbody>
            @for (p of report().payments; track $index) {
              <tr>
                <td>{{ p.apartmentName }}</td>
                <td>{{ p.renterName || '—' }}</td>
                <td>{{ p.amountPaid | number:'1.0-0' }}</td>
                <td [style.color]="p.outstanding > 0 ? 'var(--warn)' : 'inherit'">{{ p.outstanding | number:'1.0-0' }}</td>
              </tr>
            }
          </tbody>
        </table>
      </div>
    }

    @if (commission()) {
      <div class="card" style="margin-top:24px;padding:20px">
        <h3 style="margin:0 0 14px;font-weight:700">Commission — {{ commission().month }}/{{ commission().year }}</h3>
        <p style="margin:6px 0">Total Collected: <strong>{{ commission().totalRentCollected | number:'1.0-0' }}</strong></p>
        <p style="margin:6px 0">Rate: <strong>{{ commission().commissionRate }}%</strong></p>
        <p style="margin:6px 0">Commission Due: <strong>{{ commission().commissionAmount | number:'1.0-2' }}</strong></p>
      </div>
    }
  `
})
export class ReportsComponent {
  private api = inject(ApiService);
  lang = inject(LanguageService);
  private fb = inject(FormBuilder);
  report = signal<any>(null);
  commission = signal<any>(null);

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
