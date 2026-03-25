import { Component, OnInit, signal, inject } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { RentPayment } from '../../core/models';

@Component({
  selector: 'app-payments',
  standalone: true,
  imports: [MatTableModule, MatChipsModule, MatButtonModule, MatIconModule, MatCardModule, MatSnackBarModule, CommonModule],
  template: `
    <div class="page-header">
      <h2 style="margin:0">Rent Payments</h2>
      @if (isOwner()) {
        <button mat-flat-button color="accent" (click)="generateMonth()">
          <mat-icon>auto_awesome</mat-icon> Generate This Month
        </button>
      }
    </div>
    <mat-card>
      <mat-table [dataSource]="payments()">
        <ng-container matColumnDef="apartment">
          <mat-header-cell *matHeaderCellDef>Apartment</mat-header-cell>
          <mat-cell *matCellDef="let p">{{ p.apartmentName }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="renter">
          <mat-header-cell *matHeaderCellDef>Renter</mat-header-cell>
          <mat-cell *matCellDef="let p">{{ p.renterName || '—' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="period">
          <mat-header-cell *matHeaderCellDef>Period</mat-header-cell>
          <mat-cell *matCellDef="let p">{{ p.paymentMonth }}/{{ p.paymentYear }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="rent">
          <mat-header-cell *matHeaderCellDef>Rent</mat-header-cell>
          <mat-cell *matCellDef="let p">{{ p.rentAmount | number:'1.0-0' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="paid">
          <mat-header-cell *matHeaderCellDef>Paid</mat-header-cell>
          <mat-cell *matCellDef="let p">{{ p.amountPaid | number:'1.0-0' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="outstanding">
          <mat-header-cell *matHeaderCellDef>Outstanding</mat-header-cell>
          <mat-cell *matCellDef="let p" [style.color]="p.outstandingAfter > 0 ? '#f44336' : 'inherit'">
            {{ p.outstandingAfter | number:'1.0-0' }}
          </mat-cell>
        </ng-container>
        <ng-container matColumnDef="status">
          <mat-header-cell *matHeaderCellDef>Status</mat-header-cell>
          <mat-cell *matCellDef="let p">
            <mat-chip
              [color]="p.status === 'Approved' ? 'primary' : p.status === 'Rejected' ? 'warn' : 'accent'"
              highlighted>{{ p.status }}</mat-chip>
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
        <mat-row *matRowDef="let row; columns: cols"></mat-row>
      </mat-table>
      @if (!payments().length) {
        <p style="text-align:center;padding:24px;color:#888">No payments yet.</p>
      }
    </mat-card>
  `
})
export class PaymentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private snack = inject(MatSnackBar);

  payments = signal<RentPayment[]>([]);
  isOwner = signal(this.auth.isOwner);
  cols = ['apartment', 'renter', 'period', 'rent', 'paid', 'outstanding', 'status'];

  ngOnInit() { this.load(); }
  load() { this.api.get<RentPayment[]>('/payments').subscribe(data => this.payments.set(data)); }

  generateMonth() {
    const now = new Date();
    this.api.post<RentPayment[]>('/payments/generate-month', { month: now.getMonth() + 1, year: now.getFullYear() }).subscribe({
      next: (created) => { this.snack.open(`Generated ${created.length} records`, '', { duration: 3000 }); this.load(); },
      error: e => this.snack.open(e.error?.message || 'Error', 'Close', { duration: 3000 })
    });
  }
}
