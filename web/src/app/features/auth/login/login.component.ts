import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    ReactiveFormsModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule, MatCardModule,
    MatSnackBarModule, MatProgressSpinnerModule, CommonModule, RouterLink
  ],
  template: `
    <div style="display:flex;justify-content:center;align-items:center;min-height:100vh;background:#f5f5f5">
      <mat-card style="width:400px;padding:32px">
        <div style="text-align:center;margin-bottom:24px">
          <mat-icon style="font-size:56px;height:56px;width:56px;color:#3f51b5">home_work</mat-icon>
          <h1 style="margin:8px 0 4px;font-size:2rem">Ijari</h1>
          <p style="color:#888;margin:0">Rent Management Platform</p>
        </div>
        <form [formGroup]="form" (ngSubmit)="login()">
          <mat-form-field appearance="outline" style="width:100%">
            <mat-label>Email</mat-label>
            <input matInput type="email" formControlName="email" autocomplete="email">
            <mat-icon matSuffix>email</mat-icon>
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:100%;margin-top:8px">
            <mat-label>Password</mat-label>
            <input matInput [type]="hide ? 'password' : 'text'" formControlName="password" autocomplete="current-password">
            <button mat-icon-button matSuffix type="button" (click)="hide = !hide">
              <mat-icon>{{ hide ? 'visibility_off' : 'visibility' }}</mat-icon>
            </button>
          </mat-form-field>
          <button mat-flat-button color="primary" style="width:100%;margin-top:16px;height:44px" type="submit" [disabled]="loading || form.invalid">
            @if (loading) {
              <mat-spinner diameter="22" style="display:inline-block"></mat-spinner>
            } @else {
              Sign In
            }
          </button>
        </form>
        <div style="text-align:center;margin-top:20px">
          <a routerLink="/register" style="color:#3f51b5;text-decoration:none">New account? Register here</a>
        </div>
      </mat-card>
    </div>
  `
})
export class LoginComponent {
  form: FormGroup;
  loading = false;
  hide = true;

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router, private snack: MatSnackBar) {
    this.form = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', Validators.required]
    });
  }

  login() {
    if (this.form.invalid) return;
    this.loading = true;
    const { email, password } = this.form.value;
    this.auth.login(email, password).subscribe({
      next: () => this.router.navigate([this.auth.isSuperAdmin ? '/admin/dashboard' : '/dashboard']),
      error: (err) => {
        this.snack.open(err.error?.message || 'Login failed', 'Close', { duration: 3000 });
        this.loading = false;
      }
    });
  }
}
