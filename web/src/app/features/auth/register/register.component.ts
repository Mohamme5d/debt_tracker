import { Component, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';
import { ToastService } from '../../../core/services/toast.service';
import { ToastContainerComponent } from '../../../shared/toast-container.component';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule, RouterLink, ToastContainerComponent],
  template: `
    <div class="auth-page">
      <div class="auth-card" style="max-width:460px">
        <div class="auth-logo">
          <svg width="36" height="36" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M20 3L38 18V38H26V27H14V38H2V18L20 3Z" fill="#2563EB"/>
            <path d="M20 3L38 18H2L20 3Z" fill="#3B82F6"/>
            <circle cx="20" cy="28" r="3.5" fill="#0D1B2A" stroke="#F1F5F9" stroke-width="1.5"/>
            <rect x="19" y="30.5" width="2" height="5" rx="1" fill="#F1F5F9"/>
            <rect x="21" y="33.5" width="2.5" height="1.5" rx="0.75" fill="#F1F5F9"/>
          </svg>
          <span class="auth-logo-text">Create Account</span>
        </div>
        <p class="auth-subtitle">Start managing your properties</p>

        <form [formGroup]="form" (ngSubmit)="register()">
          <div class="form-group">
            <label class="form-label">Business / Portfolio Name *</label>
            <input class="form-control" type="text" formControlName="tenantName" placeholder="My Properties">
          </div>
          <div class="form-group">
            <label class="form-label">Your Name *</label>
            <input class="form-control" type="text" formControlName="name" placeholder="Full name">
          </div>
          <div class="form-group">
            <label class="form-label">Email *</label>
            <input class="form-control" type="email" formControlName="email" autocomplete="email" placeholder="you@example.com">
          </div>
          <div class="form-group">
            <label class="form-label">Phone (optional)</label>
            <input class="form-control" type="tel" formControlName="phone" placeholder="+966 5x xxx xxxx">
          </div>
          <div class="form-group">
            <label class="form-label">Password *</label>
            <div style="position:relative">
              <input class="form-control" [type]="hide ? 'password' : 'text'"
                formControlName="password" autocomplete="new-password" placeholder="Min 6 characters">
              <button type="button" class="btn-icon"
                style="position:absolute;right:6px;top:50%;transform:translateY(-50%)"
                (click)="hide = !hide">
                <span class="material-icons" style="font-size:18px">{{ hide ? 'visibility_off' : 'visibility' }}</span>
              </button>
            </div>
          </div>
          <button class="btn btn-primary" style="width:100%;justify-content:center;margin-top:8px;height:44px"
            type="submit" [disabled]="loading || form.invalid">
            @if (loading) {
              <span class="spinner"></span>
            } @else {
              Create Account
            }
          </button>
        </form>

        <div style="text-align:center;margin-top:20px;font-size:13px">
          <a routerLink="/login">Already have an account? Sign in</a>
        </div>
      </div>
    </div>
    <app-toast-container />
  `
})
export class RegisterComponent {
  form: FormGroup;
  loading = false;
  hide = true;

  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);
  private toast = inject(ToastService);

  constructor() {
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
    const { tenantName, name, email, phone, password } = this.form.value;
    this.auth.register({ tenantName, name, email, password, phone: phone || undefined }).subscribe({
      next: () => this.router.navigate(['/dashboard']),
      error: (err) => {
        this.toast.error(err.error?.message || 'Registration failed');
        this.loading = false;
      }
    });
  }
}
