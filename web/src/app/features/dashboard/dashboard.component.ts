import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';
import { DashboardStats } from '../../core/models';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h2 style="margin:0 0 24px">{{ lang.t('dashboard') }}</h2>
    @if (stats()) {
      <div class="stats-grid">
        <div class="stat-card">
          <span class="material-icons">apartment</span>
          <div class="stat-value">{{ stats()!.totalApartments }}</div>
          <div class="stat-label">{{ lang.t('totalApartments') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons">people</span>
          <div class="stat-value">{{ stats()!.activeRenters }}</div>
          <div class="stat-label">{{ lang.t('activeRenters') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons">payments</span>
          <div class="stat-value">{{ stats()!.totalCollectedThisMonth | number:'1.0-0' }}</div>
          <div class="stat-label">{{ lang.t('collectedThisMonth') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons" style="color:var(--warn)">warning</span>
          <div class="stat-value" style="color:var(--warn)">{{ stats()!.totalOutstanding | number:'1.0-0' }}</div>
          <div class="stat-label">{{ lang.t('totalOutstanding') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons" style="color:var(--accent)">receipt</span>
          <div class="stat-value">{{ stats()!.totalExpensesThisMonth | number:'1.0-0' }}</div>
          <div class="stat-label">{{ lang.t('expensesThisMonth') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons" style="color:var(--warn)">approval</span>
          <div class="stat-value" [style.color]="stats()!.pendingApprovals > 0 ? 'var(--warn)' : ''">
            {{ stats()!.pendingApprovals }}
          </div>
          <div class="stat-label">{{ lang.t('pendingApprovalsCount') }}</div>
        </div>
        <div class="stat-card">
          <span class="material-icons">notifications</span>
          <div class="stat-value">{{ stats()!.unreadNotifications }}</div>
          <div class="stat-label">{{ lang.t('unreadNotifications') }}</div>
        </div>
      </div>
    } @else {
      <p style="opacity:0.6">{{ lang.t('loading') }}</p>
    }
  `
})
export class DashboardComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);
  stats = signal<DashboardStats | null>(null);

  ngOnInit() {
    this.api.get<DashboardStats>('/dashboard').subscribe(s => this.stats.set(s));
  }
}
