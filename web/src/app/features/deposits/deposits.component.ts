import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';
import { MonthlyDeposit } from '../../core/models';

@Component({
  selector: 'app-deposits',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('monthlyDeposits') }}</h2>
    </div>
    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('period') }}</th>
            <th>{{ lang.t('amount') }}</th>
            <th>{{ lang.t('notes') }}</th>
            <th>{{ lang.t('status') }}</th>
          </tr>
        </thead>
        <tbody>
          @for (d of deposits(); track d.id) {
            <tr>
              <td>{{ d.depositMonth }}/{{ d.depositYear }}</td>
              <td>{{ d.amount | number:'1.0-0' }}</td>
              <td>{{ d.notes || '—' }}</td>
              <td>
                <span class="badge" [class]="statusClass(d.status)">
                  {{ lang.t(d.status?.toLowerCase() || 'pending') }}
                </span>
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!deposits().length) {
        <div class="empty-state">{{ lang.t('noDepositsYet') }}</div>
      }
    </div>
  `
})
export class DepositsComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);
  deposits = signal<MonthlyDeposit[]>([]);

  ngOnInit() { this.api.get<MonthlyDeposit[]>('/deposits').subscribe(d => this.deposits.set(d)); }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }
}
