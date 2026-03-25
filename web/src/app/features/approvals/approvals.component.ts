import { Component, OnInit, signal, inject } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { ApprovalRequest } from '../../core/models';

@Component({
  selector: 'app-approvals',
  standalone: true,
  imports: [MatTableModule, MatChipsModule, MatButtonModule, MatIconModule, MatCardModule, MatSnackBarModule, MatTooltipModule, CommonModule, DatePipe],
  template: `
    <div class="page-header">
      <h2 style="margin:0">Approvals</h2>
      <button mat-stroked-button (click)="showAll = !showAll; load()">
        {{ showAll ? 'Show Pending' : 'Show All' }}
      </button>
    </div>
    <mat-card>
      <mat-table [dataSource]="requests()">
        <ng-container matColumnDef="submitted">
          <mat-header-cell *matHeaderCellDef>Submitted By</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.submittedByName }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="type">
          <mat-header-cell *matHeaderCellDef>Type</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.entityType }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="action">
          <mat-header-cell *matHeaderCellDef>Action</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.action }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="status">
          <mat-header-cell *matHeaderCellDef>Status</mat-header-cell>
          <mat-cell *matCellDef="let r">
            <mat-chip [color]="r.status === 'Approved' ? 'primary' : r.status === 'Rejected' ? 'warn' : 'accent'" highlighted>
              {{ r.status }}
            </mat-chip>
          </mat-cell>
        </ng-container>
        <ng-container matColumnDef="date">
          <mat-header-cell *matHeaderCellDef>Date</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.createdAt | date:'short' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="actions">
          <mat-header-cell *matHeaderCellDef style="width:110px"></mat-header-cell>
          <mat-cell *matCellDef="let r">
            @if (r.status === 'Pending') {
              <button mat-icon-button color="primary" matTooltip="Approve" (click)="approve(r.id)">
                <mat-icon>check_circle</mat-icon>
              </button>
              <button mat-icon-button color="warn" matTooltip="Reject" (click)="reject(r.id)">
                <mat-icon>cancel</mat-icon>
              </button>
            }
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
        <mat-row *matRowDef="let row; columns: cols"></mat-row>
      </mat-table>
      @if (!requests().length) {
        <p style="text-align:center;padding:24px;color:#888">No pending approvals.</p>
      }
    </mat-card>
  `
})
export class ApprovalsComponent implements OnInit {
  private api = inject(ApiService);
  private snack = inject(MatSnackBar);
  requests = signal<ApprovalRequest[]>([]);
  cols = ['submitted', 'type', 'action', 'status', 'date', 'actions'];
  showAll = false;

  ngOnInit() { this.load(); }

  load() {
    const path = this.showAll ? '/approvals/all' : '/approvals';
    this.api.get<ApprovalRequest[]>(path).subscribe(d => this.requests.set(d));
  }

  approve(id: string) {
    this.api.put(`/approvals/${id}/approve`, {}).subscribe({
      next: () => { this.snack.open('Approved', '', { duration: 2000 }); this.load(); },
      error: e => this.snack.open(e.error?.message || 'Error', 'Close', { duration: 3000 })
    });
  }

  reject(id: string) {
    this.api.put(`/approvals/${id}/reject`, {}).subscribe({
      next: () => { this.snack.open('Rejected', '', { duration: 2000 }); this.load(); },
      error: e => this.snack.open(e.error?.message || 'Error', 'Close', { duration: 3000 })
    });
  }
}
