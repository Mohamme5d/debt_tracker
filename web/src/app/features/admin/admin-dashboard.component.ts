import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ApiService } from '../../core/services/api.service';
import { PlatformStats } from '../../core/models';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatIconModule, MatProgressSpinnerModule],
  template: `
    <h2 style="margin:0 0 24px;font-size:1.4rem;font-weight:700">Platform Overview</h2>

    @if (loading()) {
      <div style="text-align:center;padding:40px"><mat-spinner diameter="40"></mat-spinner></div>
    } @else if (stats()) {
      <div class="stats-grid">
        <div class="stat-card primary">
          <mat-icon class="stat-icon">business</mat-icon>
          <div class="stat-value">{{ stats()!.totalTenants }}</div>
          <div class="stat-label">Total Tenants</div>
        </div>
        <div class="stat-card success">
          <mat-icon class="stat-icon">check_circle</mat-icon>
          <div class="stat-value">{{ stats()!.activeTenants }}</div>
          <div class="stat-label">Active Tenants</div>
        </div>
        <div class="stat-card danger">
          <mat-icon class="stat-icon">block</mat-icon>
          <div class="stat-value">{{ stats()!.inactiveTenants }}</div>
          <div class="stat-label">Inactive Tenants</div>
        </div>
        <div class="stat-card info">
          <mat-icon class="stat-icon">people</mat-icon>
          <div class="stat-value">{{ stats()!.totalUsers }}</div>
          <div class="stat-label">Total Users</div>
        </div>
        <div class="stat-card warning">
          <mat-icon class="stat-icon">apartment</mat-icon>
          <div class="stat-value">{{ stats()!.totalApartments }}</div>
          <div class="stat-label">Total Apartments</div>
        </div>
        <div class="stat-card teal">
          <mat-icon class="stat-icon">person_pin</mat-icon>
          <div class="stat-value">{{ stats()!.totalActiveRenters }}</div>
          <div class="stat-label">Active Renters</div>
        </div>
        <div class="stat-card purple">
          <mat-icon class="stat-icon">fiber_new</mat-icon>
          <div class="stat-value">{{ stats()!.newTenantsThisMonth }}</div>
          <div class="stat-label">New This Month</div>
        </div>
      </div>
    }
  `,
  styles: [`
    .stats-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:16px; }
    .stat-card {
      background:#fff; border-radius:12px; padding:20px; text-align:center;
      box-shadow:0 2px 8px rgba(0,0,0,0.08); border-top:4px solid #ccc;
    }
    .stat-icon { font-size:32px;width:32px;height:32px; color:#aaa; margin-bottom:8px; }
    .stat-value { font-size:2rem; font-weight:700; color:#333; }
    .stat-label { font-size:0.8rem; color:#888; margin-top:4px; }
    .primary { border-color:#3f51b5; } .primary .stat-icon,.primary .stat-value { color:#3f51b5; }
    .success { border-color:#4caf50; } .success .stat-icon,.success .stat-value { color:#4caf50; }
    .danger  { border-color:#f44336; } .danger  .stat-icon,.danger  .stat-value { color:#f44336; }
    .info    { border-color:#2196f3; } .info    .stat-icon,.info    .stat-value { color:#2196f3; }
    .warning { border-color:#ff9800; } .warning .stat-icon,.warning .stat-value { color:#ff9800; }
    .teal    { border-color:#009688; } .teal    .stat-icon,.teal    .stat-value { color:#009688; }
    .purple  { border-color:#9c27b0; } .purple  .stat-icon,.purple  .stat-value { color:#9c27b0; }
  `]
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
