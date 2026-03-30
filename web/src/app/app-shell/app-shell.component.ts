import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../core/services/auth.service';
import { NotificationService } from '../core/services/notification.service';
import { ApiService } from '../core/services/api.service';
import { LanguageService } from '../core/services/language.service';
import { ToastService } from '../core/services/toast.service';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, CommonModule],
  template: `
    <div [dir]="dir()" class="app-root">

      <!-- ───────────────── SIDEBAR ───────────────────────────── -->
      <aside class="sidebar">

        <div class="sidebar-logo">
          <div class="logo-icon"><span class="material-icons">home_work</span></div>
          <span class="logo-text">Ijari</span>
        </div>

        <nav class="sidebar-nav">
          <p class="sidebar-section-label">{{ lang.t('navigation') }}</p>

          <a class="nav-item" routerLink="/dashboard" routerLinkActive="active-link">
            <span class="material-icons">dashboard</span>
            <span class="nav-label">{{ lang.t('dashboard') }}</span>
          </a>
          <a class="nav-item" routerLink="/apartments" routerLinkActive="active-link">
            <span class="material-icons">apartment</span>
            <span class="nav-label">{{ lang.t('apartments') }}</span>
          </a>
          <a class="nav-item" routerLink="/renters" routerLinkActive="active-link">
            <span class="material-icons">people</span>
            <span class="nav-label">{{ lang.t('renters') }}</span>
          </a>
          <a class="nav-item" routerLink="/contracts" routerLinkActive="active-link">
            <span class="material-icons">description</span>
            <span class="nav-label">{{ lang.t('contracts') }}</span>
          </a>
          <a class="nav-item" routerLink="/payments" routerLinkActive="active-link">
            <span class="material-icons">payments</span>
            <span class="nav-label">{{ lang.t('payments') }}</span>
          </a>
          <a class="nav-item" routerLink="/expenses" routerLinkActive="active-link">
            <span class="material-icons">receipt</span>
            <span class="nav-label">{{ lang.t('expenses') }}</span>
          </a>
          <a class="nav-item" routerLink="/deposits" routerLinkActive="active-link">
            <span class="material-icons">savings</span>
            <span class="nav-label">{{ lang.t('deposits') }}</span>
          </a>

          @if (isOwner()) {
            <div class="nav-divider"></div>
            <p class="sidebar-section-label">{{ lang.t('management') }}</p>

            <a class="nav-item" routerLink="/approvals" routerLinkActive="active-link">
              <span class="material-icons">approval</span>
              <span class="nav-label">{{ lang.t('approvals') }}</span>
              @if (pendingCount() > 0) {
                <span class="nav-badge">{{ pendingCount() }}</span>
              }
            </a>
            <a class="nav-item" routerLink="/employees" routerLinkActive="active-link">
              <span class="material-icons">badge</span>
              <span class="nav-label">{{ lang.t('employees') }}</span>
            </a>
            <a class="nav-item" routerLink="/reports" routerLinkActive="active-link">
              <span class="material-icons">bar_chart</span>
              <span class="nav-label">{{ lang.t('reports') }}</span>
            </a>
          }
        </nav>

        <div class="sidebar-footer">
          <div class="sidebar-avatar">
            {{ (user()?.name ?? 'U').charAt(0).toUpperCase() }}
          </div>
          <div class="sidebar-user-info">
            <div class="user-name">{{ user()?.name }}</div>
            <div class="user-role">{{ isOwner() ? lang.t('owner') : lang.t('employee') }}</div>
          </div>
          <button class="btn-icon" (click)="logout()" [title]="lang.t('logout')">
            <span class="material-icons">logout</span>
          </button>
        </div>

      </aside>

      <!-- ───────────────── MAIN AREA ─────────────────────────── -->
      <div class="main-area">

        <!-- Topbar -->
        <header class="topbar">
          <span class="topbar-spacer"></span>

          <button class="lang-toggle" (click)="lang.toggleLang()">
            <span class="material-icons">translate</span>
            {{ lang.lang() === 'en' ? 'AR' : 'EN' }}
          </button>

          <div class="notif-wrap">
            <button class="btn-icon" (click)="notifOpen = !notifOpen" [title]="lang.t('notifications')">
              <span class="material-icons">notifications_none</span>
              @if (notifCount() > 0) {
                <span class="notif-badge">{{ notifCount() }}</span>
              }
            </button>
            @if (notifOpen) {
              <div class="dropdown-backdrop" (click)="notifOpen = false"></div>
              <div class="dropdown-panel">
                @for (n of notifications(); track n.id) {
                  <button class="dropdown-item" [class.unread]="!n.isRead" (click)="markRead(n.id)">
                    <span class="material-icons">{{ n.isRead ? 'done' : 'circle' }}</span>
                    {{ n.title }}
                  </button>
                }
                @if (!notifications().length) {
                  <div class="dropdown-item" style="cursor:default;opacity:0.6">
                    {{ lang.t('noNotifications') }}
                  </div>
                }
              </div>
            }
          </div>
        </header>

        <!-- Page content -->
        <div class="main-content">
          <router-outlet />
        </div>

        <!-- Toasts -->
        <div class="toast-container">
          @for (t of toast.toasts(); track t.id) {
            <div class="toast" [class.toast-error]="t.type === 'error'" [class.toast-success]="t.type === 'success'">
              {{ t.message }}
            </div>
          }
        </div>

      </div>
    </div>
  `
})
export class AppShellComponent implements OnInit {
  private auth = inject(AuthService);
  private notifService = inject(NotificationService);
  private api = inject(ApiService);
  lang = inject(LanguageService);
  toast = inject(ToastService);

  dir = computed(() => this.lang.lang() === 'ar' ? 'rtl' : 'ltr');
  user = this.auth.currentUser;
  isOwner = computed(() => this.auth.isOwner);
  notifications = this.notifService.notifications;
  notifCount = this.notifService.unreadCount;
  pendingCount = signal(0);
  notifOpen = false;

  ngOnInit() {
    this.notifService.load();
    if (this.isOwner()) {
      this.api.get<any>('/dashboard').subscribe(stats => {
        this.pendingCount.set(stats.pendingApprovals ?? 0);
      });
    }
  }

  markRead(id: string) {
    this.notifService.markRead(id).subscribe(() => { this.notifService.load(); this.notifOpen = false; });
  }

  logout() { this.auth.logout(); }
}
