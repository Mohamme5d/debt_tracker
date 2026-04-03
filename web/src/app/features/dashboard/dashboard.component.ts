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
    <h2 class="page-enter" style="margin:0 0 24px">{{ lang.t('dashboard') }}</h2>

    @if (stats()) {
      <div class="stats-grid page-enter" style="animation-delay:0.05s">
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
      <!-- Skeleton stat cards -->
      <div class="stats-grid page-enter">
        @for (s of skeletons; track s) {
          <div class="stat-card" style="cursor:default">
            <div class="skeleton" style="width:36px;height:36px;border-radius:50%;margin:0 auto 12px"></div>
            <div class="skeleton" style="width:60%;height:28px;margin:0 auto 8px;border-radius:6px"></div>
            <div class="skeleton" style="width:80%;height:11px;margin:0 auto;border-radius:4px"></div>
          </div>
        }
      </div>
    }
  `
})
export class DashboardComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);
  stats = signal<DashboardStats | null>(null);
  skeletons = [1, 2, 3, 4, 5, 6, 7];

  ngOnInit() {
    this.api.get<DashboardStats>('/dashboard').subscribe(s => this.stats.set(s));
  }
}
