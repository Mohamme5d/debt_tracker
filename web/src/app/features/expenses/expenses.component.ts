import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { Expense } from '../../core/models';

@Component({
  selector: 'app-expenses',
  standalone: true,
  imports: [CommonModule, DatePipe],
  template: `
    <div class="page-header">
      <h2 class="page-title">Expenses</h2>
    </div>
    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Description</th>
            <th>Category</th>
            <th>Amount</th>
            <th>Period</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          @for (e of expenses(); track e.id) {
            <tr>
              <td>{{ e.description }}</td>
              <td>{{ e.category || '—' }}</td>
              <td>{{ e.amount | number:'1.0-0' }}</td>
              <td>{{ e.month }}/{{ e.year }}</td>
              <td>
                <span class="badge"
                  [class.badge-success]="e.status === 'Approved'"
                  [class.badge-danger]="e.status === 'Rejected'"
                  [class.badge-warning]="e.status === 'Pending'">
                  {{ e.status }}
                </span>
              </td>
            </tr>
          }
          @if (!expenses().length) {
            <tr><td colspan="5" class="table-empty">No expenses yet.</td></tr>
          }
        </tbody>
      </table>
    </div>
  `
})
export class ExpensesComponent implements OnInit {
  private api = inject(ApiService);
  expenses = signal<Expense[]>([]);
  ngOnInit() { this.api.get<Expense[]>('/expenses').subscribe(d => this.expenses.set(d)); }
}
