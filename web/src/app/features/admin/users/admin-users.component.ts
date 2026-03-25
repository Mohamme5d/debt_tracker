import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { ApiService } from '../../../core/services/api.service';
import { AdminUser } from '../../../core/models';
import { ResetPasswordDialogComponent } from './reset-password-dialog.component';

@Component({
  selector: 'app-admin-users',
  standalone: true,
  imports: [CommonModule, FormsModule, MatDialogModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">All Users</h2>
      <div class="search-wrap">
        <span class="material-icons">search</span>
        <input class="form-control" type="text" [(ngModel)]="search"
          (ngModelChange)="onSearch($event)" placeholder="Search users..."
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
              <th>User</th>
              <th>Tenant</th>
              <th>Role</th>
              <th>Status</th>
              <th>Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            @for (u of users(); track u.id) {
              <tr>
                <td>
                  <div>
                    <strong>{{ u.name }}</strong>
                    <div style="font-size:11px;color:var(--text-secondary)">{{ u.email }}</div>
                  </div>
                </td>
                <td>{{ u.tenantName }}</td>
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
                <td style="font-size:12px;color:var(--text-secondary)">{{ u.createdAt | date:'mediumDate' }}</td>
                <td>
                  <button class="btn-icon" [class.danger]="u.isActive" [class.success]="!u.isActive"
                    [title]="u.isActive ? 'Deactivate' : 'Activate'" (click)="toggleStatus(u)">
                    <span class="material-icons">{{ u.isActive ? 'block' : 'check_circle' }}</span>
                  </button>
                  <button class="btn-icon" title="Reset password" (click)="resetPassword(u)">
                    <span class="material-icons">lock_reset</span>
                  </button>
                </td>
              </tr>
            }
            @if (!users().length) {
              <tr><td colspan="6" class="table-empty">No users found.</td></tr>
            }
          </tbody>
        </table>
      </div>
    }
  `
})
export class AdminUsersComponent implements OnInit {
  private api = inject(ApiService);
  private dialog = inject(MatDialog);

  users = signal<AdminUser[]>([]);
  loading = signal(true);
  search = '';

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
    this.api.put(`/admin/users/${u.id}/status`, { isActive: !u.isActive })
      .subscribe(() => this.load(this.search));
  }

  resetPassword(u: AdminUser) {
    const ref = this.dialog.open(ResetPasswordDialogComponent, {
      data: u, width: '360px', panelClass: 'dark-dialog'
    });
    ref.afterClosed().subscribe(pw => {
      if (pw) this.api.post(`/admin/users/${u.id}/reset-password`, { newPassword: pw }).subscribe();
    });
  }
}
