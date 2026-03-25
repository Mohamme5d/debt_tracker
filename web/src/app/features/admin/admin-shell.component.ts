import { Component, inject } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { ToastContainerComponent } from '../../shared/toast-container.component';

@Component({
  selector: 'app-admin-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, ToastContainerComponent],
  template: `
    <div class="shell-layout admin-theme">
      <!-- Admin Sidebar -->
      <aside class="sidebar">
        <div class="sidebar-logo">
          <span class="material-icons" style="color:var(--primary);font-size:28px">admin_panel_settings</span>
          <div>
            <div class="sidebar-logo-text">Ijari Admin</div>
            <div class="sidebar-logo-sub">Super Admin Panel</div>
          </div>
        </div>

        <nav class="sidebar-nav">
          <a class="nav-link" routerLink="/admin/dashboard" routerLinkActive="active">
            <span class="material-icons">dashboard</span>
            Dashboard
          </a>
          <a class="nav-link" routerLink="/admin/tenants" routerLinkActive="active">
            <span class="material-icons">business</span>
            Tenants
          </a>
          <a class="nav-link" routerLink="/admin/users" routerLinkActive="active">
            <span class="material-icons">people</span>
            All Users
          </a>
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
        <header class="topbar">
          <span class="topbar-section">Super Admin</span>
          <span class="topbar-spacer"></span>
          <span class="topbar-email">{{ user()?.email }}</span>
        </header>

        <main class="page-content">
          <router-outlet />
        </main>
      </div>
    </div>

    <app-toast-container />
  `
})
export class AdminShellComponent {
  private auth = inject(AuthService);
  user = this.auth.currentUser;
  logout() { this.auth.logout(); }
}
