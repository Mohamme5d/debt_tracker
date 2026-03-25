import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { ownerGuard } from './core/guards/owner.guard';
import { adminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./features/auth/login/login.component').then(m => m.LoginComponent) },
  { path: 'register', loadComponent: () => import('./features/auth/register/register.component').then(m => m.RegisterComponent) },

  // ── Super Admin section ───────────────────────────────────────────────────
  {
    path: 'admin',
    loadComponent: () => import('./features/admin/admin-shell.component').then(m => m.AdminShellComponent),
    canActivate: [adminGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', loadComponent: () => import('./features/admin/admin-dashboard.component').then(m => m.AdminDashboardComponent) },
      { path: 'tenants',   loadComponent: () => import('./features/admin/tenants/tenants.component').then(m => m.TenantsComponent) },
      { path: 'users',     loadComponent: () => import('./features/admin/users/admin-users.component').then(m => m.AdminUsersComponent) },
    ]
  },

  // ── Tenant user section ───────────────────────────────────────────────────
  {
    path: '',
    loadComponent: () => import('./app-shell/app-shell.component').then(m => m.AppShellComponent),
    canActivate: [authGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'apartments', loadComponent: () => import('./features/apartments/apartments.component').then(m => m.ApartmentsComponent) },
      { path: 'renters', loadComponent: () => import('./features/renters/renters.component').then(m => m.RentersComponent) },
      { path: 'payments', loadComponent: () => import('./features/payments/payments.component').then(m => m.PaymentsComponent) },
      { path: 'expenses', loadComponent: () => import('./features/expenses/expenses.component').then(m => m.ExpensesComponent) },
      { path: 'deposits', loadComponent: () => import('./features/deposits/deposits.component').then(m => m.DepositsComponent) },
      { path: 'approvals', canActivate: [ownerGuard], loadComponent: () => import('./features/approvals/approvals.component').then(m => m.ApprovalsComponent) },
      { path: 'employees', canActivate: [ownerGuard], loadComponent: () => import('./features/employees/employees.component').then(m => m.EmployeesComponent) },
      { path: 'reports', canActivate: [ownerGuard], loadComponent: () => import('./features/reports/reports.component').then(m => m.ReportsComponent) },
    ]
  },
  { path: '**', redirectTo: '' }
];
