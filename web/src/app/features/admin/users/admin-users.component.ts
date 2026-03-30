import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../../core/services/api.service';
import { AdminUser } from '../../../core/models';

@Component({
  selector: 'app-admin-users',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
      <h2 style="margin:0;font-size:1.4rem;font-weight:700;color:#e6edf3">All Users</h2>
      <div style="position:relative">
        <span class="material-icons" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#8b949e;font-size:18px;pointer-events:none">search</span>
        <input style="background:#21262d;border:1px solid #30363d;border-radius:8px;color:#e6edf3;padding:8px 12px 8px 34px;font-size:13.5px;font-family:'Cairo',sans-serif;outline:none;width:260px"
          [(ngModel)]="search" (ngModelChange)="onSearch($event)" placeholder="Search users...">
      </div>
    </div>

    @if (loading()) {
      <div style="text-align:center;padding:40px;color:#8b949e">Loading...</div>
    } @else {
      <div style="background:#161b22;border:1px solid #30363d;border-radius:10px;overflow:hidden">
        <table style="width:100%;border-collapse:collapse">
          <thead>
            <tr style="background:#21262d;border-bottom:1px solid #30363d">
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">User</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Tenant</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Role</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Status</th>
              <th style="text-align:left;padding:10px 14px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.07em;color:#8b949e">Joined</th>
              <th style="width:90px"></th>
            </tr>
          </thead>
          <tbody>
            @for (u of users(); track u.id) {
              <tr style="border-bottom:1px solid #21262d">
                <td style="padding:12px 14px;color:#e6edf3">
                  <strong>{{ u.name }}</strong>
                  <div style="font-size:11px;color:#8b949e">{{ u.email }}</div>
                </td>
                <td style="padding:12px 14px;color:#8b949e;font-size:13px">{{ u.tenantName }}</td>
                <td style="padding:12px 14px">
                  <span style="padding:2px 10px;border-radius:999px;font-size:11.5px;font-weight:600"
                    [style.background]="u.role === 'Owner' ? 'rgba(129,140,248,.15)' : 'rgba(148,163,184,.1)'"
                    [style.color]="u.role === 'Owner' ? '#818cf8' : '#94a3b8'">{{ u.role }}</span>
                </td>
                <td style="padding:12px 14px">
                  <span style="padding:2px 10px;border-radius:999px;font-size:11.5px;font-weight:600"
                    [style.background]="u.isActive ? 'rgba(52,211,153,.15)' : 'rgba(248,113,113,.15)'"
                    [style.color]="u.isActive ? '#34d399' : '#f87171'">
                    {{ u.isActive ? 'Active' : 'Inactive' }}
                  </span>
                </td>
                <td style="padding:12px 14px;color:#8b949e;font-size:13px">{{ u.createdAt | date:'mediumDate' }}</td>
                <td style="padding:12px 14px;text-align:center">
                  <button class="btn-icon" [class]="u.isActive ? 'btn-icon-warn' : 'btn-icon-primary'"
                    [title]="u.isActive ? 'Deactivate' : 'Activate'" (click)="toggleStatus(u)">
                    <span class="material-icons">{{ u.isActive ? 'block' : 'check_circle' }}</span>
                  </button>
                  <button class="btn-icon" title="Reset password" (click)="resetUser.set(u)">
                    <span class="material-icons">lock_reset</span>
                  </button>
                </td>
              </tr>
            }
          </tbody>
        </table>
        @if (!users().length) {
          <div style="text-align:center;padding:40px;color:#8b949e">No users found.</div>
        }
      </div>
    }

    @if (resetUser()) {
      <div class="modal-overlay" (click)="resetUser.set(null)">
        <div class="modal" style="max-width:340px" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>Reset Password — {{ resetUser()!.name }}</h3>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label class="form-label">New Password</label>
              <input class="form-control" type="password" [(ngModel)]="newPassword">
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline" (click)="resetUser.set(null)">Cancel</button>
            <button class="btn btn-primary" [disabled]="newPassword.length < 6" (click)="confirmReset()">Set Password</button>
          </div>
        </div>
      </div>
    }
  `
})
export class AdminUsersComponent implements OnInit {
  private api = inject(ApiService);

  users = signal<AdminUser[]>([]);
  loading = signal(true);
  search = '';
  resetUser = signal<AdminUser | null>(null);
  newPassword = '';

  ngOnInit() { this.load(); }

  load(search = '') {
    this.loading.set(true);
    const params: Record<string, string | number> = {};
    if (search) params['search'] = search;
    this.api.get<AdminUser[]>('/admin/users', params).subscribe({
      next: u => { this.users.set(u); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  onSearch(val: string) { this.load(val); }

  toggleStatus(u: AdminUser) {
    this.api.put(`/admin/users/${u.id}/status`, { isActive: !u.isActive }).subscribe(() => this.load(this.search));
  }

  confirmReset() {
    const u = this.resetUser();
    if (!u || this.newPassword.length < 6) return;
    this.api.post(`/admin/users/${u.id}/reset-password`, { newPassword: this.newPassword }).subscribe(() => {
      this.resetUser.set(null);
      this.newPassword = '';
    });
  }
}
