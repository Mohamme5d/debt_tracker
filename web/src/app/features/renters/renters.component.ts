import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { ToastService } from '../../core/services/toast.service';
import { Renter, Apartment } from '../../core/models';

@Component({
  selector: 'app-renters',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Renters</h2>
      <button class="btn btn-primary" (click)="openDialog()">
        <span class="material-icons">add</span> Add Renter
      </button>
    </div>

    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Name</th><th>Apartment</th><th>Phone</th>
            <th>Monthly Rent</th><th>Active</th><th>Status</th>
            <th style="width:80px"></th>
          </tr>
        </thead>
        <tbody>
          @for (r of renters(); track r.id) {
            <tr>
              <td><strong>{{ r.name }}</strong></td>
              <td>{{ r.apartmentName }}</td>
              <td>{{ r.phone || '—' }}</td>
              <td>{{ r.monthlyRent | number:'1.0-0' }}</td>
              <td>{{ r.isActive ? 'Yes' : 'No' }}</td>
              <td>
                <span class="badge"
                  [class.badge-success]="r.status === 'Approved'"
                  [class.badge-danger]="r.status === 'Rejected'"
                  [class.badge-warning]="r.status === 'Draft'">{{ r.status }}</span>
              </td>
              <td>
                <button class="btn-icon" (click)="openDialog(r)"><span class="material-icons">edit</span></button>
                @if (isOwner()) {
                  <button class="btn-icon danger" (click)="delete(r.id)"><span class="material-icons">delete</span></button>
                }
              </td>
            </tr>
          }
          @if (!renters().length) {
            <tr><td colspan="7" class="table-empty">No renters yet.</td></tr>
          }
        </tbody>
      </table>
    </div>

    @if (showDialog()) {
      <div class="modal-overlay" (click)="backdropClick($event)">
        <div class="modal-panel">
          <div class="modal-header">
            <span class="modal-title">{{ editing() ? 'Edit Renter' : 'Add Renter' }}</span>
            <button class="btn-icon" (click)="closeDialog()"><span class="material-icons">close</span></button>
          </div>
          <div class="modal-body">
            <form #f="ngForm">
              <div class="form-group">
                <label class="form-label">Apartment *</label>
                <select class="form-control" [(ngModel)]="form.apartmentId" name="apartmentId" required>
                  <option value="">Select apartment</option>
                  @for (a of apartments(); track a.id) {
                    <option [value]="a.id">{{ a.name }}</option>
                  }
                </select>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Name *</label>
                  <input class="form-control" type="text" [(ngModel)]="form.name" name="name" required placeholder="Full name">
                </div>
                <div class="form-group">
                  <label class="form-label">Phone</label>
                  <input class="form-control" type="text" [(ngModel)]="form.phone" name="phone" placeholder="Phone number">
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Email</label>
                  <input class="form-control" type="email" [(ngModel)]="form.email" name="email" placeholder="Email address">
                </div>
                <div class="form-group">
                  <label class="form-label">Monthly Rent *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.monthlyRent" name="monthlyRent" required min="0" placeholder="0">
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Start Date *</label>
                  <input class="form-control" type="date" [(ngModel)]="form.startDate" name="startDate" required>
                </div>
                <div class="form-group" style="justify-content:flex-end;padding-top:22px">
                  <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13px;color:var(--text)">
                    <input type="checkbox" [(ngModel)]="form.isActive" name="isActive"> Active
                  </label>
                </div>
              </div>
              <div class="form-group" style="margin-bottom:0">
                <label class="form-label">Notes</label>
                <textarea class="form-control" [(ngModel)]="form.notes" name="notes" rows="2" placeholder="Optional notes"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-ghost" (click)="closeDialog()">Cancel</button>
            <button class="btn btn-primary" (click)="save(f)" [disabled]="f.invalid || saving()">
              @if (saving()) { <span class="spinner" style="border-top-color:#fff"></span> } @else { Save }
            </button>
          </div>
        </div>
      </div>
    }
  `
})
export class RentersComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private toast = inject(ToastService);

  renters = signal<Renter[]>([]);
  apartments = signal<Apartment[]>([]);
  isOwner = signal(this.auth.isOwner);
  showDialog = signal(false);
  editing = signal<Renter | null>(null);
  saving = signal(false);

  form = { apartmentId: '', name: '', phone: '', email: '', monthlyRent: 0, startDate: '', isActive: true, notes: '' };

  ngOnInit() {
    this.load();
    this.api.get<Apartment[]>('/apartments').subscribe(d => this.apartments.set(d));
  }

  load() { this.api.get<Renter[]>('/renters').subscribe(d => this.renters.set(d)); }

  openDialog(r?: Renter) {
    this.editing.set(r ?? null);
    const today = new Date().toISOString().split('T')[0];
    this.form = r
      ? { apartmentId: r.apartmentId, name: r.name, phone: r.phone ?? '', email: r.email ?? '', monthlyRent: r.monthlyRent, startDate: r.startDate.split('T')[0], isActive: r.isActive, notes: r.notes ?? '' }
      : { apartmentId: '', name: '', phone: '', email: '', monthlyRent: 0, startDate: today, isActive: true, notes: '' };
    this.showDialog.set(true);
  }

  closeDialog() { this.showDialog.set(false); }

  backdropClick(e: MouseEvent) { if ((e.target as HTMLElement).classList.contains('modal-overlay')) this.closeDialog(); }

  save(f: any) {
    if (f.invalid) return;
    this.saving.set(true);
    const body = { ...this.form };
    const r = this.editing();
    const req = r ? this.api.put(`/renters/${r.id}`, body) : this.api.post('/renters', body);
    req.subscribe({
      next: () => { this.toast.success('Saved'); this.closeDialog(); this.load(); this.saving.set(false); },
      error: e => { this.toast.error(e.error?.message || 'Error saving'); this.saving.set(false); }
    });
  }

  delete(id: string) {
    if (!confirm('Delete this renter?')) return;
    this.api.delete(`/renters/${id}`).subscribe({
      next: () => { this.toast.success('Deleted'); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Delete failed')
    });
  }
}
