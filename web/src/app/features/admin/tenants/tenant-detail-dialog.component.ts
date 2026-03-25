import { Component, OnInit, signal, inject, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatTabsModule } from '@angular/material/tabs';
import { MatTableModule } from '@angular/material/table';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ApiService } from '../../../core/services/api.service';
import { AdminTenantDetail, AdminUser } from '../../../core/models';

@Component({
  selector: 'app-tenant-detail-dialog',
  standalone: true,
  imports: [
    CommonModule, FormsModule, MatDialogModule, MatButtonModule, MatIconModule,
    MatChipsModule, MatTabsModule, MatTableModule, MatInputModule, MatFormFieldModule,
    MatProgressSpinnerModule
  ],
  template: `
    <div mat-dialog-title style="display:flex;justify-content:space-between;align-items:center">
      <span>Tenant: {{ tenant()?.name }}</span>
      <button mat-icon-button mat-dialog-close><mat-icon>close</mat-icon></button>
    </div>

    <mat-dialog-content>
      @if (loading()) {
        <div style="text-align:center;padding:32px"><mat-spinner diameter="32"></mat-spinner></div>
      } @else if (tenant()) {
        <!-- Summary row -->
        <div style="display:flex;gap:12px;flex-wrap:wrap;margin-bottom:16px">
          <div class="info-pill"><mat-icon>email</mat-icon> {{ tenant()!.email }}</div>
          <div class="info-pill"><span class="chip chip-blue">{{ tenant()!.plan }}</span></div>
          <div class="info-pill">
            <span class="chip" [class.chip-green]="tenant()!.isActive" [class.chip-red]="!tenant()!.isActive">
              {{ tenant()!.isActive ? 'Active' : 'Inactive' }}
            </span>
          </div>
        </div>

        <div class="mini-stats">
          <div class="mini-stat"><strong>{{ tenant()!.apartmentCount }}</strong><span>Apartments</span></div>
          <div class="mini-stat"><strong>{{ tenant()!.activeRenterCount }}</strong><span>Active Renters</span></div>
          <div class="mini-stat"><strong>{{ tenant()!.totalPayments }}</strong><span>Payments</span></div>
          <div class="mini-stat"><strong>{{ tenant()!.users.length }}</strong><span>Users</span></div>
        </div>

        <mat-tab-group>
          <mat-tab label="Users">
            <div style="padding-top:12px">
              <mat-table [dataSource]="tenant()!.users">
                <ng-container matColumnDef="name">
                  <mat-header-cell *matHeaderCellDef>Name</mat-header-cell>
                  <mat-cell *matCellDef="let u">
                    <div>
                      <strong>{{ u.name }}</strong>
                      <div style="font-size:11px;color:#666">{{ u.email }}</div>
                    </div>
                  </mat-cell>
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
                <ng-container matColumnDef="actions">
                  <mat-header-cell *matHeaderCellDef></mat-header-cell>
                  <mat-cell *matCellDef="let u">
                    <button mat-icon-button [color]="u.isActive ? 'warn' : 'primary'"
                      [title]="u.isActive ? 'Deactivate' : 'Activate'"
                      (click)="toggleUser(u)">
                      <mat-icon>{{ u.isActive ? 'block' : 'check_circle' }}</mat-icon>
                    </button>
                    <button mat-icon-button title="Reset password" (click)="resetPassword(u)">
                      <mat-icon>lock_reset</mat-icon>
                    </button>
                  </mat-cell>
                </ng-container>
                <mat-header-row *matHeaderRowDef="['name','role','status','actions']"></mat-header-row>
                <mat-row *matRowDef="let r; columns:['name','role','status','actions']"></mat-row>
              </mat-table>
            </div>
          </mat-tab>
        </mat-tab-group>
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button mat-flat-button [color]="tenant()?.isActive ? 'warn' : 'primary'"
        (click)="toggleTenantStatus()">
        {{ tenant()?.isActive ? 'Deactivate Tenant' : 'Activate Tenant' }}
      </button>
      <button mat-button mat-dialog-close>Close</button>
    </mat-dialog-actions>

    <!-- Reset password inline form -->
    @if (resetingUserId()) {
      <div class="reset-overlay">
        <mat-card style="padding:20px;max-width:320px">
          <h4 style="margin:0 0 12px">Reset Password</h4>
          <mat-form-field appearance="outline" style="width:100%">
            <mat-label>New Password</mat-label>
            <input matInput type="password" [(ngModel)]="newPassword" />
          </mat-form-field>
          <div style="display:flex;gap:8px;justify-content:flex-end">
            <button mat-button (click)="resetingUserId.set(null)">Cancel</button>
            <button mat-flat-button color="primary" (click)="confirmReset()">Set Password</button>
          </div>
        </mat-card>
      </div>
    }
  `,
  styles: [`
    .chip { padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600; }
    .chip-green { background:#e8f5e9; color:#2e7d32; }
    .chip-red   { background:#ffebee; color:#c62828; }
    .chip-blue  { background:#e3f2fd; color:#1565c0; }
    .chip-gray  { background:#f5f5f5; color:#555; }
    .info-pill { display:flex; align-items:center; gap:4px; font-size:13px; }
    .mini-stats { display:flex; gap:16px; margin-bottom:16px; }
    .mini-stat { background:#f9f9f9; border-radius:8px; padding:8px 16px; text-align:center; flex:1; }
    .mini-stat strong { display:block; font-size:1.4rem; color:#333; }
    .mini-stat span { font-size:11px; color:#888; }
    .reset-overlay { position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.4);
      display:flex; align-items:center; justify-content:center; z-index:9999; }
  `]
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
