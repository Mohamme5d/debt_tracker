import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { ToastService } from '../../core/services/toast.service';
import { MonthlyDeposit } from '../../core/models';

@Component({
  selector: 'app-deposits',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Monthly Deposits</h2>
      <button class="btn btn-primary" (click)="openDialog()">
        <span class="material-icons">add</span> Add Deposit
      </button>
    </div>

    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Period</th><th>Amount</th><th>Notes</th><th>Status</th>
            <th style="width:80px"></th>
          </tr>
        </thead>
        <tbody>
          @for (d of deposits(); track d.id) {
            <tr>
              <td>{{ d.depositMonth }}/{{ d.depositYear }}</td>
              <td>{{ d.amount | number:'1.0-0' }}</td>
              <td>{{ d.notes || '—' }}</td>
              <td>
                <span class="badge"
                  [class.badge-success]="d.status === 'Approved'"
                  [class.badge-danger]="d.status === 'Rejected'"
                  [class.badge-warning]="d.status === 'Draft'">{{ d.status }}</span>
              </td>
              <td>
                <button class="btn-icon" (click)="openDialog(d)"><span class="material-icons">edit</span></button>
                @if (isOwner()) {
                  <button class="btn-icon danger" (click)="delete(d.id)"><span class="material-icons">delete</span></button>
                }
              </td>
            </tr>
          }
          @if (!deposits().length) {
            <tr><td colspan="5" class="table-empty">No deposits yet.</td></tr>
          }
        </tbody>
      </table>
    </div>

    @if (showDialog()) {
      <div class="modal-overlay" (click)="backdropClick($event)">
        <div class="modal-panel">
          <div class="modal-header">
            <span class="modal-title">{{ editing() ? 'Edit Deposit' : 'Add Deposit' }}</span>
            <button class="btn-icon" (click)="closeDialog()"><span class="material-icons">close</span></button>
          </div>
          <div class="modal-body">
            <form #f="ngForm">
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Month *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.depositMonth" name="depositMonth" required min="1" max="12" placeholder="1–12">
                </div>
                <div class="form-group">
                  <label class="form-label">Year *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.depositYear" name="depositYear" required min="2000" placeholder="e.g. 2025">
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">Amount *</label>
                <input class="form-control" type="number" [(ngModel)]="form.amount" name="amount" required min="0" placeholder="0">
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
export class DepositsComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private toast = inject(ToastService);

  deposits = signal<MonthlyDeposit[]>([]);
  isOwner = signal(this.auth.isOwner);
  showDialog = signal(false);
  editing = signal<MonthlyDeposit | null>(null);
  saving = signal(false);

  form = { depositMonth: new Date().getMonth() + 1, depositYear: new Date().getFullYear(), amount: 0, notes: '' };

  ngOnInit() { this.load(); }

  load() { this.api.get<MonthlyDeposit[]>('/deposits').subscribe(d => this.deposits.set(d)); }

  openDialog(d?: MonthlyDeposit) {
    this.editing.set(d ?? null);
    this.form = d
      ? { depositMonth: d.depositMonth, depositYear: d.depositYear, amount: d.amount, notes: d.notes ?? '' }
      : { depositMonth: new Date().getMonth() + 1, depositYear: new Date().getFullYear(), amount: 0, notes: '' };
    this.showDialog.set(true);
  }

  closeDialog() { this.showDialog.set(false); }

  backdropClick(e: MouseEvent) { if ((e.target as HTMLElement).classList.contains('modal-overlay')) this.closeDialog(); }

  save(f: any) {
    if (f.invalid) return;
    this.saving.set(true);
    const d = this.editing();
    const req = d ? this.api.put(`/deposits/${d.id}`, this.form) : this.api.post('/deposits', this.form);
    req.subscribe({
      next: () => { this.toast.success('Saved'); this.closeDialog(); this.load(); this.saving.set(false); },
      error: e => { this.toast.error(e.error?.message || 'Error saving'); this.saving.set(false); }
    });
  }

  delete(id: string) {
    if (!confirm('Delete this deposit?')) return;
    this.api.delete(`/deposits/${id}`).subscribe({
      next: () => { this.toast.success('Deleted'); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Delete failed')
    });
  }
}
