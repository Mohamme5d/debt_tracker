import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService } from '../../core/services/api.service';
import { LanguageService } from '../../core/services/language.service';
import { ToastService } from '../../core/services/toast.service';
import { ApprovalRequest } from '../../core/models';

@Component({
  selector: 'app-approvals',
  standalone: true,
  imports: [CommonModule, DatePipe],
  template: `
    <div class="page-header">
      <h2>{{ lang.t('approvals') }}</h2>
      <button class="btn btn-outline" (click)="showAll = !showAll; load()">
        {{ showAll ? lang.t('showPending') : lang.t('showAll') }}
      </button>
    </div>
    <div class="card">
      <table class="data-table">
        <thead>
          <tr>
            <th>{{ lang.t('submittedBy') }}</th>
            <th>{{ lang.t('type') }}</th>
            <th>{{ lang.t('action') }}</th>
            <th>{{ lang.t('status') }}</th>
            <th>{{ lang.t('date') }}</th>
            <th class="col-actions"></th>
          </tr>
        </thead>
        <tbody>
          @for (r of requests(); track r.id) {
            <tr>
              <td>{{ r.submittedByName }}</td>
              <td>{{ r.entityType }}</td>
              <td>{{ r.action }}</td>
              <td>
                <span class="badge" [class]="statusClass(r.status)">
                  {{ lang.t(r.status?.toLowerCase() || 'pending') }}
                </span>
              </td>
              <td>{{ r.createdAt | date:'short' }}</td>
              <td class="col-actions">
                @if (r.status === 'Pending') {
                  <button class="btn-icon btn-icon-primary" (click)="approve(r.id)" [title]="lang.t('approve')">
                    <span class="material-icons">check_circle</span>
                  </button>
                  <button class="btn-icon btn-icon-warn" (click)="reject(r.id)" [title]="lang.t('reject')">
                    <span class="material-icons">cancel</span>
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
      @if (!requests().length) {
        <div class="empty-state">{{ lang.t('noPendingApprovals') }}</div>
      }
    </div>
  `
})
export class ApprovalsComponent implements OnInit {
  private api = inject(ApiService);
  lang = inject(LanguageService);
  toast = inject(ToastService);
  requests = signal<ApprovalRequest[]>([]);
  showAll = false;

  ngOnInit() { this.load(); }

  load() {
    const path = this.showAll ? '/approvals/all' : '/approvals';
    this.api.get<ApprovalRequest[]>(path).subscribe(d => this.requests.set(d));
  }

  statusClass(status?: string) {
    if (status === 'Approved') return 'badge badge-primary';
    if (status === 'Rejected') return 'badge badge-warn';
    return 'badge badge-accent';
  }

  approve(id: string) {
    this.api.put(`/approvals/${id}/approve`, {}).subscribe({
      next: () => { this.toast.show(this.lang.t('approved')); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }

  reject(id: string) {
    this.api.put(`/approvals/${id}/reject`, {}).subscribe({
      next: () => { this.toast.show(this.lang.t('rejected')); this.load(); },
      error: e => this.toast.show(e.error?.message || 'Error', 'error')
    });
  }
}
