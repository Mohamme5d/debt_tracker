import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { ApiService } from '../../../core/services/api.service';
import { AdminTenantListItem } from '../../../core/models';
import { TenantDetailDialogComponent } from './tenant-detail-dialog.component';

@Component({
  selector: 'app-admin-tenants',
  standalone: true,
  imports: [CommonModule, FormsModule, MatDialogModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Tenants Management</h2>
      <div class="search-wrap">
        <span class="material-icons">search</span>
        <input class="form-control" type="text" [(ngModel)]="search"
          (ngModelChange)="onSearch($event)" placeholder="Search tenants..."
          style="width:260px">
      </div>
    </div>

    @if (loading()) {
      <div style="text-align:center;padding:60px">
        <span class="spinner spinner-lg"></span>
      </div>
    } @else {
      <div class="card" style="padding:0;overflow:hidden">
        <table class="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Plan</th>
              <th>Resources</th>
              <th>Status</th>
              <th>Created</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            @for (t of tenants(); track t.id) {
              <tr>
                <td>
                  <div>
                    <strong>{{ t.name }}</strong>
                    <div style="font-size:11px;color:var(--text-secondary)">{{ t.email }}</div>
                  </div>
                </td>
                <td>
                  <span class="badge badge-primary">{{ t.plan }}</span>
                </td>
                <td>
                  <div style="display:flex;gap:4px;flex-wrap:wrap">
                    <span class="badge badge-neutral">{{ t.userCount }} users</span>
                    <span class="badge badge-neutral">{{ t.apartmentCount }} apts</span>
                    <span class="badge badge-neutral">{{ t.activeRenterCount }} renters</span>
                  </div>
                </td>
                <td>
                  <span class="badge" [class.badge-success]="t.isActive" [class.badge-danger]="!t.isActive">
                    {{ t.isActive ? 'Active' : 'Inactive' }}
                  </span>
                </td>
                <td style="font-size:12px;color:var(--text-secondary)">{{ t.createdAt | date:'mediumDate' }}</td>
                <td>
                  <button class="btn-icon" title="View details" (click)="viewDetail(t)">
                    <span class="material-icons">visibility</span>
                  </button>
                  <button class="btn-icon" title="{{ t.isActive ? 'Deactivate' : 'Activate' }}"
                    [class.danger]="t.isActive" [class.success]="!t.isActive"
                    (click)="toggleStatus(t)">
                    <span class="material-icons">{{ t.isActive ? 'block' : 'check_circle' }}</span>
                  </button>
                </td>
              </tr>
            }
            @if (!tenants().length) {
              <tr><td colspan="6" class="table-empty">No tenants found.</td></tr>
            }
          </tbody>
        </table>
      </div>
    }
  `
})
export class TenantsComponent implements OnInit {
  private api = inject(ApiService);
  private dialog = inject(MatDialog);

  tenants = signal<AdminTenantListItem[]>([]);
  loading = signal(true);
  search = '';

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

  viewDetail(t: AdminTenantListItem) {
    const ref = this.dialog.open(TenantDetailDialogComponent, {
      data: t.id, width: '700px', maxHeight: '90vh',
      panelClass: 'dark-dialog'
    });
    ref.afterClosed().subscribe(() => this.load(this.search));
  }

  toggleStatus(t: AdminTenantListItem) {
    this.api.put(`/admin/tenants/${t.id}/status`, { isActive: !t.isActive }).subscribe(() =>
      this.load(this.search)
    );
  }
}
