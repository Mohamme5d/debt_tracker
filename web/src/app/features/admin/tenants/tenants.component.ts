import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../../core/services/api.service';
import { AdminTenantListItem } from '../../../core/models';
import { TenantDetailDialogComponent } from './tenant-detail-dialog.component';

@Component({
  selector: 'app-admin-tenants',
  standalone: true,
  imports: [CommonModule, FormsModule, TenantDetailDialogComponent],
  template: `
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
      <h2 style="margin:0;font-size:1.4rem;font-weight:700;color:#e6edf3">Tenants Management</h2>
      <div style="position:relative">
        <span class="material-icons" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#8b949e;font-size:18px;pointer-events:none">search</span>
        <input style="background:#21262d;border:1px solid #30363d;border-radius:8px;color:#e6edf3;padding:8px 12px 8px 34px;font-size:13.5px;font-family:'Cairo',sans-serif;outline:none;width:260px"
          [(ngModel)]="search" (ngModelChange)="onSearch($event)" placeholder="Search tenants...">
      </div>
    </div>

    @if (loading()) {
      <div style="text-align:center;padding:40px;color:#8b949e">Loading...</div>
    } @else {
      <div style="background:#161b22;border:1px solid #30363d;border-radius:10px;overflow:hidden">
        <table style="width:100%;border-collapse:collapse">
          <thead>
            <tr style="background:#21262d;border-bottom:1px solid #30363d">
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Name</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Plan</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Resources</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Status</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Created</th>
              <th style="width:90px"></th>
            </tr>
          </thead>
          <tbody>
            @for (t of tenants(); track t.id) {
              <tr style="border-bottom:1px solid #21262d">
                <td style="padding:12px 14px;color:#e6edf3">
                  <strong>{{ t.name }}</strong>
                  <div style="font-size:11px;color:#8b949e">{{ t.email }}</div>
                </td>
                <td style="padding:12px 14px">
                  <span style="background:rgba(129,140,248,.15);color:#818cf8;padding:2px 10px;border-radius:999px;font-size:11.5px;font-weight:600">{{ t.plan }}</span>
                </td>
                <td style="padding:12px 14px">
                  <span style="background:#21262d;color:#8b949e;padding:2px 8px;border-radius:999px;font-size:11px;margin-right:4px">{{ t.userCount }} users</span>
                  <span style="background:#21262d;color:#8b949e;padding:2px 8px;border-radius:999px;font-size:11px;margin-right:4px">{{ t.apartmentCount }} apts</span>
                  <span style="background:#21262d;color:#8b949e;padding:2px 8px;border-radius:999px;font-size:11px">{{ t.activeRenterCount }} renters</span>
                </td>
                <td style="padding:12px 14px">
                  <span style="padding:2px 10px;border-radius:999px;font-size:11.5px;font-weight:600"
                    [style.background]="t.isActive ? 'rgba(52,211,153,.15)' : 'rgba(248,113,113,.15)'"
                    [style.color]="t.isActive ? '#34d399' : '#f87171'">
                    {{ t.isActive ? 'Active' : 'Inactive' }}
                  </span>
                </td>
                <td style="padding:12px 14px;color:#8b949e;font-size:13px">{{ t.createdAt | date:'mediumDate' }}</td>
                <td style="padding:12px 14px;text-align:center">
                  <button class="btn-icon" title="View details" (click)="viewDetail(t.id)">
                    <span class="material-icons">visibility</span>
                  </button>
                  <button class="btn-icon" [class]="t.isActive ? 'btn-icon-warn' : 'btn-icon-primary'"
                    [title]="t.isActive ? 'Deactivate' : 'Activate'" (click)="toggleStatus(t)">
                    <span class="material-icons">{{ t.isActive ? 'block' : 'check_circle' }}</span>
                  </button>
                </td>
              </tr>
            }
          </tbody>
        </table>
        @if (!tenants().length) {
          <div style="text-align:center;padding:40px;color:#8b949e">No tenants found.</div>
        }
      </div>
    }

    @if (selectedTenantId()) {
      <app-tenant-detail-dialog
        [tenantId]="selectedTenantId()!"
        (closed)="selectedTenantId.set(null); load(search)">
      </app-tenant-detail-dialog>
    }
  `
})
export class TenantsComponent implements OnInit {
  private api = inject(ApiService);

  tenants = signal<AdminTenantListItem[]>([]);
  loading = signal(true);
  search = '';
  selectedTenantId = signal<string | null>(null);

  ngOnInit() { this.load(); }

  load(search = '') {
    this.loading.set(true);
    const params: Record<string, string | number> = {};
    if (search) params['search'] = search;
    this.api.get<AdminTenantListItem[]>('/admin/tenants', params).subscribe({
      next: t => { this.tenants.set(t); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  onSearch(val: string) { this.load(val); }

  viewDetail(id: string) { this.selectedTenantId.set(id); }

  toggleStatus(t: AdminTenantListItem) {
    this.api.put(`/admin/tenants/${t.id}/status`, { isActive: !t.isActive }).subscribe(() => this.load(this.search));
  }
}
