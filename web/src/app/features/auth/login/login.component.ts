import { Component, signal, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';
import { LanguageService } from '../../../core/services/language.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule, RouterLink],
  template: `
    <div [dir]="lang.isRtl ? 'rtl' : 'ltr'"
         style="display:flex;justify-content:center;align-items:center;min-height:100vh;background:var(--bg)">
      <div style="width:400px;max-width:calc(100vw - 40px)">

        <div style="text-align:center;margin-bottom:32px">
          <div style="width:56px;height:56px;border-radius:16px;background:linear-gradient(135deg,var(--primary),var(--primary-dark));display:inline-flex;align-items:center;justify-content:center;margin-bottom:14px">
            <span class="material-icons" style="font-size:28px;color:#fff">home_work</span>
          </div>
          <h1 style="margin:0 0 4px;font-size:2rem;font-weight:800;color:var(--text)">Ijari</h1>
          <p style="margin:0;opacity:0.6;color:var(--text-muted)">{{ lang.t('rentManagement') }}</p>
        </div>

        <div class="card" style="padding:32px">
          @if (error()) {
            <div style="background:var(--warn-dim);border:1px solid var(--warn);border-radius:var(--radius-md);padding:10px 14px;margin-bottom:16px;color:var(--warn);font-size:13px">
              {{ error() }}
            </div>
          }
          <form [formGroup]="form" (ngSubmit)="login()">
            <div class="form-group" style="margin-bottom:14px">
              <label class="form-label">{{ lang.t('email') }}</label>
              <input class="form-control" type="email" formControlName="email" autocomplete="email">
            </div>
            <div class="form-group" style="margin-bottom:20px">
              <label class="form-label">{{ lang.t('password') }}</label>
              <div style="position:relative">
                <input class="form-control" [type]="hide ? 'password' : 'text'" formControlName="password" autocomplete="current-password">
                <button type="button" class="btn-icon"
                  style="position:absolute;inset-inline-end:6px;top:50%;transform:translateY(-50%)"
                  (click)="hide = !hide">
                  <span class="material-icons">{{ hide ? 'visibility_off' : 'visibility' }}</span>
                </button>
              </div>
            </div>
            <button class="btn btn-primary" type="submit" style="width:100%;justify-content:center;height:44px"
              [disabled]="loading || form.invalid">
              @if (loading) {
                <span class="material-icons" style="animation:spin 1s linear infinite;font-size:20px">refresh</span>
              } @else {
                {{ lang.t('signIn') }}
              }
            </button>
          </form>
        </div>

        <div style="text-align:center;margin-top:20px">
          <a routerLink="/register" style="text-decoration:none;opacity:0.7;color:var(--text-muted);font-size:13px">
            {{ lang.t('newAccount') }}
          </a>
        </div>

        <div style="text-align:center;margin-top:14px">
          <button class="lang-toggle" (click)="lang.toggleLang()" style="margin:0 auto">
            <span class="material-icons">translate</span>
            {{ lang.lang() === 'en' ? 'العربية' : 'English' }}
          </button>
        </div>
      </div>
    </div>

    <style>
      @keyframes spin { to { transform: rotate(360deg); } }
    </style>
  `
})
export class LoginComponent {
  lang = inject(LanguageService);
  form: FormGroup;
  loading = false;
  hide = true;
  error = signal('');

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router) {
    this.form = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', Validators.required]
    });
  }

  login() {
    if (this.form.invalid) return;
    this.loading = true;
    this.error.set('');
    const { email, password } = this.form.value;
    this.auth.login(email, password).subscribe({
      next: () => this.router.navigate([this.auth.isSuperAdmin ? '/admin/dashboard' : '/dashboard']),
      error: (err) => {
        this.error.set(err.error?.message || 'Login failed');
        this.loading = false;
      }
    });
  }
}
