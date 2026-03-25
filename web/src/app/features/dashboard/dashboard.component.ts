import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { DashboardStats } from '../../core/models';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h2 class="page-title" style="margin-bottom:24px">Dashboard</h2>
    @if (stats()) {
      <div class="stats-grid">
        <div class="stat-card">
          <span class="material-icons stat-icon">apartment</span>
          <div class="stat-value">{{ stats()!.totalApartments }}</div>
          <div class="stat-label">Apartments</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon">people</span>
          <div class="stat-value">{{ stats()!.activeRenters }}</div>
          <div class="stat-label">Active Renters</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon">payments</span>
          <div class="stat-value">{{ stats()!.totalCollectedThisMonth | number:'1.0-0' }}</div>
          <div class="stat-label">Collected This Month</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon text-danger">warning</span>
          <div class="stat-value text-danger">{{ stats()!.totalOutstanding | number:'1.0-0' }}</div>
          <div class="stat-label">Total Outstanding</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon">receipt</span>
          <div class="stat-value">{{ stats()!.totalExpensesThisMonth | number:'1.0-0' }}</div>
          <div class="stat-label">Expenses This Month</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon" [class.text-warning]="stats()!.pendingApprovals > 0">approval</span>
          <div class="stat-value" [class.text-warning]="stats()!.pendingApprovals > 0">
            {{ stats()!.pendingApprovals }}
          </div>
          <div class="stat-label">Pending Approvals</div>
        </div>
        <div class="stat-card">
          <span class="material-icons stat-icon">notifications</span>
          <div class="stat-value">{{ stats()!.unreadNotifications }}</div>
          <div class="stat-label">Unread Notifications</div>
        </div>
      </div>
    } @else {
      <div style="text-align:center;padding:60px">
        <span class="spinner spinner-lg"></span>
      </div>
    }
  `
})
export class DashboardComponent implements OnInit {
  private api = inject(ApiService);
  stats = signal<DashboardStats | null>(null);

  ngOnInit() {
    this.api.get<DashboardStats>('/dashboard').subscribe(s => this.stats.set(s));
  }
}
