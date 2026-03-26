import { Component, OnInit, signal, inject } from '@angular/core';
import { MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { ToastService } from '../../core/services/toast.service';
import { UserDto, Apartment } from '../../core/models';

@Component({
  selector: 'invite-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, CommonModule],
  template: `
    <div class="modal-header">
      <span class="modal-title">Invite Employee</span>
      <button class="btn-icon" mat-dialog-close><span class="material-icons">close</span></button>
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
  imports: [MatDialogModule, CommonModule, FormsModule, InviteDialogComponent],
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
            <th>Name</th><th>Email</th><th>Phone</th><th>Active</th>
            <th>Assigned Apartments</th><th style="width:100px"></th>
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
                @if (assignmentMap()[e.id]) {
                  <span class="badge badge-primary">{{ assignmentMap()[e.id] }} apt(s)</span>
                } @else {
                  <span class="text-secondary" style="font-size:12px">None assigned</span>
                }
              </td>
              <td style="display:flex;gap:4px">
                <button class="btn-icon" title="Manage Apartments" (click)="manageApartments(e)">
                  <span class="material-icons">apartment</span>
                </button>
                <button class="btn-icon danger" title="Remove" (click)="delete(e.id)">
                  <span class="material-icons">person_remove</span>
                </button>
              </td>
            </tr>
          }
          @if (!employees().length) {
            <tr><td colspan="6" class="table-empty">No employees yet.</td></tr>
          }
        </tbody>
      </table>
    </div>

    <!-- Assign Apartments Modal -->
    @if (showAssignDialog()) {
      <div class="modal-overlay" (click)="backdropClick($event)">
        <div class="modal-panel">
          <div class="modal-header">
            <span class="modal-title">Assign Apartments — {{ selectedEmployee()?.name }}</span>
            <button class="btn-icon" (click)="closeAssignDialog()"><span class="material-icons">close</span></button>
          </div>
          <div class="modal-body">
            <p style="font-size:13px;color:var(--text-secondary);margin:0 0 14px">
              Select which apartments this employee can view and manage.
            </p>
            <div style="display:flex;flex-direction:column;gap:10px">
              @for (apt of apartments(); track apt.id) {
                <label style="display:flex;align-items:center;gap:10px;cursor:pointer;padding:10px 12px;border-radius:8px;border:1px solid var(--border);transition:background 0.15s"
                  [style.background]="isAptSelected(apt.id) ? 'rgba(37,99,235,0.12)' : 'var(--surface2)'"
                  [style.border-color]="isAptSelected(apt.id) ? 'var(--primary)' : 'var(--border)'">
                  <input type="checkbox" [checked]="isAptSelected(apt.id)" (change)="toggleApt(apt.id)">
                  <span style="font-size:13.5px;font-weight:500;color:var(--text)">{{ apt.name }}</span>
                  @if (apt.address) {
                    <span style="font-size:12px;color:var(--text-secondary);margin-left:auto">{{ apt.address }}</span>
                  }
                </label>
              }
              @if (!apartments().length) {
                <p class="text-secondary" style="font-size:13px;text-align:center;padding:16px 0">No apartments found.</p>
              }
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-ghost" (click)="closeAssignDialog()">Cancel</button>
            <button class="btn btn-primary" (click)="saveAssignments()" [disabled]="savingAssignments()">
              @if (savingAssignments()) { <span class="spinner" style="border-top-color:#fff"></span> } @else { Save }
            </button>
          </div>
        </div>
      </div>
    }
  `
})
export class EmployeesComponent implements OnInit {
  private api = inject(ApiService);
  private dialog = inject(MatDialog);
  private toast = inject(ToastService);

  employees = signal<UserDto[]>([]);
  apartments = signal<Apartment[]>([]);
  assignmentMap = signal<Record<string, number>>({});
  showAssignDialog = signal(false);
  selectedEmployee = signal<UserDto | null>(null);
  selectedAptIds = signal<Set<string>>(new Set());
  savingAssignments = signal(false);

  ngOnInit() {
    this.load();
    this.api.get<Apartment[]>('/apartments').subscribe(d => this.apartments.set(d));
  }

  load() {
    this.api.get<UserDto[]>('/employees').subscribe(employees => {
      this.employees.set(employees);
      // Load assignment counts
      const map: Record<string, number> = {};
      employees.forEach(e => {
        this.api.get<{apartmentId: string, name: string}[]>(`/employees/${e.id}/apartments`).subscribe(apts => {
          map[e.id] = apts.length;
          this.assignmentMap.set({ ...map });
        });
      });
    });
  }

  invite() {
    const ref = this.dialog.open(InviteDialogComponent, { panelClass: 'dark-dialog', width: '480px' });
    ref.afterClosed().subscribe(result => {
      if (!result) return;
      this.api.post('/employees', result).subscribe({
        next: () => { this.toast.success('Employee invited'); this.load(); },
        error: e => this.toast.error(e.error?.message || 'Error')
      });
    });
  }

  manageApartments(e: UserDto) {
    this.selectedEmployee.set(e);
    this.api.get<{apartmentId: string}[]>(`/employees/${e.id}/apartments`).subscribe(apts => {
      this.selectedAptIds.set(new Set(apts.map(a => a.apartmentId)));
      this.showAssignDialog.set(true);
    });
  }

  isAptSelected(id: string) { return this.selectedAptIds().has(id); }

  toggleApt(id: string) {
    const set = new Set(this.selectedAptIds());
    set.has(id) ? set.delete(id) : set.add(id);
    this.selectedAptIds.set(set);
  }

  saveAssignments() {
    const e = this.selectedEmployee();
    if (!e) return;
    this.savingAssignments.set(true);
    const ids = Array.from(this.selectedAptIds());
    this.api.put(`/employees/${e.id}/apartments`, ids).subscribe({
      next: () => { this.toast.success('Apartments assigned'); this.closeAssignDialog(); this.load(); this.savingAssignments.set(false); },
      error: err => { this.toast.error(err.error?.message || 'Error'); this.savingAssignments.set(false); }
    });
  }

  closeAssignDialog() { this.showAssignDialog.set(false); }

  backdropClick(e: MouseEvent) { if ((e.target as HTMLElement).classList.contains('modal-overlay')) this.closeAssignDialog(); }

  delete(id: string) {
    if (!confirm('Remove this employee?')) return;
    this.api.delete(`/employees/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.error(e.error?.message || 'Error')
    });
  }
}
