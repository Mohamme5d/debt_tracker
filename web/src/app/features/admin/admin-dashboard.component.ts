import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { PlatformStats } from '../../core/models';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h2 style="margin:0 0 24px;font-size:1.4rem;font-weight:700;color:#e6edf3">Platform Overview</h2>

    @if (loading()) {
      <div style="text-align:center;padding:40px;color:#8b949e">Loading...</div>
    } @else if (stats()) {
      <div class="adm-grid">
        <div class="adm-stat" style="--c:#818cf8">
          <span class="material-icons" style="color:#818cf8">business</span>
          <div class="adm-val">{{ stats()!.totalTenants }}</div>
          <div class="adm-lbl">Total Tenants</div>
        </div>
        <div class="adm-stat" style="--c:#34d399">
          <span class="material-icons" style="color:#34d399">check_circle</span>
          <div class="adm-val" style="color:#34d399">{{ stats()!.activeTenants }}</div>
          <div class="adm-lbl">Active Tenants</div>
        </div>
        <div class="adm-stat" style="--c:#f87171">
          <span class="material-icons" style="color:#f87171">block</span>
          <div class="adm-val" style="color:#f87171">{{ stats()!.inactiveTenants }}</div>
          <div class="adm-lbl">Inactive Tenants</div>
        </div>
        <div class="adm-stat" style="--c:#60a5fa">
          <span class="material-icons" style="color:#60a5fa">people</span>
          <div class="adm-val" style="color:#60a5fa">{{ stats()!.totalUsers }}</div>
          <div class="adm-lbl">Total Users</div>
        </div>
        <div class="adm-stat" style="--c:#fb923c">
          <span class="material-icons" style="color:#fb923c">apartment</span>
          <div class="adm-val" style="color:#fb923c">{{ stats()!.totalApartments }}</div>
          <div class="adm-lbl">Total Apartments</div>
        </div>
        <div class="adm-stat" style="--c:#2dd4bf">
          <span class="material-icons" style="color:#2dd4bf">person_pin</span>
          <div class="adm-val" style="color:#2dd4bf">{{ stats()!.totalActiveRenters }}</div>
          <div class="adm-lbl">Active Renters</div>
        </div>
        <div class="adm-stat" style="--c:#c084fc">
          <span class="material-icons" style="color:#c084fc">fiber_new</span>
          <div class="adm-val" style="color:#c084fc">{{ stats()!.newTenantsThisMonth }}</div>
          <div class="adm-lbl">New This Month</div>
        </div>
      </div>
    }
  `,
  styles: [`
    .adm-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(180px,1fr)); gap:14px; }
    .adm-stat {
      background:#161b22; border:1px solid #30363d; border-top:3px solid var(--c,#818cf8);
      border-radius:10px; padding:18px; text-align:center;
    }
    .adm-stat .material-icons { font-size:30px; }
    .adm-val { font-size:1.8rem; font-weight:800; color:#e6edf3; margin:8px 0 4px; }
    .adm-lbl { font-size:11px; color:#8b949e; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }
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
