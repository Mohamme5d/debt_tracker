import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { ApiService } from '../../../core/services/api.service';
import { AdminTenantListItem } from '../../../core/models';
import { TenantDetailDialogComponent } from './tenant-detail-dialog.component';

@Component({
  selector: 'app-admin-tenants',
  standalone: true,
  imports: [
    CommonModule, FormsModule, RouterLink, MatCardModule, MatTableModule,
    MatButtonModule, MatIconModule, MatInputModule, MatFormFieldModule,
    MatChipsModule, MatProgressSpinnerModule, MatTooltipModule, MatDialogModule
  ],
  template: `
    <div class="page-header">
      <h2 style="margin:0;font-size:1.4rem;font-weight:700">Tenants Management</h2>
      <mat-form-field appearance="outline" style="width:280px">
        <mat-label>Search tenants...</mat-label>
        <input matInput [(ngModel)]="search" (ngModelChange)="onSearch($event)" />
        <mat-icon matSuffix>search</mat-icon>
      </mat-form-field>
    </div>

    @if (loading()) {
      <div style="text-align:center;padding:40px"><mat-spinner diameter="36"></mat-spinner></div>
    } @else {
      <mat-card>
        <mat-table [dataSource]="tenants()">

          <ng-container matColumnDef="name">
            <mat-header-cell *matHeaderCellDef>Name</mat-header-cell>
            <mat-cell *matCellDef="let t">
              <div>
                <strong>{{ t.name }}</strong>
                <div style="font-size:11px;color:#666">{{ t.email }}</div>
              </div>
            </mat-cell>
          </ng-container>

          <ng-container matColumnDef="plan">
            <mat-header-cell *matHeaderCellDef>Plan</mat-header-cell>
            <mat-cell *matCellDef="let t">
              <span class="chip chip-blue">{{ t.plan }}</span>
            </mat-cell>
          </ng-container>

          <ng-container matColumnDef="stats">
            <mat-header-cell *matHeaderCellDef>Resources</mat-header-cell>
            <mat-cell *matCellDef="let t">
              <span class="badge">{{ t.userCount }} users</span>
              <span class="badge ml">{{ t.apartmentCount }} apts</span>
              <span class="badge ml">{{ t.activeRenterCount }} renters</span>
            </mat-cell>
          </ng-container>

          <ng-container matColumnDef="status">
            <mat-header-cell *matHeaderCellDef>Status</mat-header-cell>
            <mat-cell *matCellDef="let t">
              <span class="chip" [class.chip-green]="t.isActive" [class.chip-red]="!t.isActive">
                {{ t.isActive ? 'Active' : 'Inactive' }}
              </span>
            </mat-cell>
          </ng-container>

          <ng-container matColumnDef="created">
            <mat-header-cell *matHeaderCellDef>Created</mat-header-cell>
            <mat-cell *matCellDef="let t">{{ t.createdAt | date:'mediumDate' }}</mat-cell>
          </ng-container>

          <ng-container matColumnDef="actions">
            <mat-header-cell *matHeaderCellDef>Actions</mat-header-cell>
            <mat-cell *matCellDef="let t">
              <button mat-icon-button [matTooltip]="'View details'" (click)="viewDetail(t)">
                <mat-icon>visibility</mat-icon>
              </button>
              <button mat-icon-button
                [matTooltip]="t.isActive ? 'Deactivate' : 'Activate'"
                [color]="t.isActive ? 'warn' : 'primary'"
                (click)="toggleStatus(t)">
                <mat-icon>{{ t.isActive ? 'block' : 'check_circle' }}</mat-icon>
              </button>
            </mat-cell>
          </ng-container>

          <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
          <mat-row *matRowDef="let row; columns: cols"></mat-row>
        </mat-table>

        @if (!tenants().length) {
          <div style="text-align:center;padding:40px;color:#888">No tenants found.</div>
        }
      </mat-card>
    }
  `,
  styles: [`
    .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
    .chip { padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600; }
    .chip-green { background:#e8f5e9; color:#2e7d32; }
    .chip-red { background:#ffebee; color:#c62828; }
    .chip-blue { background:#e3f2fd; color:#1565c0; }
    .badge { background:#f0f0f0; color:#555; padding:2px 8px; border-radius:12px; font-size:11px; }
    .ml { margin-left:4px; }
  `]
})
export class TenantsComponent implements OnInit {
  private api = inject(ApiService);
  private dialog = inject(MatDialog);

  tenants = signal<AdminTenantListItem[]>([]);
  loading = signal(true);
  search = '';
  cols = ['name', 'plan', 'stats', 'status', 'created', 'actions'];

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
      data: t.id, width: '700px', maxHeight: '90vh'
    });
    ref.afterClosed().subscribe(() => this.load(this.search));
  }

  toggleStatus(t: AdminTenantListItem) {
    this.api.put(`/admin/tenants/${t.id}/status`, { isActive: !t.isActive }).subscribe(() =>
      this.load(this.search)
    );
  }
}
