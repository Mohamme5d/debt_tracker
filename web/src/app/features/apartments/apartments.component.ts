import { Component, OnInit, signal, inject } from '@angular/core';
import { MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { ToastService } from '../../core/services/toast.service';
import { Apartment } from '../../core/models';

@Component({
  selector: 'apt-form-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, CommonModule],
  template: `
    <div class="modal-header">
      <span class="modal-title">{{ title }}</span>
      <button class="btn-icon" mat-dialog-close>
        <span class="material-icons">close</span>
      </button>
    </div>
    <div class="modal-body">
      <form [formGroup]="form" style="display:flex;flex-direction:column;gap:0">
        <div class="form-group">
          <label class="form-label">Name *</label>
          <input class="form-control" type="text" formControlName="name" placeholder="Apartment name">
        </div>
        <div class="form-group">
          <label class="form-label">Address</label>
          <input class="form-control" type="text" formControlName="address" placeholder="Street address">
        </div>
        <div class="form-group">
          <label class="form-label">Description</label>
          <textarea class="form-control" formControlName="description" rows="2" placeholder="Optional description"></textarea>
        </div>
        <div class="form-group" style="margin-bottom:0">
          <label class="form-label">Notes</label>
          <textarea class="form-control" formControlName="notes" rows="2" placeholder="Optional notes"></textarea>
        </div>
      </form>
    </div>
    <div class="modal-footer">
      <button class="btn btn-ghost" mat-dialog-close>Cancel</button>
      <button class="btn btn-primary" [mat-dialog-close]="form.value" [disabled]="form.invalid">Save</button>
    </div>
  `
})
export class ApartmentFormDialogComponent {
  title = 'Add Apartment';
  form = inject(FormBuilder).group({
    name: ['', Validators.required],
    address: [''],
    description: [''],
    notes: ['']
  });
}

@Component({
  selector: 'app-apartments',
  standalone: true,
  imports: [MatDialogModule, CommonModule, ApartmentFormDialogComponent],
  template: `
    <div class="page-header">
      <h2 class="page-title">Apartments</h2>
      @if (isOwner()) {
        <button class="btn btn-primary" (click)="openDialog()">
          <span class="material-icons">add</span> Add Apartment
        </button>
      }
    </div>

    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Address</th>
            <th>Description</th>
            @if (isOwner()) { <th style="width:90px"></th> }
          </tr>
        </thead>
        <tbody>
          @for (a of apartments(); track a.id) {
            <tr>
              <td><strong>{{ a.name }}</strong></td>
              <td>{{ a.address || '—' }}</td>
              <td>{{ a.description || '—' }}</td>
              @if (isOwner()) {
                <td>
                  <button class="btn-icon" title="Edit" (click)="openDialog(a)">
                    <span class="material-icons">edit</span>
                  </button>
                  <button class="btn-icon danger" title="Delete" (click)="delete(a.id)">
                    <span class="material-icons">delete</span>
                  </button>
                </td>
              }
            </tr>
          }
          @if (!apartments().length) {
            <tr><td [colSpan]="isOwner() ? 4 : 3" class="table-empty">No apartments yet.</td></tr>
          }
        </tbody>
      </table>
    </div>
  `
})
export class ApartmentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private dialog = inject(MatDialog);
  private toast = inject(ToastService);

  apartments = signal<Apartment[]>([]);
  isOwner = signal(this.auth.isOwner);

  ngOnInit() { this.load(); }

  load() {
    this.api.get<Apartment[]>('/apartments').subscribe(data => this.apartments.set(data));
  }

  openDialog(apt?: Apartment) {
    const ref = this.dialog.open(ApartmentFormDialogComponent, {
      panelClass: 'dark-dialog',
      width: '500px'
    });
    if (apt) {
      ref.componentInstance.title = 'Edit Apartment';
      ref.componentInstance.form.patchValue(apt);
    }
    ref.afterClosed().subscribe(result => {
      if (!result) return;
      const obs = apt
        ? this.api.put(`/apartments/${apt.id}`, result)
        : this.api.post('/apartments', result);
      obs.subscribe({
        next: () => { this.toast.success('Saved successfully'); this.load(); },
        error: e => this.toast.error(e.error?.message || 'Error saving')
      });
    });
  }

  delete(id: string) {
    if (!confirm('Delete this apartment?')) return;
    this.api.delete(`/apartments/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.toast.error(e.error?.message || 'Delete failed')
    });
  }
}
