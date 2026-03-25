import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { Renter } from '../../core/models';

@Component({
  selector: 'app-renters',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-header">
      <h2 class="page-title">Renters</h2>
    </div>
    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Apartment</th>
            <th>Phone</th>
            <th>Monthly Rent</th>
            <th>Active</th>
            <th>Status</th>
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
                  [class.badge-warning]="r.status === 'Pending'">
                  {{ r.status }}
                </span>
              </td>
            </tr>
          }
          @if (!renters().length) {
            <tr><td colspan="6" class="table-empty">No renters yet.</td></tr>
          }
        </tbody>
      </table>
    </div>
  `
})
export class RentersComponent implements OnInit {
  private api = inject(ApiService);
  renters = signal<Renter[]>([]);

  ngOnInit() {
    this.api.get<Renter[]>('/renters').subscribe(data => this.renters.set(data));
  }
}
