import { Component, OnInit, signal, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';
import { Apartment, Renter } from '../../core/models';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule, FormsModule],
  styles: [`
    .tabs { display:flex; gap:4px; margin-bottom:24px; border-bottom:2px solid var(--border); }
    .tab-btn {
      padding:10px 20px; border:none; background:none; cursor:pointer;
      font-size:14px; font-weight:500; color:var(--text-secondary);
      border-bottom:2px solid transparent; margin-bottom:-2px; transition:all .15s;
    }
    .tab-btn.active { color:var(--primary); border-bottom-color:var(--primary); }
    .tab-btn:hover:not(.active) { color:var(--text); }
    .action-bar { display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; margin-bottom:24px; }
    .stat-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(160px,1fr)); gap:14px; margin-bottom:24px; }
    .stat-card { background:var(--surface); border:1px solid var(--border); border-radius:10px; padding:16px; text-align:center; }
    .stat-value { font-size:22px; font-weight:700; margin:6px 0 4px; }
    .stat-label { font-size:12px; color:var(--text-secondary); }
    .section-title { font-size:15px; font-weight:700; margin:24px 0 12px; }
    @media print {
      .no-print { display:none !important; }
      .tabs { display:none; }
      body { background:#fff; }
    }
  `],
  template: `
    <div class="page-header no-print">
      <h2>{{ lang.t('reports') }}</h2>
    </div>

    <!-- Tabs -->
    <div class="tabs no-print">
      <button class="tab-btn" [class.active]="activeTab === 'monthly'" (click)="activeTab = 'monthly'">
        {{ lang.t('monthlyReport') }}
      </button>
      <button class="tab-btn" [class.active]="activeTab === 'renter'" (click)="activeTab = 'renter'">
        {{ lang.t('renterApartmentReport') }}
      </button>
      <button class="tab-btn" [class.active]="activeTab === 'alltime'" (click)="activeTab = 'alltime'">
        {{ lang.t('allTimeReport') }}
      </button>
    </div>

    <!-- ── Monthly Report Tab ── -->
    @if (activeTab === 'monthly') {
      <div class="action-bar no-print">
        <div class="form-group">
          <label class="form-label">{{ lang.t('month') }}</label>
          <input class="form-control" type="number" [(ngModel)]="monthlyMonth" min="1" max="12" style="width:100px">
        </div>
        <div class="form-group">
          <label class="form-label">{{ lang.t('year') }}</label>
          <input class="form-control" type="number" [(ngModel)]="monthlyYear" min="2000" max="2099" style="width:110px">
        </div>
        <button class="btn btn-primary" (click)="loadMonthly()">
          <span class="material-icons">search</span> Load
        </button>
        <button class="btn btn-outline" (click)="loadCommission()">
          {{ lang.t('commission') }}
        </button>
        @if (monthlyReport()) {
          <button class="btn btn-accent" (click)="exportMonthlyExcel()">
            <span class="material-icons">table_view</span> {{ lang.t('exportExcel') }}
          </button>
          <button class="btn btn-outline" (click)="printReport()">
            <span class="material-icons">picture_as_pdf</span> {{ lang.t('exportPdf') }}
          </button>
        }
      </div>

      @if (monthlyReport(); as r) {
        <div class="print-header" style="display:none">
          <h2>{{ lang.t('monthlyReport') }} — {{ monthlyMonth }}/{{ monthlyYear }}</h2>
        </div>
        <div class="stat-grid">
          <div class="stat-card">
            <span class="material-icons">payments</span>
            <div class="stat-value">{{ r.totalRentCollected | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('rentCollected') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons" style="color:var(--warn)">warning</span>
            <div class="stat-value" style="color:var(--warn)">{{ r.totalOutstanding | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('outstanding') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons" style="color:var(--accent)">receipt</span>
            <div class="stat-value">{{ r.totalExpenses | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('expenses') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons">savings</span>
            <div class="stat-value">{{ r.totalDeposit | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('deposits') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons" [style.color]="r.netBalance < 0 ? 'var(--warn)' : 'var(--accent)'">account_balance</span>
            <div class="stat-value" [style.color]="r.netBalance < 0 ? 'var(--warn)' : 'var(--accent)'">
              {{ r.netBalance | number:'1.0-0' }}
            </div>
            <div class="stat-label">{{ lang.t('netBalance') }}</div>
          </div>
        </div>

        <div class="section-title">{{ lang.t('payments') }}</div>
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
              @for (p of r.payments; track $index) {
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

        @if (r.expenses?.length) {
          <div class="section-title">{{ lang.t('expenses') }}</div>
          <div class="card">
            <table class="data-table">
              <thead>
                <tr>
                  <th>{{ lang.t('description') }}</th>
                  <th>{{ lang.t('category') }}</th>
                  <th>{{ lang.t('amount') }}</th>
                </tr>
              </thead>
              <tbody>
                @for (e of r.expenses; track $index) {
                  <tr>
                    <td>{{ e.description }}</td>
                    <td>{{ e.category || '—' }}</td>
                    <td>{{ e.amount | number:'1.0-0' }}</td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        }
      }

      @if (commission(); as c) {
        <div class="card" style="margin-top:24px;padding:20px">
          <h3 style="margin:0 0 14px;font-weight:700">{{ lang.t('commission') }} — {{ c.month }}/{{ c.year }}</h3>
          <p style="margin:6px 0">{{ lang.t('rentCollected') }}: <strong>{{ c.totalRentCollected | number:'1.0-0' }}</strong></p>
          <p style="margin:6px 0">{{ lang.t('commissionRate') }}: <strong>{{ c.commissionRate }}%</strong></p>
          <p style="margin:6px 0">{{ lang.t('commissionDue') }}: <strong>{{ c.commissionAmount | number:'1.0-2' }}</strong></p>
        </div>
      }

      @if (!monthlyReport() && !commission()) {
        <div class="empty-state"><span class="material-icons">bar_chart</span><p>{{ lang.t('noReportData') }}</p></div>
      }
    }

    <!-- ── Renter / Apartment Report Tab ── -->
    @if (activeTab === 'renter') {
      <div class="action-bar no-print">
        <div class="form-group">
          <label class="form-label">{{ lang.t('filterByApartment') }}</label>
          <select class="form-control" [(ngModel)]="filterApartmentId" style="width:180px">
            <option value="">{{ lang.t('allApartmentsOption') }}</option>
            @for (a of apartments(); track a.id) {
              <option [value]="a.id">{{ a.name }}</option>
            }
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">{{ lang.t('filterByRenter') }}</label>
          <select class="form-control" [(ngModel)]="filterRenterId" style="width:180px">
            <option value="">{{ lang.t('allRentersOption') }}</option>
            @for (r of renters(); track r.id) {
              <option [value]="r.id">{{ r.name }}</option>
            }
          </select>
        </div>
        <button class="btn btn-primary" (click)="loadRenterApartment()">
          <span class="material-icons">search</span> Load
        </button>
        @if (renterReport()) {
          <button class="btn btn-outline" (click)="printReport()">
            <span class="material-icons">picture_as_pdf</span> {{ lang.t('exportPdf') }}
          </button>
        }
      </div>

      @if (renterReport(); as r) {
        <div class="stat-grid">
          <div class="stat-card">
            <span class="material-icons">payments</span>
            <div class="stat-value">{{ r.totalPaid | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('totalPaid') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons" style="color:var(--warn)">warning</span>
            <div class="stat-value" style="color:var(--warn)">{{ r.totalOutstanding | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('outstanding') }}</div>
          </div>
        </div>

        @if (r.rows?.length) {
          <div class="card">
            <table class="data-table">
              <thead>
                <tr>
                  <th>{{ lang.t('apartment') }}</th>
                  <th>{{ lang.t('renter') }}</th>
                  <th>{{ lang.t('month') }}</th>
                  <th>{{ lang.t('year') }}</th>
                  <th>{{ lang.t('paid') }}</th>
                  <th>{{ lang.t('outstanding') }}</th>
                </tr>
              </thead>
              <tbody>
                @for (row of r.rows; track $index) {
                  <tr>
                    <td>{{ row.apartmentName }}</td>
                    <td>{{ row.renterName || '—' }}</td>
                    <td>{{ row.month }}</td>
                    <td>{{ row.year }}</td>
                    <td>{{ row.amountPaid | number:'1.0-0' }}</td>
                    <td [style.color]="row.outstandingAfter > 0 ? 'var(--warn)' : 'inherit'">{{ row.outstandingAfter | number:'1.0-0' }}</td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        } @else {
          <div class="empty-state"><span class="material-icons">search_off</span><p>{{ lang.t('noResults') }}</p></div>
        }
      } @else {
        <div class="empty-state"><span class="material-icons">bar_chart</span><p>{{ lang.t('noReportData') }}</p></div>
      }
    }

    <!-- ── All-Time Report Tab ── -->
    @if (activeTab === 'alltime') {
      <div class="action-bar no-print">
        <button class="btn btn-primary" (click)="loadAllTime()">
          <span class="material-icons">search</span> Load
        </button>
        @if (allTimeReport()) {
          <button class="btn btn-accent" (click)="exportAllTimeExcel()">
            <span class="material-icons">table_view</span> {{ lang.t('exportExcel') }}
          </button>
          <button class="btn btn-outline" (click)="printReport()">
            <span class="material-icons">picture_as_pdf</span> {{ lang.t('exportPdf') }}
          </button>
        }
      </div>

      @if (allTimeReport(); as r) {
        <div class="stat-grid">
          <div class="stat-card">
            <span class="material-icons">payments</span>
            <div class="stat-value">{{ r.totalRentCollected | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('rentCollected') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons" style="color:var(--warn)">warning</span>
            <div class="stat-value" style="color:var(--warn)">{{ r.totalOutstanding | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('outstanding') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons" style="color:var(--accent)">receipt</span>
            <div class="stat-value">{{ r.totalExpenses | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('expenses') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons">savings</span>
            <div class="stat-value">{{ r.totalDeposits | number:'1.0-0' }}</div>
            <div class="stat-label">{{ lang.t('totalDeposits') }}</div>
          </div>
          <div class="stat-card">
            <span class="material-icons" [style.color]="r.netBalance < 0 ? 'var(--warn)' : 'var(--accent)'">account_balance</span>
            <div class="stat-value" [style.color]="r.netBalance < 0 ? 'var(--warn)' : 'var(--accent)'">
              {{ r.netBalance | number:'1.0-0' }}
            </div>
            <div class="stat-label">{{ lang.t('netBalance') }}</div>
          </div>
        </div>

        @if (r.apartments?.length) {
          <div class="section-title">{{ lang.t('byApartment') }}</div>
          <div class="card">
            <table class="data-table">
              <thead>
                <tr>
                  <th>{{ lang.t('apartment') }}</th>
                  <th>{{ lang.t('renter') }}</th>
                  <th>{{ lang.t('totalPaid') }}</th>
                  <th>{{ lang.t('outstanding') }}</th>
                </tr>
              </thead>
              <tbody>
                @for (a of r.apartments; track $index) {
                  <tr>
                    <td>{{ a.apartmentName }}</td>
                    <td>{{ a.renterName || '—' }}</td>
                    <td>{{ a.totalPaid | number:'1.0-0' }}</td>
                    <td [style.color]="a.totalOutstanding > 0 ? 'var(--warn)' : 'inherit'">{{ a.totalOutstanding | number:'1.0-0' }}</td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        }

        @if (r.expenseCategories?.length) {
          <div class="section-title">{{ lang.t('byExpenseCategory') }}</div>
          <div class="card">
            <table class="data-table">
              <thead>
                <tr>
                  <th>{{ lang.t('category') }}</th>
                  <th>{{ lang.t('amount') }}</th>
                </tr>
              </thead>
              <tbody>
                @for (c of r.expenseCategories; track $index) {
                  <tr>
                    <td>{{ c.category || '—' }}</td>
                    <td>{{ c.totalAmount | number:'1.0-0' }}</td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        }
      } @else {
        <div class="empty-state"><span class="material-icons">bar_chart</span><p>{{ lang.t('noReportData') }}</p></div>
      }
    }
  `
})
export class ReportsComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);

  activeTab: 'monthly' | 'renter' | 'alltime' = 'monthly';

  // Monthly
  monthlyMonth = new Date().getMonth() + 1;
  monthlyYear = new Date().getFullYear();
  monthlyReport = signal<any>(null);
  commission = signal<any>(null);

  // Renter/Apartment
  filterApartmentId = '';
  filterRenterId = '';
  apartments = signal<Apartment[]>([]);
  renters = signal<Renter[]>([]);
  renterReport = signal<any>(null);

  // All-Time
  allTimeReport = signal<any>(null);

  ngOnInit() {
    this.api.get<Apartment[]>('/apartments').subscribe(d => this.apartments.set(d));
    this.api.get<Renter[]>('/renters').subscribe(d => this.renters.set(d));
  }

  loadMonthly() {
    this.api.get<any>('/reports/monthly', { month: this.monthlyMonth, year: this.monthlyYear })
      .subscribe(d => this.monthlyReport.set(d));
  }

  loadCommission() {
    this.api.get<any>('/reports/commission', { month: this.monthlyMonth, year: this.monthlyYear, rate: 10 })
      .subscribe(d => this.commission.set(d));
  }

  loadRenterApartment() {
    const params: Record<string, string | number> = {};
    if (this.filterApartmentId) params['apartmentId'] = this.filterApartmentId;
    if (this.filterRenterId) params['renterId'] = this.filterRenterId;
    this.api.get<any>('/reports/renter-apartment', params).subscribe(d => this.renterReport.set(d));
  }

  loadAllTime() {
    this.api.get<any>('/reports/all-time').subscribe(d => this.allTimeReport.set(d));
  }

  exportMonthlyExcel() {
    this.api.getBlob('/reports/export/monthly', { month: this.monthlyMonth, year: this.monthlyYear })
      .subscribe(blob => this.downloadBlob(blob, `monthly-report-${this.monthlyYear}-${String(this.monthlyMonth).padStart(2, '0')}.xlsx`));
  }

  exportAllTimeExcel() {
    this.api.getBlob('/reports/export/all-time')
      .subscribe(blob => this.downloadBlob(blob, 'all-time-report.xlsx'));
  }

  printReport() {
    window.print();
  }

  private downloadBlob(blob: Blob, filename: string) {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
  }
}
