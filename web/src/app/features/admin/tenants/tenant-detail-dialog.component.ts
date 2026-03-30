import { Component, OnInit, OnChanges, signal, inject, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../../core/services/api.service';
import { AdminTenantDetail, AdminUser } from '../../../core/models';

@Component({
  selector: 'app-tenant-detail-dialog',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="modal-overlay" (click)="closed.emit()">
      <div class="modal" style="max-width:680px" (click)="$event.stopPropagation()">
        <div class="modal-header" style="display:flex;justify-content:space-between;align-items:center">
          <h3>Tenant: {{ tenant()?.name }}</h3>
          <button class="btn-icon" (click)="closed.emit()">
            <span class="material-icons">close</span>
          </button>
        </div>

        <div class="modal-body" style="max-height:65vh">
          @if (loading()) {
            <div style="text-align:center;padding:32px;color:#8b949e">Loading...</div>
          } @else if (tenant()) {
            <div style="display:flex;gap:10px;flex-wrap:wrap;margin-bottom:16px">
              <span style="font-size:13px;color:#8b949e">
                <span class="material-icons" style="font-size:15px;vertical-align:middle">email</span>
                {{ tenant()!.email }}
              </span>
              <span class="badge badge-primary">{{ tenant()!.plan }}</span>
              <span class="badge" [class]="tenant()!.isActive ? 'badge-accent' : 'badge-warn'">
                {{ tenant()!.isActive ? 'Active' : 'Inactive' }}
              </span>
            </div>

            <div style="display:flex;gap:12px;margin-bottom:18px;flex-wrap:wrap">
              <div class="mini-stat"><strong>{{ tenant()!.apartmentCount }}</strong><span>Apartments</span></div>
              <div class="mini-stat"><strong>{{ tenant()!.activeRenterCount }}</strong><span>Active Renters</span></div>
              <div class="mini-stat"><strong>{{ tenant()!.totalPayments }}</strong><span>Payments</span></div>
              <div class="mini-stat"><strong>{{ tenant()!.users.length }}</strong><span>Users</span></div>
            </div>

            <h4 style="margin:0 0 10px;font-weight:700;color:#e6edf3">Users</h4>
            <table style="width:100%;border-collapse:collapse">
              <thead>
                <tr>
                  <th style="text-align:left;padding:8px 12px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e;background:#21262d;border-bottom:1px solid #30363d">User</th>
                  <th style="text-align:left;padding:8px 12px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e;background:#21262d;border-bottom:1px solid #30363d">Role</th>
                  <th style="text-align:left;padding:8px 12px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e;background:#21262d;border-bottom:1px solid #30363d">Status</th>
                  <th style="text-align:center;padding:8px 12px;width:90px;background:#21262d;border-bottom:1px solid #30363d"></th>
                </tr>
              </thead>
              <tbody>
                @for (u of tenant()!.users; track u.id) {
                  <tr style="border-bottom:1px solid #30363d">
                    <td style="padding:10px 12px;color:#e6edf3">
                      <strong>{{ u.name }}</strong>
                      <div style="font-size:11px;color:#8b949e">{{ u.email }}</div>
                    </td>
                    <td style="padding:10px 12px">
                      <span class="badge" [class]="u.role === 'Owner' ? 'badge-primary' : 'badge-muted'">{{ u.role }}</span>
                    </td>
                    <td style="padding:10px 12px">
                      <span class="badge" [class]="u.isActive ? 'badge-accent' : 'badge-warn'">
                        {{ u.isActive ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td style="padding:10px 12px;text-align:center">
                      <button class="btn-icon" [class]="u.isActive ? 'btn-icon-warn' : 'btn-icon-primary'"
                        [title]="u.isActive ? 'Deactivate' : 'Activate'" (click)="toggleUser(u)">
                        <span class="material-icons">{{ u.isActive ? 'block' : 'check_circle' }}</span>
                      </button>
                      <button class="btn-icon" title="Reset password" (click)="resetPassword(u)">
                        <span class="material-icons">lock_reset</span>
                      </button>
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          }
        </div>

        <div class="modal-footer">
          <button class="btn" [class]="tenant()?.isActive ? 'btn-warn' : 'btn-primary'"
            (click)="toggleTenantStatus()">
            {{ tenant()?.isActive ? 'Deactivate Tenant' : 'Activate Tenant' }}
          </button>
          <button class="btn btn-outline" (click)="closed.emit()">Close</button>
        </div>
      </div>
    </div>

    @if (resetingUserId()) {
      <div class="modal-overlay" (click)="resetingUserId.set(null)">
        <div class="modal" style="max-width:340px" (click)="$event.stopPropagation()">
          <div class="modal-header"><h3>Reset Password</h3></div>
          <div class="modal-body">
            <div class="form-group">
              <label class="form-label">New Password</label>
              <input class="form-control" type="password" [(ngModel)]="newPassword">
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" (click)="resetingUserId.set(null)">Cancel</button>
            <button class="btn btn-primary" [disabled]="newPassword.length < 6" (click)="confirmReset()">Set Password</button>
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .mini-stat { background:#21262d; border:1px solid #30363d; border-radius:8px; padding:8px 16px; text-align:center; flex:1; min-width:80px; }
    .mini-stat strong { display:block; font-size:1.4rem; color:#e6edf3; font-weight:700; }
    .mini-stat span { font-size:11px; color:#8b949e; }
  `]
})
export class TenantDetailDialogComponent implements OnInit, OnChanges {
  @Input() tenantId!: string;
  @Output() closed = new EventEmitter<void>();

  private api = inject(ApiService);

  tenant = signal<AdminTenantDetail | null>(null);
  loading = signal(true);
  resetingUserId = signal<string | null>(null);
  newPassword = '';

  ngOnInit() { this.load(); }
  ngOnChanges() { if (this.tenantId) this.load(); }

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
