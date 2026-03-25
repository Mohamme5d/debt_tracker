import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { ApiService } from '../../../core/services/api.service';
import { AdminUser } from '../../../core/models';
import { ResetPasswordDialogComponent } from './reset-password-dialog.component';

@Component({
  selector: 'app-admin-users',
  standalone: true,
  imports: [
    CommonModule, FormsModule, MatCardModule, MatTableModule,
    MatButtonModule, MatIconModule, MatInputModule, MatFormFieldModule,
    MatProgressSpinnerModule, MatTooltipModule, MatDialogModule
  ],
  template: `
    <div class="page-header">
      <h2 style="margin:0;font-size:1.4rem;font-weight:700">All Users</h2>
      <mat-form-field appearance="outline" style="width:280px">
        <mat-label>Search users...</mat-label>
        <input matInput [(ngModel)]="search" (ngModelChange)="onSearch($event)" />
        <mat-icon matSuffix>search</mat-icon>
      </mat-form-field>
    </div>

    @if (loading()) {
      <div style="text-align:center;padding:40px"><mat-spinner diameter="36"></mat-spinner></div>
    } @else {
      <mat-card>
        <mat-table [dataSource]="users()">
          <ng-container matColumnDef="name">
            <mat-header-cell *matHeaderCellDef>User</mat-header-cell>
            <mat-cell *matCellDef="let u">
              <div>
                <strong>{{ u.name }}</strong>
                <div style="font-size:11px;color:#666">{{ u.email }}</div>
              </div>
            </mat-cell>
          </ng-container>

          <ng-container matColumnDef="tenant">
            <mat-header-cell *matHeaderCellDef>Tenant</mat-header-cell>
            <mat-cell *matCellDef="let u">{{ u.tenantName }}</mat-cell>
          </ng-container>

          <ng-container matColumnDef="role">
            <mat-header-cell *matHeaderCellDef>Role</mat-header-cell>
            <mat-cell *matCellDef="let u">
              <span class="chip" [class.chip-blue]="u.role==='Owner'" [class.chip-gray]="u.role==='Employee'">
                {{ u.role }}
              </span>
            </mat-cell>
          </ng-container>

          <ng-container matColumnDef="status">
            <mat-header-cell *matHeaderCellDef>Status</mat-header-cell>
            <mat-cell *matCellDef="let u">
              <span class="chip" [class.chip-green]="u.isActive" [class.chip-red]="!u.isActive">
                {{ u.isActive ? 'Active' : 'Inactive' }}
              </span>
            </mat-cell>
          </ng-container>

          <ng-container matColumnDef="created">
            <mat-header-cell *matHeaderCellDef>Joined</mat-header-cell>
            <mat-cell *matCellDef="let u">{{ u.createdAt | date:'mediumDate' }}</mat-cell>
          </ng-container>

          <ng-container matColumnDef="actions">
            <mat-header-cell *matHeaderCellDef>Actions</mat-header-cell>
            <mat-cell *matCellDef="let u">
              <button mat-icon-button [matTooltip]="u.isActive ? 'Deactivate' : 'Activate'"
                [color]="u.isActive ? 'warn' : 'primary'" (click)="toggleStatus(u)">
                <mat-icon>{{ u.isActive ? 'block' : 'check_circle' }}</mat-icon>
              </button>
              <button mat-icon-button matTooltip="Reset password" (click)="resetPassword(u)">
                <mat-icon>lock_reset</mat-icon>
              </button>
            </mat-cell>
          </ng-container>

          <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
          <mat-row *matRowDef="let row; columns: cols"></mat-row>
        </mat-table>
        @if (!users().length) {
          <div style="text-align:center;padding:40px;color:#888">No users found.</div>
        }
      </mat-card>
    }
  `,
  styles: [`
    .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
    .chip { padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600; }
    .chip-green { background:#e8f5e9; color:#2e7d32; }
    .chip-red   { background:#ffebee; color:#c62828; }
    .chip-blue  { background:#e3f2fd; color:#1565c0; }
    .chip-gray  { background:#f5f5f5; color:#555; }
  `]
})
export class AdminUsersComponent implements OnInit {
  private api = inject(ApiService);
  private dialog = inject(MatDialog);

  users = signal<AdminUser[]>([]);
  loading = signal(true);
  search = '';
  cols = ['name', 'tenant', 'role', 'status', 'created', 'actions'];

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
    const ref = this.dialog.open(ResetPasswordDialogComponent, { data: u, width: '360px' });
    ref.afterClosed().subscribe(pw => {
      if (pw) this.api.post(`/admin/users/${u.id}/reset-password`, { newPassword: pw }).subscribe();
    });
  }
}
