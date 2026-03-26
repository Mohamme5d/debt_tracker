import { Component, OnInit, OnDestroy, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { DashboardStats, MonthlyTrendPoint } from '../../core/models';

declare const Chart: any;

const MONTH_NAMES = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="page-header" style="margin-bottom:24px">
      <div>
        <h2 class="page-title">Dashboard</h2>
        <p class="text-secondary" style="margin:4px 0 0;font-size:13px">
          {{ isOwner ? 'Owner overview — all apartments' : 'Your assigned apartments' }}
        </p>
      </div>
      @if (isOwner && stats()?.pendingApprovals) {
        <a class="btn btn-primary" routerLink="/approvals" style="gap:6px">
          <span class="material-icons" style="font-size:18px">approval</span>
          {{ stats()!.pendingApprovals }} Pending Approval{{ stats()!.pendingApprovals === 1 ? '' : 's' }}
        </a>
      }
    </div>

    <!-- Stats -->
    @if (stats(); as s) {
      <div class="stats-grid" style="margin-bottom:28px">
        <div class="stat-card">
          <span class="material-icons stat-icon" style="color:#2563EB">apartment</span>
          <div class="stat-value">{{ s.totalApartments }}</div>
          <div class="stat-label">{{ isOwner ? 'Total' : 'Assigned' }} Apartments</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon" style="color:#10B981">people</span>
          <div class="stat-value">{{ s.activeRenters }}</div>
          <div class="stat-label">Active Renters</div>
        </div>
        <div class="stat-card" style="border-color:#2563EB">
          <span class="material-icons stat-icon" style="color:#2563EB">payments</span>
          <div class="stat-value" style="color:#2563EB">{{ s.totalCollectedThisMonth | number:'1.0-0' }}</div>
          <div class="stat-label">Collected This Month</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon" style="color:#F43F5E">warning_amber</span>
          <div class="stat-value" [class.text-danger]="s.totalOutstanding > 0">{{ s.totalOutstanding | number:'1.0-0' }}</div>
          <div class="stat-label">Outstanding Balance</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon" style="color:#F59E0B">receipt_long</span>
          <div class="stat-value">{{ s.totalExpensesThisMonth | number:'1.0-0' }}</div>
          <div class="stat-label">Expenses This Month</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon" style="color:#8B5CF6">notifications</span>
          <div class="stat-value" [class.text-warning]="s.unreadNotifications > 0">{{ s.unreadNotifications }}</div>
          <div class="stat-label">Unread Notifications</div>
        </div>
        @if (isOwner) {
          <div class="stat-card" [style.border-color]="s.pendingApprovals > 0 ? 'var(--warning)' : ''">
            <span class="material-icons stat-icon" [style.color]="s.pendingApprovals > 0 ? '#F59E0B' : 'inherit'">pending_actions</span>
            <div class="stat-value" [class.text-warning]="s.pendingApprovals > 0">{{ s.pendingApprovals }}</div>
            <div class="stat-label">Pending Approvals</div>
          </div>
        }
      </div>
    } @else {
      <div class="stats-grid" style="margin-bottom:28px">
        @for (_ of [1,2,3,4,5,6]; track $index) {
          <div class="stat-card" style="min-height:100px;animation:pulse 1.5s ease-in-out infinite"></div>
        }
      </div>
    }

    <!-- 6-Month Trend Chart -->
    <div class="card" style="margin-bottom:24px">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px">
        <div>
          <h3 style="font-size:1rem;font-weight:600;margin-bottom:2px">6-Month Performance</h3>
          <p class="text-secondary" style="font-size:12px;margin:0">Rent collected vs expenses</p>
        </div>
        <div style="display:flex;gap:16px;font-size:12px">
          <span style="display:flex;align-items:center;gap:6px">
            <span style="width:12px;height:12px;border-radius:3px;background:#2563EB;display:inline-block"></span>
            Collected
          </span>
          <span style="display:flex;align-items:center;gap:6px">
            <span style="width:12px;height:3px;border-radius:2px;background:#F43F5E;display:inline-block"></span>
            Expenses
          </span>
        </div>
      </div>
      <div style="position:relative;height:260px">
        <canvas id="ijari-trend-chart"></canvas>
        @if (!trendLoaded()) {
          <div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center">
            <span class="spinner spinner-lg"></span>
          </div>
        }
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="card">
      <h3 style="font-size:1rem;font-weight:600;margin-bottom:16px">Quick Actions</h3>
      <div style="display:flex;gap:12px;flex-wrap:wrap">
        <a class="btn btn-ghost" routerLink="/payments" style="gap:6px">
          <span class="material-icons" style="font-size:18px">payments</span> Payments
        </a>
        <a class="btn btn-ghost" routerLink="/renters" style="gap:6px">
          <span class="material-icons" style="font-size:18px">person</span> Renters
        </a>
        <a class="btn btn-ghost" routerLink="/expenses" style="gap:6px">
          <span class="material-icons" style="font-size:18px">receipt</span> Expenses
        </a>
        <a class="btn btn-ghost" routerLink="/deposits" style="gap:6px">
          <span class="material-icons" style="font-size:18px">savings</span> Deposits
        </a>
        <a class="btn btn-ghost" routerLink="/reports" style="gap:6px">
          <span class="material-icons" style="font-size:18px">bar_chart</span> Reports
        </a>
        @if (isOwner) {
          <a class="btn btn-ghost" routerLink="/approvals" style="gap:6px">
            <span class="material-icons" style="font-size:18px">approval</span> Approvals
          </a>
          <a class="btn btn-ghost" routerLink="/apartments" style="gap:6px">
            <span class="material-icons" style="font-size:18px">apartment</span> Apartments
          </a>
          <a class="btn btn-ghost" routerLink="/employees" style="gap:6px">
            <span class="material-icons" style="font-size:18px">badge</span> Employees
          </a>
        }
      </div>
    </div>
  `,
  styles: [`
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.4; }
    }
  `]
})
export class DashboardComponent implements OnInit, OnDestroy {
  private api = inject(ApiService);
  private auth = inject(AuthService);

  stats = signal<DashboardStats | null>(null);
  trendLoaded = signal(false);
  get isOwner() { return this.auth.isOwner; }

  private chart: any = null;

  ngOnInit() {
    this.api.get<DashboardStats>('/dashboard').subscribe(s => this.stats.set(s));
    this.api.get<MonthlyTrendPoint[]>('/dashboard/trend').subscribe(points => {
      this.trendLoaded.set(true);
      setTimeout(() => this.renderChart(points), 0);
    });
  }

  ngOnDestroy() {
    if (this.chart) { this.chart.destroy(); this.chart = null; }
  }

  private renderChart(points: MonthlyTrendPoint[]) {
    const canvas = document.getElementById('ijari-trend-chart') as HTMLCanvasElement;
    if (!canvas || typeof Chart === 'undefined') return;
    if (this.chart) this.chart.destroy();

    const labels = points.map(p => `${MONTH_NAMES[p.month - 1]} ${p.year}`);
    const collected = points.map(p => p.collected);
    const expenses = points.map(p => p.expenses);

    this.chart = new Chart(canvas, {
      data: {
        labels,
        datasets: [
          {
            type: 'bar',
            label: 'Collected',
            data: collected,
            backgroundColor: 'rgba(37,99,235,0.75)',
            borderColor: '#2563EB',
            borderWidth: 1,
            borderRadius: 6,
            order: 2
          },
          {
            type: 'line',
            label: 'Expenses',
            data: expenses,
            borderColor: '#F43F5E',
            backgroundColor: 'rgba(244,63,94,0.1)',
            borderWidth: 2,
            pointBackgroundColor: '#F43F5E',
            pointRadius: 4,
            tension: 0.4,
            fill: true,
            order: 1
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: '#1E293B',
            borderColor: '#334155',
            borderWidth: 1,
            titleColor: '#F1F5F9',
            bodyColor: '#94A3B8',
            callbacks: {
              label: (ctx: any) => ` ${ctx.dataset.label}: ${ctx.parsed.y.toLocaleString()}`
            }
          }
        },
        scales: {
          x: {
            grid: { color: '#334155' },
            ticks: { color: '#94A3B8', font: { size: 11 } }
          },
          y: {
            beginAtZero: true,
            grid: { color: '#334155' },
            ticks: {
              color: '#94A3B8',
              font: { size: 11 },
              callback: (v: any) => v.toLocaleString()
            }
          }
        }
      }
    });
  }
}
