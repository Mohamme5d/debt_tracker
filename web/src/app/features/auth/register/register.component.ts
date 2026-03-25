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
  selector: 'app-register',
  standalone: true,
  imports: [
    ReactiveFormsModule, MatFormFieldModule, MatInputModule,
    MatButtonModule, MatIconModule, MatCardModule,
    MatSnackBarModule, MatProgressSpinnerModule, CommonModule, RouterLink
  ],
  template: `
    <div style="display:flex;justify-content:center;align-items:center;min-height:100vh;background:#f5f5f5;padding:24px">
      <mat-card style="width:440px;padding:32px">
        <h2 style="margin:0 0 24px;font-size:1.5rem">Create Account</h2>
        <form [formGroup]="form" (ngSubmit)="register()">
          <mat-form-field appearance="outline" style="width:100%">
            <mat-label>Business / Portfolio Name</mat-label>
            <input matInput formControlName="tenantName">
            <mat-icon matSuffix>business</mat-icon>
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:100%;margin-top:8px">
            <mat-label>Your Name</mat-label>
            <input matInput formControlName="name">
            <mat-icon matSuffix>person</mat-icon>
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:100%;margin-top:8px">
            <mat-label>Email</mat-label>
            <input matInput type="email" formControlName="email" autocomplete="email">
            <mat-icon matSuffix>email</mat-icon>
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:100%;margin-top:8px">
            <mat-label>Phone (optional)</mat-label>
            <input matInput type="tel" formControlName="phone">
            <mat-icon matSuffix>phone</mat-icon>
          </mat-form-field>
          <mat-form-field appearance="outline" style="width:100%;margin-top:8px">
            <mat-label>Password</mat-label>
            <input matInput [type]="hide ? 'password' : 'text'" formControlName="password" autocomplete="new-password">
            <button mat-icon-button matSuffix type="button" (click)="hide = !hide">
              <mat-icon>{{ hide ? 'visibility_off' : 'visibility' }}</mat-icon>
            </button>
          </mat-form-field>
          <button mat-flat-button color="primary" style="width:100%;margin-top:16px;height:44px" type="submit" [disabled]="loading || form.invalid">
            @if (loading) {
              <mat-spinner diameter="22" style="display:inline-block"></mat-spinner>
            } @else {
              Create Account
            }
          </button>
        </form>
        <div style="text-align:center;margin-top:20px">
          <a routerLink="/login" style="color:#3f51b5;text-decoration:none">Already have an account? Sign in</a>
        </div>
      </mat-card>
    </div>
  `
})
export class RegisterComponent {
  form: FormGroup;
  loading = false;
  hide = true;

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router, private snack: MatSnackBar) {
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
        this.snack.open(err.error?.message || 'Registration failed', 'Close', { duration: 3000 });
        this.loading = false;
      }
    });
  }
}
