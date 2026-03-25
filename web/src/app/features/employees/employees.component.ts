import { Component, OnInit, signal, inject } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { UserDto } from '../../core/models';

@Component({
  selector: 'invite-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatDialogModule, MatIconModule],
  template: `
    <h2 mat-dialog-title>Invite Employee</h2>
    <mat-dialog-content>
      <form [formGroup]="form" style="display:flex;flex-direction:column;gap:12px;min-width:320px;padding-top:8px">
        <mat-form-field appearance="outline"><mat-label>Name *</mat-label><input matInput formControlName="name"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Email *</mat-label><input matInput type="email" formControlName="email"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Phone</mat-label><input matInput formControlName="phone"></mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Password *</mat-label>
          <input matInput [type]="hide ? 'password' : 'text'" formControlName="password">
          <button mat-icon-button matSuffix type="button" (click)="hide = !hide">
            <mat-icon>{{ hide ? 'visibility_off' : 'visibility' }}</mat-icon>
          </button>
        </mat-form-field>
      </form>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancel</button>
      <button mat-flat-button color="primary" [mat-dialog-close]="form.value" [disabled]="form.invalid">Invite</button>
    </mat-dialog-actions>
  `
})
export class InviteDialogComponent {
  hide = true;
  form = inject(FormBuilder).group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    phone: [''],
    password: ['', [Validators.required, Validators.minLength(6)]]
  });
}

@Component({
  selector: 'app-employees',
  standalone: true,
  imports: [MatTableModule, MatButtonModule, MatIconModule, MatCardModule, MatDialogModule, MatSnackBarModule, CommonModule, InviteDialogComponent],
  template: `
    <div class="page-header">
      <h2 style="margin:0">Employees</h2>
      <button mat-flat-button color="primary" (click)="invite()">
        <mat-icon>person_add</mat-icon> Invite Employee
      </button>
    </div>
    <mat-card>
      <mat-table [dataSource]="employees()">
        <ng-container matColumnDef="name">
          <mat-header-cell *matHeaderCellDef>Name</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.name }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="email">
          <mat-header-cell *matHeaderCellDef>Email</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.email }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="phone">
          <mat-header-cell *matHeaderCellDef>Phone</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.phone || '—' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="active">
          <mat-header-cell *matHeaderCellDef>Active</mat-header-cell>
          <mat-cell *matCellDef="let e">{{ e.isActive ? 'Yes' : 'No' }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="actions">
          <mat-header-cell *matHeaderCellDef style="width:60px"></mat-header-cell>
          <mat-cell *matCellDef="let e">
            <button mat-icon-button color="warn" (click)="delete(e.id)" matTooltip="Remove">
              <mat-icon>person_remove</mat-icon>
            </button>
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
        <mat-row *matRowDef="let row; columns: cols"></mat-row>
      </mat-table>
      @if (!employees().length) {
        <p style="text-align:center;padding:24px;color:#888">No employees yet.</p>
      }
    </mat-card>
  `
})
export class EmployeesComponent implements OnInit {
  private api = inject(ApiService);
  private dialog = inject(MatDialog);
  private snack = inject(MatSnackBar);

  employees = signal<UserDto[]>([]);
  cols = ['name', 'email', 'phone', 'active', 'actions'];

  ngOnInit() { this.load(); }
  load() { this.api.get<UserDto[]>('/employees').subscribe(d => this.employees.set(d)); }

  invite() {
    const ref = this.dialog.open(InviteDialogComponent);
    ref.afterClosed().subscribe(result => {
      if (!result) return;
      this.api.post('/employees', result).subscribe({
        next: () => { this.snack.open('Employee invited', '', { duration: 2000 }); this.load(); },
        error: e => this.snack.open(e.error?.message || 'Error', 'Close', { duration: 3000 })
      });
    });
  }

  delete(id: string) {
    if (!confirm('Remove this employee?')) return;
    this.api.delete(`/employees/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.snack.open(e.error?.message || 'Error', 'Close', { duration: 3000 })
    });
  }
}
