import { Component, inject, Inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { AdminUser } from '../../../core/models';

@Component({
  selector: 'app-reset-password-dialog',
  standalone: true,
  imports: [FormsModule, MatDialogModule, MatButtonModule, MatInputModule, MatFormFieldModule],
  template: `
    <h3 mat-dialog-title>Reset Password — {{ user.name }}</h3>
    <mat-dialog-content>
      <mat-form-field appearance="outline" style="width:100%;margin-top:8px">
        <mat-label>New Password</mat-label>
        <input matInput type="password" [(ngModel)]="password" />
      </mat-form-field>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancel</button>
      <button mat-flat-button color="primary" [disabled]="password.length < 6"
        (click)="dialogRef.close(password)">Set Password</button>
    </mat-dialog-actions>
  `
})
export class ResetPasswordDialogComponent {
  dialogRef = inject(MatDialogRef<ResetPasswordDialogComponent>);
  password = '';
  constructor(@Inject(MAT_DIALOG_DATA) public user: AdminUser) {}
}
