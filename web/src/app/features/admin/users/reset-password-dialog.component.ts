import { Component, inject, Inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { AdminUser } from '../../../core/models';

@Component({
  selector: 'app-reset-password-dialog',
  standalone: true,
  imports: [FormsModule, MatDialogModule],
  template: `
    <div class="modal-header">
      <span class="modal-title">Reset Password — {{ user.name }}</span>
      <button class="btn-icon" mat-dialog-close>
        <span class="material-icons">close</span>
      </button>
    </div>
    <div class="modal-body">
      <div class="form-group" style="margin-bottom:0">
        <label class="form-label">New Password</label>
        <input class="form-control" type="password" [(ngModel)]="password" placeholder="Min 6 characters">
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-ghost" mat-dialog-close>Cancel</button>
      <button class="btn btn-primary" [disabled]="password.length < 6"
        (click)="dialogRef.close(password)">Set Password</button>
    </div>
  `
})
export class ResetPasswordDialogComponent {
  dialogRef = inject(MatDialogRef<ResetPasswordDialogComponent>);
  password = '';
  constructor(@Inject(MAT_DIALOG_DATA) public user: AdminUser) {}
}
