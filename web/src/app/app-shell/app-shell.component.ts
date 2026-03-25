import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatBadgeModule } from '@angular/material/badge';
import { MatMenuModule } from '@angular/material/menu';
import { CommonModule } from '@angular/common';
import { AuthService } from '../core/services/auth.service';
import { NotificationService } from '../core/services/notification.service';
import { ApiService } from '../core/services/api.service';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [
    RouterOutlet, RouterLink, RouterLinkActive,
    MatSidenavModule, MatToolbarModule, MatListModule,
    MatIconModule, MatButtonModule, MatBadgeModule, MatMenuModule,
    CommonModule
  ],
  template: `
    <mat-sidenav-container style="height:100vh">
      <mat-sidenav mode="side" opened style="width:220px">
        <mat-toolbar color="primary" style="font-size:1.1rem;min-height:56px">
          <mat-icon style="margin-right:8px">home_work</mat-icon> Ijari
        </mat-toolbar>
        <mat-nav-list>
          <a mat-list-item routerLink="/dashboard" routerLinkActive="active-link">
            <mat-icon matListItemIcon>dashboard</mat-icon>
            <span matListItemTitle>Dashboard</span>
          </a>
          <a mat-list-item routerLink="/apartments" routerLinkActive="active-link">
            <mat-icon matListItemIcon>apartment</mat-icon>
            <span matListItemTitle>Apartments</span>
          </a>
          <a mat-list-item routerLink="/renters" routerLinkActive="active-link">
            <mat-icon matListItemIcon>people</mat-icon>
            <span matListItemTitle>Renters</span>
          </a>
          <a mat-list-item routerLink="/payments" routerLinkActive="active-link">
            <mat-icon matListItemIcon>payments</mat-icon>
            <span matListItemTitle>Payments</span>
          </a>
          <a mat-list-item routerLink="/expenses" routerLinkActive="active-link">
            <mat-icon matListItemIcon>receipt</mat-icon>
            <span matListItemTitle>Expenses</span>
          </a>
          <a mat-list-item routerLink="/deposits" routerLinkActive="active-link">
            <mat-icon matListItemIcon>savings</mat-icon>
            <span matListItemTitle>Deposits</span>
          </a>
          @if (isOwner()) {
            <mat-divider></mat-divider>
            <a mat-list-item routerLink="/approvals" routerLinkActive="active-link">
              <mat-icon matListItemIcon
                [matBadge]="pendingCount() > 0 ? pendingCount().toString() : null"
                matBadgeColor="warn" matBadgeSize="small">approval</mat-icon>
              <span matListItemTitle>Approvals</span>
            </a>
            <a mat-list-item routerLink="/employees" routerLinkActive="active-link">
              <mat-icon matListItemIcon>badge</mat-icon>
              <span matListItemTitle>Employees</span>
            </a>
            <a mat-list-item routerLink="/reports" routerLinkActive="active-link">
              <mat-icon matListItemIcon>bar_chart</mat-icon>
              <span matListItemTitle>Reports</span>
            </a>
          }
        </mat-nav-list>
      </mat-sidenav>

      <mat-sidenav-content>
        <mat-toolbar color="primary" style="position:sticky;top:0;z-index:100">
          <span style="flex:1"></span>
          <button mat-icon-button [matMenuTriggerFor]="notifMenu"
            [matBadge]="notifCount() > 0 ? notifCount().toString() : null"
            matBadgeColor="warn" matBadgeSize="small">
            <mat-icon>notifications</mat-icon>
          </button>
          <mat-menu #notifMenu="matMenu">
            @for (n of notifications(); track n.id) {
              <button mat-menu-item (click)="markRead(n.id)"
                [style.font-weight]="n.isRead ? 'normal' : '700'">
                <span>{{ n.title }}</span>
              </button>
            }
            @if (!notifications().length) {
              <button mat-menu-item disabled>No notifications</button>
            }
          </mat-menu>

          <button mat-button [matMenuTriggerFor]="userMenu">
            <mat-icon>account_circle</mat-icon>&nbsp;{{ user()?.name }}
          </button>
          <mat-menu #userMenu="matMenu">
            <button mat-menu-item (click)="logout()">
              <mat-icon>logout</mat-icon> Logout
            </button>
          </mat-menu>
        </mat-toolbar>

        <div style="padding:24px">
          <router-outlet />
        </div>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: [`
    .active-link { background: rgba(63,81,181,0.15) !important; }
  `]
})
export class AppShellComponent implements OnInit {
  private auth = inject(AuthService);
  private notifService = inject(NotificationService);
  private api = inject(ApiService);

  user = this.auth.currentUser;
  isOwner = computed(() => this.auth.isOwner);
  notifications = this.notifService.notifications;
  notifCount = this.notifService.unreadCount;
  pendingCount = signal(0);

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
  }

  logout() { this.auth.logout(); }
}
