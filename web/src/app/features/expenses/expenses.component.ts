import { Component, OnInit, signal, inject } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatCardModule } from '@angular/material/card';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { Expense } from '../../core/models';

@Component({
  selector: 'app-expenses',
  standalone: true,
  imports: [MatTableModule, MatChipsModule, MatCardModule, CommonModule, DatePipe],
  template: `
    <div class="page-header"><h2 style="margin:0">Expenses</h2></div>
    <mat-card>
      <mat-table [dataSource]="expenses()">
        <ng-container matColumnDef="description">
          <mat-header-cell *matHeaderCellDef>Description</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.description }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="category">
          <mat-header-cell *matHeaderCellDef>Category</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.category || '—' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="amount">
          <mat-header-cell *matHeaderCellDef>Amount</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.amount | number:'1.0-0' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="period">
          <mat-header-cell *matHeaderCellDef>Period</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.month }}/{{ e.year }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="status">
          <mat-header-cell *matHeaderCellDef>Status</mat-header-cell>
          <mat-cell *matCellDef="let e">
            <mat-chip [color]="e.status === 'Approved' ? 'primary' : e.status === 'Rejected' ? 'warn' : 'accent'" highlighted>{{ e.status }}</mat-chip>
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
        <mat-row *matRowDef="let row; columns: cols"></mat-row>
      </mat-table>
      @if (!expenses().length) {
        <p style="text-align:center;padding:24px;color:#888">No expenses yet.</p>
      }
    </mat-card>
  `
})
export class ExpensesComponent implements OnInit {
  private api = inject(ApiService);
  expenses = signal<Expense[]>([]);
  cols = ['description', 'category', 'amount', 'period', 'status'];
  ngOnInit() { this.api.get<Expense[]>('/expenses').subscribe(d => this.expenses.set(d)); }
}
