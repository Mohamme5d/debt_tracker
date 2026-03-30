import { Component, inject } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-admin-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <div style="display:flex;height:100vh;background:#0d1117;color:#e6edf3;font-family:'Cairo',sans-serif">

      <!-- Sidebar -->
      <aside style="width:220px;background:#161b22;border-right:1px solid #30363d;display:flex;flex-direction:column;flex-shrink:0">
        <div style="padding:18px 20px;border-bottom:1px solid #30363d">
          <div style="display:flex;align-items:center;gap:10px">
            <span class="material-icons" style="color:#e94560;font-size:26px">admin_panel_settings</span>
            <div>
              <div style="color:#e6edf3;font-weight:700;font-size:15px">Ijari Admin</div>
              <div style="color:#8b949e;font-size:11px">Super Admin</div>
            </div>
          </div>
        </div>

        <nav style="padding:10px 8px;flex:1">
          <a class="admin-nav-item" routerLink="/admin/dashboard" routerLinkActive="admin-active">
            <span class="material-icons">dashboard</span> Dashboard
          </a>
          <a class="admin-nav-item" routerLink="/admin/tenants" routerLinkActive="admin-active">
            <span class="material-icons">business</span> Tenants
          </a>
          <a class="admin-nav-item" routerLink="/admin/users" routerLinkActive="admin-active">
            <span class="material-icons">people</span> All Users
          </a>
        </nav>

        <div style="padding:12px;border-top:1px solid #30363d">
          <button class="admin-nav-item" style="width:100%;background:transparent;border:none;cursor:pointer;color:#8b949e;text-align:start" (click)="logout()">
            <span class="material-icons">logout</span> Logout
          </button>
        </div>
      </aside>

      <!-- Main -->
      <div style="flex:1;display:flex;flex-direction:column;overflow:hidden">
        <header style="height:52px;background:#161b22;border-bottom:1px solid #30363d;display:flex;align-items:center;padding:0 24px;flex-shrink:0">
          <span style="font-size:13px;color:#8b949e">Super Admin</span>
          <span style="flex:1"></span>
          <span style="font-size:13px;color:#e94560">{{ user()?.email }}</span>
        </header>
        <div style="flex:1;overflow-y:auto;padding:24px">
          <router-outlet />
        </div>
      </div>
    </div>
  `,
  styles: [`
    .admin-nav-item {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 9px 12px;
      border-radius: 8px;
      text-decoration: none;
      color: #8b949e;
      font-size: 13.5px;
      font-weight: 500;
      font-family: 'Cairo', sans-serif;
      margin-bottom: 2px;
      cursor: pointer;
      transition: background 0.15s, color 0.15s;
    }
    .admin-nav-item:hover { background: #21262d; color: #e6edf3; }
    .admin-active { background: rgba(233,69,96,0.15) !important; color: #e94560 !important; }
    .admin-nav-item .material-icons { font-size: 19px; }
  `]
})
export class AdminShellComponent {
  private auth = inject(AuthService);
  user = this.auth.currentUser;
  logout() { this.auth.logout(); }
}
