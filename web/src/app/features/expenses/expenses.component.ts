import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../core/services/api.service';
import { AuthService } from '../../core/services/auth.service';
import { ToastService } from '../../core/services/toast.service';
import { Expense } from '../../core/models';

@Component({
  selector: 'app-expenses',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Expenses</h2>
      <button class="btn btn-primary" (click)="openDialog()">
        <span class="material-icons">add</span> Add Expense
      </button>
    </div>

    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Description</th><th>Category</th><th>Amount</th>
            <th>Date</th><th>Period</th><th>Status</th>
            <th style="width:80px"></th>
          </tr>
        </thead>
        <tbody>
          @for (e of expenses(); track e.id) {
            <tr>
              <td>{{ e.description }}</td>
              <td>{{ e.category || '—' }}</td>
              <td>{{ e.amount | number:'1.0-0' }}</td>
              <td>{{ e.expenseDate | date:'mediumDate' }}</td>
              <td>{{ e.month }}/{{ e.year }}</td>
              <td>
                <span class="badge"
                  [class.badge-success]="e.status === 'Approved'"
                  [class.badge-danger]="e.status === 'Rejected'"
                  [class.badge-warning]="e.status === 'Draft'">{{ e.status }}</span>
              </td>
              <td>
                <button class="btn-icon" (click)="openDialog(e)"><span class="material-icons">edit</span></button>
                @if (isOwner()) {
                  <button class="btn-icon danger" (click)="delete(e.id)"><span class="material-icons">delete</span></button>
                }
              </td>
            </tr>
          }
          @if (!expenses().length) {
            <tr><td colspan="7" class="table-empty">No expenses yet.</td></tr>
          }
        </tbody>
      </table>
    </div>

    @if (showDialog()) {
      <div class="modal-overlay" (click)="backdropClick($event)">
        <div class="modal-panel">
          <div class="modal-header">
            <span class="modal-title">{{ editing() ? 'Edit Expense' : 'Add Expense' }}</span>
            <button class="btn-icon" (click)="closeDialog()"><span class="material-icons">close</span></button>
          </div>
          <div class="modal-body">
            <form #f="ngForm">
              <div class="form-group">
                <label class="form-label">Description *</label>
                <input class="form-control" type="text" [(ngModel)]="form.description" name="description" required placeholder="Expense description">
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Amount *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.amount" name="amount" required min="0" placeholder="0">
                </div>
                <div class="form-group">
                  <label class="form-label">Category</label>
                  <input class="form-control" type="text" [(ngModel)]="form.category" name="category" placeholder="e.g. Maintenance">
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Expense Date *</label>
                  <input class="form-control" type="date" [(ngModel)]="form.expenseDate" name="expenseDate" required>
                </div>
                <div class="form-group">
                  <label class="form-label">Month *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.month" name="month" required min="1" max="12" placeholder="1–12">
                </div>
                <div class="form-group">
                  <label class="form-label">Year *</label>
                  <input class="form-control" type="number" [(ngModel)]="form.year" name="year" required min="2000" placeholder="e.g. 2025">
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
export class ExpensesComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  private toast = inject(ToastService);

  expenses = signal<Expense[]>([]);
  isOwner = signal(this.auth.isOwner);
  showDialog = signal(false);
  editing = signal<Expense | null>(null);
  saving = signal(false);

  get today() { return new Date().toISOString().split('T')[0]; }

  form = { description: '', amount: 0, category: '', expenseDate: this.today, month: new Date().getMonth() + 1, year: new Date().getFullYear(), notes: '' };

  ngOnInit() { this.load(); }

  load() { this.api.get<Expense[]>('/expenses').subscribe(d => this.expenses.set(d)); }

  openDialog(e?: Expense) {
    this.editing.set(e ?? null);
    this.form = e
      ? { description: e.description, amount: e.amount, category: e.category ?? '', expenseDate: e.expenseDate.split('T')[0], month: e.month, year: e.year, notes: e.notes ?? '' }
      : { description: '', amount: 0, category: '', expenseDate: this.today, month: new Date().getMonth() + 1, year: new Date().getFullYear(), notes: '' };
    this.showDialog.set(true);
  }

  closeDialog() { this.showDialog.set(false); }

  backdropClick(e: MouseEvent) { if ((e.target as HTMLElement).classList.contains('modal-overlay')) this.closeDialog(); }

  save(f: any) {
    if (f.invalid) return;
    this.saving.set(true);
    const e = this.editing();
    const req = e ? this.api.put(`/expenses/${e.id}`, this.form) : this.api.post('/expenses', this.form);
    req.subscribe({
      next: () => { this.toast.success('Saved'); this.closeDialog(); this.load(); this.saving.set(false); },
      error: err => { this.toast.error(err.error?.message || 'Error saving'); this.saving.set(false); }
    });
  }

  delete(id: string) {
    if (!confirm('Delete this expense?')) return;
    this.api.delete(`/expenses/${id}`).subscribe({
      next: () => { this.toast.success('Deleted'); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Delete failed')
    });
  }
}
