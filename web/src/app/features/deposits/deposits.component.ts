import { Component, OnInit, signal, inject } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatCardModule } from '@angular/material/card';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { MonthlyDeposit } from '../../core/models';

@Component({
  selector: 'app-deposits',
  standalone: true,
  imports: [MatTableModule, MatChipsModule, MatCardModule, CommonModule],
  template: `
    <div class="page-header"><h2 style="margin:0">Monthly Deposits</h2></div>
    <mat-card>
      <mat-table [dataSource]="deposits()">
        <ng-container matColumnDef="period">
          <mat-header-cell *matHeaderCellDef>Period</mat-header-cell>
          <mat-cell *matCellDef="let d">{{ d.depositMonth }}/{{ d.depositYear }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="amount">
          <mat-header-cell *matHeaderCellDef>Amount</mat-header-cell>
          <mat-cell *matCellDef="let d">{{ d.amount | number:'1.0-0' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="notes">
          <mat-header-cell *matHeaderCellDef>Notes</mat-header-cell>
          <mat-cell *matCellDef="let d">{{ d.notes }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="status">
          <mat-header-cell *matHeaderCellDef>Status</mat-header-cell>
          <mat-cell *matCellDef="let d">
            <mat-chip [color]="d.status === 'Approved' ? 'primary' : d.status === 'Rejected' ? 'warn' : 'accent'" highlighted>{{ d.status }}</mat-chip>
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
        <mat-row *matRowDef="let row; columns: cols"></mat-row>
      </mat-table>
      @if (!deposits().length) {
        <p style="text-align:center;padding:24px;color:#888">No deposits yet.</p>
      }
    </mat-card>
  `
})
export class DepositsComponent implements OnInit {
  private api = inject(ApiService);
  deposits = signal<MonthlyDeposit[]>([]);
  cols = ['period', 'amount', 'notes', 'status'];
  ngOnInit() { this.api.get<MonthlyDeposit[]>('/deposits').subscribe(d => this.deposits.set(d)); }
}
