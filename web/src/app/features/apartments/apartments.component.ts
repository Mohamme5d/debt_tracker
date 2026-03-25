import { Component, OnInit, signal, inject } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatCardModule } from '@angular/material/card';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { Apartment } from '../../core/models';

@Component({
  selector: 'apt-form-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatFormFieldModule, MatInputModule, MatButtonModule, MatDialogModule],
  template: `
    <h2 mat-dialog-title>{{ title }}</h2>
    <mat-dialog-content>
      <form [formGroup]="form" style="display:flex;flex-direction:column;gap:12px;min-width:320px;padding-top:8px">
        <mat-form-field appearance="outline">
          <mat-label>Name *</mat-label>
          <input matInput formControlName="name">
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Address</mat-label>
          <input matInput formControlName="address">
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Description</mat-label>
          <textarea matInput formControlName="description" rows="2"></textarea>
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Notes</mat-label>
          <textarea matInput formControlName="notes" rows="2"></textarea>
        </mat-form-field>
      </form>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancel</button>
      <button mat-flat-button color="primary" [mat-dialog-close]="form.value" [disabled]="form.invalid">Save</button>
    </mat-dialog-actions>
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
  imports: [
    MatTableModule, MatButtonModule, MatIconModule,
    MatDialogModule, MatSnackBarModule, MatCardModule, CommonModule,
    ApartmentFormDialogComponent
  ],
  template: `
    <div class="page-header">
      <h2 style="margin:0">Apartments</h2>
      @if (isOwner()) {
        <button mat-flat-button color="primary" (click)="openDialog()">
          <mat-icon>add</mat-icon> Add Apartment
        </button>
      }
    </div>
    <mat-card>
      <mat-table [dataSource]="apartments()">
        <ng-container matColumnDef="name">
          <mat-header-cell *matHeaderCellDef>Name</mat-header-cell>
          <mat-cell *matCellDef="let a">{{ a.name }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="address">
          <mat-header-cell *matHeaderCellDef>Address</mat-header-cell>
          <mat-cell *matCellDef="let a">{{ a.address }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="description">
          <mat-header-cell *matHeaderCellDef>Description</mat-header-cell>
          <mat-cell *matCellDef="let a">{{ a.description }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="actions">
          <mat-header-cell *matHeaderCellDef style="width:100px"></mat-header-cell>
          <mat-cell *matCellDef="let a">
            @if (isOwner()) {
              <button mat-icon-button (click)="openDialog(a)" matTooltip="Edit">
                <mat-icon>edit</mat-icon>
              </button>
              <button mat-icon-button color="warn" (click)="delete(a.id)" matTooltip="Delete">
                <mat-icon>delete</mat-icon>
              </button>
            }
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="cols"></mat-header-row>
        <mat-row *matRowDef="let row; columns: cols"></mat-row>
      </mat-table>
      @if (!apartments().length) {
        <p style="text-align:center;padding:24px;color:#888">No apartments yet.</p>
      }
    </mat-card>
  `
})
export class ApartmentsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private dialog = inject(MatDialog);
  private snack = inject(MatSnackBar);

  apartments = signal<Apartment[]>([]);
  isOwner = signal(this.auth.isOwner);
  cols = ['name', 'address', 'description', 'actions'];

  ngOnInit() { this.load(); }

  load() {
    this.api.get<Apartment[]>('/apartments').subscribe(data => this.apartments.set(data));
  }

  openDialog(apt?: Apartment) {
    const ref = this.dialog.open(ApartmentFormDialogComponent);
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
        next: () => { this.snack.open('Saved successfully', '', { duration: 2000 }); this.load(); },
        error: e => this.snack.open(e.error?.message || 'Error saving', 'Close', { duration: 3000 })
      });
    });
  }

  delete(id: string) {
    if (!confirm('Delete this apartment?')) return;
    this.api.delete(`/apartments/${id}`).subscribe({
      next: () => this.load(),
      error: e => this.snack.open(e.error?.message || 'Delete failed', 'Close', { duration: 3000 })
    });
  }
}
