import { Component, OnInit, signal, inject } from '@angular/core';
import { MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { ToastService } from '../../core/services/toast.service';
import { UserDto } from '../../core/models';

@Component({
  selector: 'invite-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, CommonModule],
  template: `
    <div class="modal-header">
      <span class="modal-title">Invite Employee</span>
      <button class="btn-icon" mat-dialog-close>
        <span class="material-icons">close</span>
      </button>
    </div>
    <div class="modal-body">
      <form [formGroup]="form" style="display:flex;flex-direction:column">
        <div class="form-group">
          <label class="form-label">Name *</label>
          <input class="form-control" type="text" formControlName="name" placeholder="Full name">
        </div>
        <div class="form-group">
          <label class="form-label">Email *</label>
          <input class="form-control" type="email" formControlName="email" placeholder="email@example.com">
        </div>
        <div class="form-group">
          <label class="form-label">Phone</label>
          <input class="form-control" type="tel" formControlName="phone" placeholder="Optional">
        </div>
        <div class="form-group" style="margin-bottom:0">
          <label class="form-label">Password *</label>
          <div style="position:relative">
            <input class="form-control" [type]="hide ? 'password' : 'text'"
              formControlName="password" placeholder="Min 6 characters">
            <button type="button" class="btn-icon"
              style="position:absolute;right:6px;top:50%;transform:translateY(-50%)"
              (click)="hide = !hide">
              <span class="material-icons" style="font-size:18px">{{ hide ? 'visibility_off' : 'visibility' }}</span>
            </button>
          </div>
        </div>
      </form>
    </div>
    <div class="modal-footer">
      <button class="btn btn-ghost" mat-dialog-close>Cancel</button>
      <button class="btn btn-primary" [mat-dialog-close]="form.value" [disabled]="form.invalid">Invite</button>
    </div>
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
  imports: [MatDialogModule, CommonModule, InviteDialogComponent],
  template: `
    <div class="page-header">
      <h2 class="page-title">Employees</h2>
      <button class="btn btn-primary" (click)="invite()">
        <span class="material-icons">person_add</span> Invite Employee
      </button>
    </div>
    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Active</th>
            <th style="width:60px"></th>
          </tr>
        </thead>
        <tbody>
          @for (e of employees(); track e.id) {
            <tr>
              <td><strong>{{ e.name }}</strong></td>
              <td>{{ e.email }}</td>
              <td>{{ e.phone || '—' }}</td>
              <td>{{ e.isActive ? 'Yes' : 'No' }}</td>
              <td>
                <button class="btn-icon danger" title="Remove" (click)="delete(e.id)">
                  <span class="material-icons">person_remove</span>
                </button>
              </td>
            </tr>
          }
          @if (!employees().length) {
            <tr><td colspan="5" class="table-empty">No employees yet.</td></tr>
          }
        </tbody>
      </table>
    </div>
  `
})
export class EmployeesComponent implements OnInit {
  private api = inject(ApiService);
  private dialog = inject(MatDialog);
  private toast = inject(ToastService);

  employees = signal<UserDto[]>([]);

  ngOnInit() { this.load(); }
  load() { this.api.get<UserDto[]>('/employees').subscribe(d => this.employees.set(d)); }

  invite() {
    const ref = this.dialog.open(InviteDialogComponent, {
      panelClass: 'dark-dialog',
      width: '480px'
    });
    ref.afterClosed().subscribe(result => {
      if (!result) return;
      this.api.post('/employees', result).subscribe({
        next: () => { this.toast.success('Employee invited'); this.load(); },
        error: e => this.toast.error(e.error?.message || 'Error')
      });
    });
  }

  delete(id: string) {
    if (!confirm('Remove this employee?')) return;
    this.api.delete(`/employees/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.error(e.error?.message || 'Error')
    });
  }
}
