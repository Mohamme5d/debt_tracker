import { Component, signal } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule, RouterLink],
  template: `
    <div style="display:flex;justify-content:center;align-items:center;min-height:100vh;background:var(--bg);padding:24px">
      <div style="width:440px;max-width:calc(100vw - 40px)">
        <div class="card" style="padding:32px">
          <h2 style="margin:0 0 24px;font-size:1.5rem;font-weight:700;color:var(--text)">Create Account</h2>

          @if (error()) {
            <div style="background:var(--warn-dim);border:1px solid var(--warn);border-radius:var(--radius-md);padding:10px 14px;margin-bottom:16px;color:var(--warn);font-size:13px">
              {{ error() }}
            </div>
          }

          <form [formGroup]="form" (ngSubmit)="register()">
            <div class="form-group" style="margin-bottom:12px">
              <label class="form-label">Business / Portfolio Name *</label>
              <input class="form-control" formControlName="tenantName">
            </div>
            <div class="form-group" style="margin-bottom:12px">
              <label class="form-label">Your Name *</label>
              <input class="form-control" formControlName="name">
            </div>
            <div class="form-group" style="margin-bottom:12px">
              <label class="form-label">Email *</label>
              <input class="form-control" type="email" formControlName="email" autocomplete="email">
            </div>
            <div class="form-group" style="margin-bottom:12px">
              <label class="form-label">Phone (optional)</label>
              <input class="form-control" type="tel" formControlName="phone">
            </div>
            <div class="form-group" style="margin-bottom:20px">
              <label class="form-label">Password *</label>
              <div style="position:relative">
                <input class="form-control" [type]="hide ? 'password' : 'text'" formControlName="password" autocomplete="new-password">
                <button type="button" class="btn-icon"
                  style="position:absolute;right:6px;top:50%;transform:translateY(-50%)"
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
                Create Account
              }
            </button>
          </form>

          <div style="text-align:center;margin-top:20px">
            <a routerLink="/login" style="text-decoration:none;color:var(--primary);font-size:13px">
              Already have an account? Sign in
            </a>
          </div>
        </div>
      </div>
    </div>
    <style>@keyframes spin { to { transform: rotate(360deg); } }</style>
  `
})
export class RegisterComponent {
  form: FormGroup;
  loading = false;
  hide = true;
  error = signal('');

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router) {
    this.form = this.fb.group({
      tenantName: ['', Validators.required],
      name: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: [''],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  register() {
    if (this.form.invalid) return;
    this.loading = true;
    this.error.set('');
    const { tenantName, name, email, phone, password } = this.form.value;
    this.auth.register({ tenantName, name, email, password, phone: phone || undefined }).subscribe({
      next: () => this.router.navigate(['/dashboard']),
      error: (err) => {
        this.error.set(err.error?.message || 'Registration failed');
        this.loading = false;
      }
    });
  }
}
