import { Component, OnInit, signal, inject } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { Renter } from '../../core/models';

@Component({
  selector: 'app-renters',
  standalone: true,
  imports: [MatTableModule, MatChipsModule, MatButtonModule, MatIconModule, MatCardModule, MatSnackBarModule, MatTooltipModule, CommonModule],
  template: `
    <div class="page-header">
      <h2 style="margin:0">Renters</h2>
    </div>
    <mat-card>
      <mat-table [dataSource]="renters()">
        <ng-container matColumnDef="name">
          <mat-header-cell *matHeaderCellDef>Name</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.name }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="apartment">
          <mat-header-cell *matHeaderCellDef>Apartment</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.apartmentName }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="phone">
          <mat-header-cell *matHeaderCellDef>Phone</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.phone }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="rent">
          <mat-header-cell *matHeaderCellDef>Monthly Rent</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.monthlyRent | number:'1.0-0' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="active">
          <mat-header-cell *matHeaderCellDef>Active</mat-header-cell>
          <mat-cell *matCellDef="let r">{{ r.isActive ? 'Yes' : 'No' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="status">
          <mat-header-cell *matHeaderCellDef>Status</mat-header-cell>
          <mat-cell *matCellDef="let r">
            <mat-chip
              [color]="r.status === 'Approved' ? 'primary' : r.status === 'Rejected' ? 'warn' : 'accent'"
              highlighted>{{ r.status }}</mat-chip>
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
        <mat-row *matRowDef="let row; columns: cols"></mat-row>
      </mat-table>
      @if (!renters().length) {
        <p style="text-align:center;padding:24px;color:#888">No renters yet.</p>
      }
    </mat-card>
  `
})
export class RentersComponent implements OnInit {
  private api = inject(ApiService);
  renters = signal<Renter[]>([]);
  cols = ['name', 'apartment', 'phone', 'rent', 'active', 'status'];

  ngOnInit() {
    this.api.get<Renter[]>('/renters').subscribe(data => this.renters.set(data));
  }
}
