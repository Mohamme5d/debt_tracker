import { Component, signal, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatDividerModule } from '@angular/material/divider';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [ReactiveFormsModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatCardModule, MatTableModule, MatDividerModule, CommonModule],
  template: `
    <h2 style="margin:0 0 24px">Monthly Report</h2>
    <form [formGroup]="form" style="display:flex;gap:16px;align-items:center;flex-wrap:wrap;margin-bottom:24px">
      <mat-form-field appearance="outline" style="width:120px">
        <mat-label>Month</mat-label>
        <input matInput type="number" formControlName="month" min="1" max="12">
      </mat-form-field>
      <mat-form-field appearance="outline" style="width:120px">
        <mat-label>Year</mat-label>
        <input matInput type="number" formControlName="year" min="2000" max="2099">
      </mat-form-field>
      <button mat-flat-button color="primary" (click)="load()">Load Report</button>
      @if (isOwner()) {
        <button mat-stroked-button color="accent" (click)="loadCommission()">Commission</button>
      }
    </form>

    @if (report()) {
      <div class="stats-grid">
        <mat-card class="stat-card"><mat-card-content>
          <div class="stat-value">{{ report().totalRentCollected | number:'1.0-0' }}</div>
          <div class="stat-label">Rent Collected</div>
        </mat-card-content></mat-card>
        <mat-card class="stat-card"><mat-card-content>
          <div class="stat-value" style="color:#f44336">{{ report().totalOutstanding | number:'1.0-0' }}</div>
          <div class="stat-label">Outstanding</div>
        </mat-card-content></mat-card>
        <mat-card class="stat-card"><mat-card-content>
          <div class="stat-value">{{ report().totalExpenses | number:'1.0-0' }}</div>
          <div class="stat-label">Expenses</div>
        </mat-card-content></mat-card>
        <mat-card class="stat-card"><mat-card-content>
          <div class="stat-value">{{ report().totalDeposit | number:'1.0-0' }}</div>
          <div class="stat-label">Deposit</div>
        </mat-card-content></mat-card>
        <mat-card class="stat-card"><mat-card-content>
          <div class="stat-value" [style.color]="report().netBalance < 0 ? '#f44336' : '#4caf50'">{{ report().netBalance | number:'1.0-0' }}</div>
          <div class="stat-label">Net Balance</div>
        </mat-card-content></mat-card>
      </div>

      <h3>Payments</h3>
      <mat-card>
        <mat-table [dataSource]="report().payments">
          <ng-container matColumnDef="apt"><mat-header-cell *matHeaderCellDef>Apartment</mat-header-cell><mat-cell *matCellDef="let p">{{ p.apartmentName }}</mat-cell></ng-container>
          <ng-container matColumnDef="renter"><mat-header-cell *matHeaderCellDef>Renter</mat-header-cell><mat-cell *matCellDef="let p">{{ p.renterName || '—' }}</mat-cell></ng-container>
          <ng-container matColumnDef="paid"><mat-header-cell *matHeaderCellDef>Paid</mat-header-cell><mat-cell *matCellDef="let p">{{ p.amountPaid | number:'1.0-0' }}</mat-cell></ng-container>
          <ng-container matColumnDef="out"><mat-header-cell *matHeaderCellDef>Outstanding</mat-header-cell><mat-cell *matCellDef="let p">{{ p.outstanding | number:'1.0-0' }}</mat-cell></ng-container>
          <mat-header-row *matHeaderRowDef="['apt','renter','paid','out']"></mat-header-row>
          <mat-row *matRowDef="let row; columns: ['apt','renter','paid','out']"></mat-row>
        </mat-table>
      </mat-card>
    }

    @if (commission()) {
      <mat-card style="margin-top:24px;padding:16px">
        <h3 style="margin:0 0 16px">Commission — {{ commission().month }}/{{ commission().year }}</h3>
        <p>Total Collected: <strong>{{ commission().totalRentCollected | number:'1.0-0' }}</strong></p>
        <p>Rate: <strong>{{ commission().commissionRate }}%</strong></p>
        <p>Commission Due: <strong>{{ commission().commissionAmount | number:'1.0-2' }}</strong></p>
      </mat-card>
    }
  `
})
export class ReportsComponent {
  private api = inject(ApiService);
  private fb = inject(FormBuilder);
  report = signal<any>(null);
  commission = signal<any>(null);
  isOwner = signal(true);

  form = this.fb.group({
    month: [new Date().getMonth() + 1],
    year: [new Date().getFullYear()]
  });

  load() {
    const { month, year } = this.form.value;
    this.api.get<any>('/reports/monthly', { month: month!, year: year! }).subscribe(d => this.report.set(d));
  }

  loadCommission() {
    const { month, year } = this.form.value;
    this.api.get<any>('/reports/commission', { month: month!, year: year!, rate: 10 }).subscribe(d => this.commission.set(d));
  }
}
