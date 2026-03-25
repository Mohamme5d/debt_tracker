import { Component, inject } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-admin-shell',
  standalone: true,
  imports: [
    RouterOutlet, RouterLink, RouterLinkActive,
    MatSidenavModule, MatToolbarModule, MatListModule,
    MatIconModule, MatButtonModule
  ],
  template: `
    <mat-sidenav-container style="height:100vh">
      <mat-sidenav mode="side" opened style="width:230px;background:#1a1a2e">
        <div style="padding:16px 20px;background:#16213e;border-bottom:1px solid #0f3460">
          <div style="display:flex;align-items:center;gap:10px">
            <mat-icon style="color:#e94560;font-size:28px;width:28px;height:28px">admin_panel_settings</mat-icon>
            <div>
              <div style="color:#fff;font-weight:700;font-size:15px">Ijari Admin</div>
              <div style="color:#aaa;font-size:11px">Super Admin Panel</div>
            </div>
          </div>
        </div>

        <mat-nav-list style="padding-top:8px">
          <a mat-list-item routerLink="/admin/dashboard" routerLinkActive="admin-active">
            <mat-icon matListItemIcon style="color:#e94560">dashboard</mat-icon>
            <span matListItemTitle style="color:#ddd">Dashboard</span>
          </a>
          <a mat-list-item routerLink="/admin/tenants" routerLinkActive="admin-active">
            <mat-icon matListItemIcon style="color:#e94560">business</mat-icon>
            <span matListItemTitle style="color:#ddd">Tenants</span>
          </a>
          <a mat-list-item routerLink="/admin/users" routerLinkActive="admin-active">
            <mat-icon matListItemIcon style="color:#e94560">people</mat-icon>
            <span matListItemTitle style="color:#ddd">All Users</span>
          </a>
        </mat-nav-list>

        <div style="position:absolute;bottom:0;width:100%;padding:12px 0;border-top:1px solid #0f3460">
          <button mat-list-item style="width:100%;color:#aaa;text-align:left" (click)="logout()">
            <mat-icon style="margin-right:8px;vertical-align:middle">logout</mat-icon>
            Logout
          </button>
        </div>
      </mat-sidenav>

      <mat-sidenav-content style="background:#f5f5f5">
        <mat-toolbar style="background:#16213e;color:#fff;border-bottom:1px solid #0f3460">
          <span style="font-size:14px;color:#aaa">Super Admin</span>
          <span style="flex:1"></span>
          <span style="font-size:13px;color:#e94560">{{ user()?.email }}</span>
        </mat-toolbar>
        <div style="padding:24px">
          <router-outlet />
        </div>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: [`
    .admin-active { background: rgba(233,69,96,0.2) !important; }
    .admin-active span { color: #e94560 !important; }
    .admin-active mat-icon { color: #e94560 !important; }
  `]
})
export class AdminShellComponent {
  private auth = inject(AuthService);
  user = this.auth.currentUser;
  logout() { this.auth.logout(); }
}
