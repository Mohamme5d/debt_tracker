import { Component, OnInit, signal, inject, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { ApiService } from '../../../core/services/api.service';
import { AdminTenantDetail, AdminUser } from '../../../core/models';

@Component({
  selector: 'app-tenant-detail-dialog',
  standalone: true,
  imports: [CommonModule, FormsModule, MatDialogModule],
  template: `
    <div class="modal-header">
      <span class="modal-title">Tenant: {{ tenant()?.name }}</span>
      <button class="btn-icon" mat-dialog-close>
        <span class="material-icons">close</span>
      </button>
    </div>

    <div class="modal-body">
      @if (loading()) {
        <div style="text-align:center;padding:32px">
          <span class="spinner spinner-lg"></span>
        </div>
      } @else if (tenant()) {
        <!-- Summary -->
        <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:16px">
          <div class="info-pill">
            <span class="material-icons">email</span> {{ tenant()!.email }}
          </div>
          <span class="badge badge-primary">{{ tenant()!.plan }}</span>
          <span class="badge" [class.badge-success]="tenant()!.isActive" [class.badge-danger]="!tenant()!.isActive">
            {{ tenant()!.isActive ? 'Active' : 'Inactive' }}
          </span>
        </div>

        <!-- Mini stats -->
        <div class="mini-stats">
          <div class="mini-stat">
            <strong>{{ tenant()!.apartmentCount }}</strong>
            <span>Apartments</span>
          </div>
          <div class="mini-stat">
            <strong>{{ tenant()!.activeRenterCount }}</strong>
            <span>Active Renters</span>
          </div>
          <div class="mini-stat">
            <strong>{{ tenant()!.totalPayments }}</strong>
            <span>Payments</span>
          </div>
          <div class="mini-stat">
            <strong>{{ tenant()!.users.length }}</strong>
            <span>Users</span>
          </div>
        </div>

        <!-- Users tab -->
        <h4 style="margin-bottom:12px;font-size:0.9rem;color:var(--text-secondary)">Users</h4>
        <div style="overflow:hidden;border-radius:8px;border:1px solid var(--border)">
          <table class="data-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Role</th>
                <th>Status</th>
                <th style="width:90px"></th>
              </tr>
            </thead>
            <tbody>
              @for (u of tenant()!.users; track u.id) {
                <tr>
                  <td>
                    <div>
                      <strong>{{ u.name }}</strong>
                      <div style="font-size:11px;color:var(--text-secondary)">{{ u.email }}</div>
                    </div>
                  </td>
                  <td>
                    <span class="badge" [class.badge-primary]="u.role === 'Owner'" [class.badge-neutral]="u.role !== 'Owner'">
                      {{ u.role }}
                    </span>
                  </td>
                  <td>
                    <span class="badge" [class.badge-success]="u.isActive" [class.badge-danger]="!u.isActive">
                      {{ u.isActive ? 'Active' : 'Inactive' }}
                    </span>
                  </td>
                  <td>
                    <button class="btn-icon" [class.danger]="u.isActive" [class.success]="!u.isActive"
                      [title]="u.isActive ? 'Deactivate' : 'Activate'" (click)="toggleUser(u)">
                      <span class="material-icons">{{ u.isActive ? 'block' : 'check_circle' }}</span>
                    </button>
                    <button class="btn-icon" title="Reset password" (click)="resetPassword(u)">
                      <span class="material-icons">lock_reset</span>
                    </button>
                  </td>
                </tr>
              }
              @if (!tenant()!.users.length) {
                <tr><td colspan="4" class="table-empty">No users.</td></tr>
              }
            </tbody>
          </table>
        </div>
      }
    </div>

    <div class="modal-footer">
      <button class="btn" [class.btn-danger]="tenant()?.isActive" [class.btn-success]="!tenant()?.isActive"
        (click)="toggleTenantStatus()">
        {{ tenant()?.isActive ? 'Deactivate Tenant' : 'Activate Tenant' }}
      </button>
      <button class="btn btn-ghost" mat-dialog-close>Close</button>
    </div>

    <!-- Reset password overlay -->
    @if (resetingUserId()) {
      <div class="modal-overlay" style="position:fixed;z-index:9999">
        <div class="modal-panel" style="max-width:340px">
          <div class="modal-header">
            <span class="modal-title">Reset Password</span>
          </div>
          <div class="modal-body">
            <div class="form-group" style="margin-bottom:0">
              <label class="form-label">New Password</label>
              <input class="form-control" type="password" [(ngModel)]="newPassword" placeholder="Min 6 characters">
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-ghost" (click)="resetingUserId.set(null)">Cancel</button>
            <button class="btn btn-primary" [disabled]="newPassword.length < 6" (click)="confirmReset()">Set Password</button>
          </div>
        </div>
      </div>
    }
  `
})
export class TenantDetailDialogComponent implements OnInit {
  private api = inject(ApiService);
  private dialogRef = inject(MatDialogRef<TenantDetailDialogComponent>);

  tenant = signal<AdminTenantDetail | null>(null);
  loading = signal(true);
  resetingUserId = signal<string | null>(null);
  newPassword = '';

  constructor(@Inject(MAT_DIALOG_DATA) public tenantId: string) {}

  ngOnInit() { this.load(); }

  load() {
    this.loading.set(true);
    this.api.get<AdminTenantDetail>(`/admin/tenants/${this.tenantId}`).subscribe({
      next: t => { this.tenant.set(t); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  toggleTenantStatus() {
    const t = this.tenant();
    if (!t) return;
    this.api.put(`/admin/tenants/${t.id}/status`, { isActive: !t.isActive }).subscribe(() => this.load());
  }

  toggleUser(u: AdminUser) {
    this.api.put(`/admin/users/${u.id}/status`, { isActive: !u.isActive }).subscribe(() => this.load());
  }

  resetPassword(u: AdminUser) {
    this.resetingUserId.set(u.id);
    this.newPassword = '';
  }

  confirmReset() {
    const uid = this.resetingUserId();
    if (!uid || !this.newPassword) return;
    this.api.post(`/admin/users/${uid}/reset-password`, { newPassword: this.newPassword }).subscribe(() => {
      this.resetingUserId.set(null);
      this.newPassword = '';
    });
  }
}
