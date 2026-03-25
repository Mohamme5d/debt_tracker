import { Component, OnInit, signal, inject } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { DashboardStats } from '../../core/models';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [MatCardModule, MatIconModule, CommonModule],
  template: `
    <h2 style="margin:0 0 24px">Dashboard</h2>
    @if (stats()) {
      <div class="stats-grid">
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon color="primary" style="font-size:36px;height:36px;width:36px">apartment</mat-icon>
            <div class="stat-value">{{ stats()!.totalApartments }}</div>
            <div class="stat-label">Apartments</div>
          </mat-card-content>
        </mat-card>
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon color="primary" style="font-size:36px;height:36px;width:36px">people</mat-icon>
            <div class="stat-value">{{ stats()!.activeRenters }}</div>
            <div class="stat-label">Active Renters</div>
          </mat-card-content>
        </mat-card>
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon color="primary" style="font-size:36px;height:36px;width:36px">payments</mat-icon>
            <div class="stat-value">{{ stats()!.totalCollectedThisMonth | number:'1.0-0' }}</div>
            <div class="stat-label">Collected This Month</div>
          </mat-card-content>
        </mat-card>
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon color="warn" style="font-size:36px;height:36px;width:36px">warning</mat-icon>
            <div class="stat-value" style="color:#f44336">{{ stats()!.totalOutstanding | number:'1.0-0' }}</div>
            <div class="stat-label">Total Outstanding</div>
          </mat-card-content>
        </mat-card>
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon color="accent" style="font-size:36px;height:36px;width:36px">receipt</mat-icon>
            <div class="stat-value">{{ stats()!.totalExpensesThisMonth | number:'1.0-0' }}</div>
            <div class="stat-label">Expenses This Month</div>
          </mat-card-content>
        </mat-card>
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon color="warn" style="font-size:36px;height:36px;width:36px">approval</mat-icon>
            <div class="stat-value" [style.color]="stats()!.pendingApprovals > 0 ? '#ff9800' : '#3f51b5'">
              {{ stats()!.pendingApprovals }}
            </div>
            <div class="stat-label">Pending Approvals</div>
          </mat-card-content>
        </mat-card>
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon style="font-size:36px;height:36px;width:36px">notifications</mat-icon>
            <div class="stat-value">{{ stats()!.unreadNotifications }}</div>
            <div class="stat-label">Unread Notifications</div>
          </mat-card-content>
        </mat-card>
      </div>
    } @else {
      <p>Loading...</p>
    }
  `
})
export class DashboardComponent implements OnInit {
  private api = inject(ApiService);
  stats = signal<DashboardStats | null>(null);

  ngOnInit() {
    this.api.get<DashboardStats>('/dashboard').subscribe(s => this.stats.set(s));
  }
}
