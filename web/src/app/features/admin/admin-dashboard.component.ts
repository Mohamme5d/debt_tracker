import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { PlatformStats } from '../../core/models';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h2 class="page-title" style="margin-bottom:24px">Platform Overview</h2>

    @if (loading()) {
      <div style="text-align:center;padding:60px">
        <span class="spinner spinner-lg"></span>
      </div>
    } @else if (stats()) {
      <div class="stats-grid">
        <div class="stat-card" style="border-top:3px solid var(--primary)">
          <span class="material-icons stat-icon">business</span>
          <div class="stat-value">{{ stats()!.totalTenants }}</div>
          <div class="stat-label">Total Tenants</div>
        </div>
        <div class="stat-card" style="border-top:3px solid var(--success)">
          <span class="material-icons stat-icon text-success">check_circle</span>
          <div class="stat-value text-success">{{ stats()!.activeTenants }}</div>
          <div class="stat-label">Active Tenants</div>
        </div>
        <div class="stat-card" style="border-top:3px solid var(--danger)">
          <span class="material-icons stat-icon text-danger">block</span>
          <div class="stat-value text-danger">{{ stats()!.inactiveTenants }}</div>
          <div class="stat-label">Inactive Tenants</div>
        </div>
        <div class="stat-card" style="border-top:3px solid #3b82f6">
          <span class="material-icons stat-icon" style="color:#3b82f6">people</span>
          <div class="stat-value" style="color:#3b82f6">{{ stats()!.totalUsers }}</div>
          <div class="stat-label">Total Users</div>
        </div>
        <div class="stat-card" style="border-top:3px solid var(--warning)">
          <span class="material-icons stat-icon text-warning">apartment</span>
          <div class="stat-value text-warning">{{ stats()!.totalApartments }}</div>
          <div class="stat-label">Total Apartments</div>
        </div>
        <div class="stat-card" style="border-top:3px solid #14b8a6">
          <span class="material-icons stat-icon" style="color:#14b8a6">person_pin</span>
          <div class="stat-value" style="color:#14b8a6">{{ stats()!.totalActiveRenters }}</div>
          <div class="stat-label">Active Renters</div>
        </div>
        <div class="stat-card" style="border-top:3px solid #a855f7">
          <span class="material-icons stat-icon" style="color:#a855f7">fiber_new</span>
          <div class="stat-value" style="color:#a855f7">{{ stats()!.newTenantsThisMonth }}</div>
          <div class="stat-label">New This Month</div>
        </div>
      </div>
    }
  `
})
export class AdminDashboardComponent implements OnInit {
  private api = inject(ApiService);
  stats = signal<PlatformStats | null>(null);
  loading = signal(true);

  ngOnInit() {
    this.api.get<PlatformStats>('/admin/stats').subscribe({
      next: s => { this.stats.set(s); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }
}
