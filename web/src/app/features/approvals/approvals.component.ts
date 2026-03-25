import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { ToastService } from '../../core/services/toast.service';
import { ApprovalRequest } from '../../core/models';

@Component({
  selector: 'app-approvals',
  standalone: true,
  imports: [CommonModule, DatePipe],
  template: `
    <div class="page-header">
      <h2 class="page-title">Approvals</h2>
      <button class="btn btn-ghost" (click)="showAll = !showAll; load()">
        <span class="material-icons">{{ showAll ? 'filter_list_off' : 'filter_list' }}</span>
        {{ showAll ? 'Show Pending' : 'Show All' }}
      </button>
    </div>
    <div class="card" style="padding:0;overflow:hidden">
      <table class="data-table">
        <thead>
          <tr>
            <th>Submitted By</th>
            <th>Type</th>
            <th>Action</th>
            <th>Status</th>
            <th>Date</th>
            <th style="width:100px"></th>
          </tr>
        </thead>
        <tbody>
          @for (r of requests(); track r.id) {
            <tr>
              <td>{{ r.submittedByName }}</td>
              <td>{{ r.entityType }}</td>
              <td>{{ r.action }}</td>
              <td>
                <span class="badge"
                  [class.badge-success]="r.status === 'Approved'"
                  [class.badge-danger]="r.status === 'Rejected'"
                  [class.badge-warning]="r.status === 'Pending'">
                  {{ r.status }}
                </span>
              </td>
              <td style="font-size:12px;color:var(--text-secondary)">{{ r.createdAt | date:'short' }}</td>
              <td>
                @if (r.status === 'Pending') {
                  <button class="btn-icon success" title="Approve" (click)="approve(r.id)">
                    <span class="material-icons">check_circle</span>
                  </button>
                  <button class="btn-icon danger" title="Reject" (click)="reject(r.id)">
                    <span class="material-icons">cancel</span>
                  </button>
                }
              </td>
            </tr>
          }
          @if (!requests().length) {
            <tr><td colspan="6" class="table-empty">No pending approvals.</td></tr>
          }
        </tbody>
      </table>
    </div>
  `
})
export class ApprovalsComponent implements OnInit {
  private api = inject(ApiService);
  private toast = inject(ToastService);
  requests = signal<ApprovalRequest[]>([]);
  showAll = false;

  ngOnInit() { this.load(); }

  load() {
    const path = this.showAll ? '/approvals/all' : '/approvals';
    this.api.get<ApprovalRequest[]>(path).subscribe(d => this.requests.set(d));
  }

  approve(id: string) {
    this.api.put(`/approvals/${id}/approve`, {}).subscribe({
      next: () => { this.toast.success('Approved'); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Error')
    });
  }

  reject(id: string) {
    this.api.put(`/approvals/${id}/reject`, {}).subscribe({
      next: () => { this.toast.info('Rejected'); this.load(); },
      error: e => this.toast.error(e.error?.message || 'Error')
    });
  }
}
