import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';
import { Expense } from '../../core/models';

@Component({
  selector: 'app-expenses',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('expenses') }}</h2>
    </div>
    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('description') }}</th>
            <th>{{ lang.t('category') }}</th>
            <th>{{ lang.t('amount') }}</th>
            <th>{{ lang.t('period') }}</th>
            <th>{{ lang.t('status') }}</th>
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
                <span class="badge" [class]="statusClass(e.status)">
                  {{ lang.t(e.status?.toLowerCase() || 'pending') }}
                </span>
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!expenses().length) {
        <div class="empty-state">{{ lang.t('noExpensesYet') }}</div>
      }
    </div>
  `
})
export class ExpensesComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);
  expenses = signal<Expense[]>([]);

  ngOnInit() { this.api.get<Expense[]>('/expenses').subscribe(d => this.expenses.set(d)); }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }
}
