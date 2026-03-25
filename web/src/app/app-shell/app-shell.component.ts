import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../core/services/auth.service';
import { NotificationService } from '../core/services/notification.service';
import { ApiService } from '../core/services/api.service';
import { ToastContainerComponent } from '../shared/toast-container.component';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [
    RouterOutlet, RouterLink, RouterLinkActive,
    CommonModule, ToastContainerComponent
  ],
  template: `
    <div class="shell-layout">
      <!-- Sidebar -->
      <aside class="sidebar">
        <div class="sidebar-logo">
          <svg width="32" height="32" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M20 3L38 18V38H26V27H14V38H2V18L20 3Z" fill="#2563EB"/>
            <path d="M20 3L38 18H2L20 3Z" fill="#3B82F6"/>
            <circle cx="20" cy="28" r="3.5" fill="#0D1B2A" stroke="#F1F5F9" stroke-width="1.5"/>
            <rect x="19" y="30.5" width="2" height="5" rx="1" fill="#F1F5F9"/>
            <rect x="21" y="33.5" width="2.5" height="1.5" rx="0.75" fill="#F1F5F9"/>
          </svg>
          <div>
            <div class="sidebar-logo-text">Ijari</div>
            <div class="sidebar-logo-sub">Rent Management</div>
          </div>
        </div>

        <nav class="sidebar-nav">
          <a class="nav-link" routerLink="/dashboard" routerLinkActive="active">
            <span class="material-icons">dashboard</span>
            Dashboard
          </a>
          <a class="nav-link" routerLink="/apartments" routerLinkActive="active">
            <span class="material-icons">apartment</span>
            Apartments
          </a>
          <a class="nav-link" routerLink="/renters" routerLinkActive="active">
            <span class="material-icons">people</span>
            Renters
          </a>
          <a class="nav-link" routerLink="/payments" routerLinkActive="active">
            <span class="material-icons">payments</span>
            Payments
          </a>
          <a class="nav-link" routerLink="/expenses" routerLinkActive="active">
            <span class="material-icons">receipt</span>
            Expenses
          </a>
          <a class="nav-link" routerLink="/deposits" routerLinkActive="active">
            <span class="material-icons">savings</span>
            Deposits
          </a>

          @if (isOwner()) {
            <div class="nav-divider"></div>
            <div class="nav-section-label">Owner</div>
            <a class="nav-link" routerLink="/approvals" routerLinkActive="active">
              <span class="material-icons">approval</span>
              Approvals
              @if (pendingCount() > 0) {
                <span class="badge badge-danger" style="margin-left:auto;padding:1px 7px;font-size:10px">
                  {{ pendingCount() }}
                </span>
              }
            </a>
            <a class="nav-link" routerLink="/employees" routerLinkActive="active">
              <span class="material-icons">badge</span>
              Employees
            </a>
            <a class="nav-link" routerLink="/reports" routerLinkActive="active">
              <span class="material-icons">bar_chart</span>
              Reports
            </a>
          }
        </nav>

        <div class="sidebar-footer">
          <button class="nav-link" (click)="logout()">
            <span class="material-icons">logout</span>
            Logout
          </button>
        </div>
      </aside>

      <!-- Main Area -->
      <div class="shell-main">
        <!-- Topbar -->
        <header class="topbar">
          <span class="topbar-spacer"></span>

          <!-- Notifications -->
          <div class="dropdown">
            <button class="btn-icon notif-btn" (click)="notifsOpen.set(!notifsOpen())">
              <span class="material-icons">notifications</span>
              @if (notifCount() > 0) {
                <span class="notif-dot"></span>
              }
            </button>
            @if (notifsOpen()) {
              <div class="dropdown-menu" style="width:260px">
                @for (n of notifications(); track n.id) {
                  <button class="dropdown-item" (click)="markRead(n.id)"
                    [style.font-weight]="n.isRead ? '400' : '600'">
                    <span class="material-icons" style="font-size:15px">circle</span>
                    {{ n.title }}
                  </button>
                }
                @if (!notifications().length) {
                  <div style="padding:12px 16px;font-size:12px;color:var(--text-secondary)">No notifications</div>
                }
              </div>
            }
          </div>

          <!-- User Menu -->
          <div class="dropdown">
            <button class="btn btn-ghost btn-sm" (click)="userMenuOpen.set(!userMenuOpen())">
              <span class="material-icons" style="font-size:18px">account_circle</span>
              {{ user()?.name }}
              <span class="material-icons" style="font-size:14px">expand_more</span>
            </button>
            @if (userMenuOpen()) {
              <div class="dropdown-menu">
                <button class="dropdown-item" (click)="logout()">
                  <span class="material-icons">logout</span>
                  Logout
                </button>
              </div>
            }
          </div>
        </header>

        <!-- Page Content -->
        <main class="page-content">
          <router-outlet />
        </main>
      </div>
    </div>

    <app-toast-container />
  `
})
export class AppShellComponent implements OnInit {
  private auth = inject(AuthService);
  private notifService = inject(NotificationService);
  private api = inject(ApiService);

  user = this.auth.currentUser;
  isOwner = computed(() => this.auth.currentUser()?.role === 'Owner');
  notifications = this.notifService.notifications;
  notifCount = this.notifService.unreadCount;
  pendingCount = signal(0);

  notifsOpen = signal(false);
  userMenuOpen = signal(false);

  ngOnInit() {
    this.notifService.load();
    if (this.isOwner()) {
      this.api.get<any>('/dashboard').subscribe(stats => {
        this.pendingCount.set(stats.pendingApprovals ?? 0);
      });
    }
  }

  markRead(id: string) {
    this.notifService.markRead(id).subscribe(() => this.notifService.load());
    this.notifsOpen.set(false);
  }

  logout() { this.auth.logout(); }
}
