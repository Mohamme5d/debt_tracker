import { Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap } from 'rxjs/operators';
import { AuthResponse, UserDto } from '../models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  currentUser = signal<UserDto | null>(JSON.parse(localStorage.getItem('ijari_user') || 'null'));

  constructor(private http: HttpClient, private router: Router) {}

  login(email: string, password: string) {
    return this.http.post<AuthResponse>('/api/auth/login', { email, password }).pipe(
      tap(res => this.saveSession(res))
    );
  }

  register(data: { tenantName: string; name: string; email: string; password: string; phone?: string }) {
    return this.http.post<AuthResponse>('/api/auth/register', data).pipe(
      tap(res => this.saveSession(res))
    );
  }

  refresh() {
    const rt = localStorage.getItem('ijari_refresh');
    return this.http.post<AuthResponse>('/api/auth/refresh', { refreshToken: rt }).pipe(
      tap(res => this.saveSession(res))
    );
  }

  logout() {
    const rt = localStorage.getItem('ijari_refresh');
    this.http.post('/api/auth/logout', { refreshToken: rt }).subscribe();
    localStorage.removeItem('ijari_token');
    localStorage.removeItem('ijari_refresh');
    localStorage.removeItem('ijari_user');
    this.currentUser.set(null);
    this.router.navigate(['/login']);
  }

  saveSession(res: AuthResponse) {
    localStorage.setItem('ijari_token', res.accessToken);
    localStorage.setItem('ijari_refresh', res.refreshToken);
    localStorage.setItem('ijari_user', JSON.stringify(res.user));
    this.currentUser.set(res.user);
  }

  get token() { return localStorage.getItem('ijari_token'); }
  get isOwner() { return this.currentUser()?.role === 'Owner'; }
  get isSuperAdmin() { return this.currentUser()?.role === 'SuperAdmin'; }
  get isLoggedIn() { return !!this.currentUser() && !!this.token; }
}
