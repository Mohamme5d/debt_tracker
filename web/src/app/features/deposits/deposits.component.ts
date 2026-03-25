import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { MonthlyDeposit } from '../../core/models';

@Component({
  selector: 'app-deposits',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Monthly Deposits</h2>
    </div>
    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Period</th>
            <th>Amount</th>
            <th>Notes</th>
            <th>Status</th>
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
                  [class.badge-warning]="d.status === 'Pending'">
                  {{ d.status }}
                </span>
              </td>
            </tr>
          }
          @if (!deposits().length) {
            <tr><td colspan="4" class="table-empty">No deposits yet.</td></tr>
          }
        </tbody>
      </table>
    </div>
  `
})
export class DepositsComponent implements OnInit {
  private api = inject(ApiService);
  deposits = signal<MonthlyDeposit[]>([]);
  ngOnInit() { this.api.get<MonthlyDeposit[]>('/deposits').subscribe(d => this.deposits.set(d)); }
}
